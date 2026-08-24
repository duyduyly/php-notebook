param(
    [Parameter(Mandatory = $true)]
    [string]$RunDirectory
)

$ErrorActionPreference = 'Stop'
$inventoryRoot = (Resolve-Path -LiteralPath $RunDirectory).Path
$templateRoot = Join-Path $PSScriptRoot 'templates'
$validationErrors = [System.Collections.Generic.List[string]]::new()
$validationWarnings = [System.Collections.Generic.List[string]]::new()

$fileContracts = [ordered]@{
    '00' = '00-inventory-run.csv'
    '01' = '01-feature-inventory.csv'
    '02' = '02-page-inventory.csv'
    '03' = '03-page-feature-map.csv'
    '04' = '04-feature-dependency-map.csv'
    '05' = '05-feature-evidence.csv'
    '06' = '06-feature-coverage.csv'
    '07' = '07-implementation-inventory.csv'
    '08' = '08-data-object-inventory.csv'
    '09' = '09-external-integration-inventory.csv'
    '10' = '10-route-runtime-verification.csv'
    '11' = '11-access-control-map.csv'
    '12' = '12-exception-register.csv'
    '13' = '13-validation-results.csv'
}

$templateContracts = [ordered]@{}
foreach ($contractKey in $fileContracts.Keys) {
    $templateContracts[$contractKey] = $fileContracts[$contractKey] -replace '\.csv$', '-template.csv'
}

function Add-ValidationError([string]$Message) {
    $validationErrors.Add($Message)
}

function Add-ValidationWarning([string]$Message) {
    $validationWarnings.Add($Message)
}

function Read-InventoryCsv([string]$ContractKey) {
    $inventoryFile = Join-Path $inventoryRoot $fileContracts[$ContractKey]
    if (-not (Test-Path -LiteralPath $inventoryFile -PathType Leaf)) {
        return @()
    }

    return @(Import-Csv -LiteralPath $inventoryFile)
}

function Get-IdSet([object[]]$Rows, [string]$ColumnName) {
    $idSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($row in $Rows) {
        $idValue = [string]$row.$ColumnName
        if (-not [string]::IsNullOrWhiteSpace($idValue)) {
            [void]$idSet.Add($idValue)
        }
    }
    return $idSet
}

function Test-UniqueRequiredColumn([object[]]$Rows, [string]$ColumnName, [string]$FileName) {
    $seenValues = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($row in $Rows) {
        $value = [string]$row.$ColumnName
        if ([string]::IsNullOrWhiteSpace($value)) {
            Add-ValidationError "$FileName has an empty required $ColumnName."
            continue
        }
        if (-not $seenValues.Add($value)) {
            Add-ValidationError "$FileName has duplicate $ColumnName '$value'."
        }
    }
}

function Test-Reference(
    [object[]]$Rows,
    [string]$ColumnName,
    [System.Collections.Generic.HashSet[string]]$TargetIds,
    [string]$FileName,
    [bool]$Required
) {
    foreach ($row in $Rows) {
        $reference = [string]$row.$ColumnName
        if ([string]::IsNullOrWhiteSpace($reference)) {
            if ($Required) {
                Add-ValidationError "$FileName has an empty required reference $ColumnName."
            }
            continue
        }
        if ($reference -eq 'UNKNOWN') {
            Add-ValidationError "$FileName uses UNKNOWN as $ColumnName; create an exception and preserve the unresolved subject."
            continue
        }
        if (-not $TargetIds.Contains($reference)) {
            Add-ValidationError "$FileName has broken $ColumnName reference '$reference'."
        }
    }
}

function Test-AllowedValues(
    [object[]]$Rows,
    [string]$ColumnName,
    [string[]]$AllowedValues,
    [string]$FileName,
    [bool]$AllowEmpty
) {
    foreach ($row in $Rows) {
        $value = [string]$row.$ColumnName
        if ([string]::IsNullOrWhiteSpace($value) -and $AllowEmpty) {
            continue
        }
        if ($value -notin $AllowedValues) {
            Add-ValidationError "$FileName has invalid $ColumnName '$value'."
        }
    }
}

$runFile = Join-Path $inventoryRoot $fileContracts['00']
if (-not (Test-Path -LiteralPath $runFile -PathType Leaf)) {
    Add-ValidationError "Missing required file $($fileContracts['00'])."
    $inventoryProfile = 'UNKNOWN'
} else {
    $runRows = @(Import-Csv -LiteralPath $runFile)
    if ($runRows.Count -ne 1) {
        Add-ValidationError "$($fileContracts['00']) must contain exactly one run row."
    }
    $inventoryProfile = if ($runRows.Count -gt 0) { [string]$runRows[0].profile } else { 'UNKNOWN' }
}

$requiredContractKeys = if ($inventoryProfile -eq 'CATALOG') {
    @('00', '01', '02', '03', '05', '13')
} elseif ($inventoryProfile -eq 'COMPLETE') {
    @($fileContracts.Keys)
} else {
    Add-ValidationError "Inventory profile must be CATALOG or COMPLETE; observed '$inventoryProfile'."
    @('00')
}

foreach ($contractKey in $requiredContractKeys) {
    $inventoryFile = Join-Path $inventoryRoot $fileContracts[$contractKey]
    $templateFile = Join-Path $templateRoot $templateContracts[$contractKey]
    if (-not (Test-Path -LiteralPath $inventoryFile -PathType Leaf)) {
        Add-ValidationError "Missing required file $($fileContracts[$contractKey])."
        continue
    }
    if (-not (Test-Path -LiteralPath $templateFile -PathType Leaf)) {
        Add-ValidationError "Missing workflow template $($templateContracts[$contractKey])."
        continue
    }

    $actualHeader = (Get-Content -LiteralPath $inventoryFile -TotalCount 1).TrimStart([char]0xFEFF)
    $expectedHeader = (Get-Content -LiteralPath $templateFile -TotalCount 1).TrimStart([char]0xFEFF)
    if ($actualHeader -cne $expectedHeader) {
        Add-ValidationError "$($fileContracts[$contractKey]) header does not match its canonical template."
    }
}

$rows00 = Read-InventoryCsv '00'
$rows01 = Read-InventoryCsv '01'
$rows02 = Read-InventoryCsv '02'
$rows03 = Read-InventoryCsv '03'
$rows04 = Read-InventoryCsv '04'
$rows05 = Read-InventoryCsv '05'
$rows06 = Read-InventoryCsv '06'
$rows07 = Read-InventoryCsv '07'
$rows08 = Read-InventoryCsv '08'
$rows09 = Read-InventoryCsv '09'
$rows10 = Read-InventoryCsv '10'
$rows11 = Read-InventoryCsv '11'
$rows12 = Read-InventoryCsv '12'
$rows13 = Read-InventoryCsv '13'

$idContracts = @(
    @($rows00, 'inventory_run_id', $fileContracts['00']),
    @($rows01, 'feature_id', $fileContracts['01']),
    @($rows02, 'page_id', $fileContracts['02']),
    @($rows03, 'map_id', $fileContracts['03']),
    @($rows04, 'dependency_id', $fileContracts['04']),
    @($rows05, 'evidence_id', $fileContracts['05']),
    @($rows06, 'coverage_id', $fileContracts['06']),
    @($rows07, 'implementation_id', $fileContracts['07']),
    @($rows08, 'data_object_id', $fileContracts['08']),
    @($rows09, 'integration_id', $fileContracts['09']),
    @($rows10, 'verification_id', $fileContracts['10']),
    @($rows11, 'acl_map_id', $fileContracts['11']),
    @($rows12, 'exception_id', $fileContracts['12']),
    @($rows13, 'validation_id', $fileContracts['13'])
)
foreach ($idContract in $idContracts) {
    Test-UniqueRequiredColumn $idContract[0] $idContract[1] $idContract[2]
}
Test-UniqueRequiredColumn $rows01 'feature_key' $fileContracts['01']
Test-UniqueRequiredColumn $rows02 'page_key' $fileContracts['02']
Test-UniqueRequiredColumn $rows07 'implementation_key' $fileContracts['07']

$runIds = Get-IdSet $rows00 'inventory_run_id'
$featureIds = Get-IdSet $rows01 'feature_id'
$pageIds = Get-IdSet $rows02 'page_id'
$implementationIds = Get-IdSet $rows07 'implementation_id'
$dataObjectIds = Get-IdSet $rows08 'data_object_id'
$evidenceIds = Get-IdSet $rows05 'evidence_id'

foreach ($runBoundContract in @(
    @($rows05, $fileContracts['05']), @($rows06, $fileContracts['06']), @($rows07, $fileContracts['07']),
    @($rows08, $fileContracts['08']), @($rows09, $fileContracts['09']), @($rows10, $fileContracts['10']),
    @($rows11, $fileContracts['11']), @($rows12, $fileContracts['12']), @($rows13, $fileContracts['13'])
)) {
    Test-Reference $runBoundContract[0] 'inventory_run_id' $runIds $runBoundContract[1] $true
}

Test-Reference $rows01 'primary_implementation_id' $implementationIds $fileContracts['01'] $false
Test-Reference $rows02 'parent_page_id' $pageIds $fileContracts['02'] $false
Test-Reference $rows03 'page_id' $pageIds $fileContracts['03'] $true
Test-Reference $rows03 'feature_id' $featureIds $fileContracts['03'] $true
Test-Reference $rows03 'implementation_id' $implementationIds $fileContracts['03'] ($inventoryProfile -eq 'COMPLETE')
Test-Reference $rows04 'feature_id' $featureIds $fileContracts['04'] $true
Test-Reference $rows04 'implementation_id' $implementationIds $fileContracts['04'] $false
Test-Reference $rows04 'depends_on_implementation_id' $implementationIds $fileContracts['04'] $false
Test-Reference $rows08 'implementation_id' $implementationIds $fileContracts['08'] $false
Test-Reference $rows08 'parent_data_object_id' $dataObjectIds $fileContracts['08'] $false
Test-Reference $rows09 'feature_id' $featureIds $fileContracts['09'] $false
Test-Reference $rows09 'implementation_id' $implementationIds $fileContracts['09'] $false
Test-Reference $rows10 'page_id' $pageIds $fileContracts['10'] $false
Test-Reference $rows10 'feature_id' $featureIds $fileContracts['10'] $false
Test-Reference $rows10 'implementation_id' $implementationIds $fileContracts['10'] $false
Test-Reference $rows11 'feature_id' $featureIds $fileContracts['11'] $false
Test-Reference $rows11 'page_id' $pageIds $fileContracts['11'] $false
Test-Reference $rows11 'implementation_id' $implementationIds $fileContracts['11'] $false

foreach ($evidenceContract in @(
    @($rows04, $fileContracts['04']), @($rows06, $fileContracts['06']), @($rows07, $fileContracts['07']),
    @($rows08, $fileContracts['08']), @($rows09, $fileContracts['09']), @($rows10, $fileContracts['10']),
    @($rows11, $fileContracts['11']), @($rows12, $fileContracts['12']), @($rows13, $fileContracts['13'])
)) {
    Test-Reference $evidenceContract[0] 'evidence_id' $evidenceIds $evidenceContract[1] $false
}

$mappingKeys = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($mapRow in $rows03) {
    $mappingKey = @(
        $mapRow.page_id, $mapRow.feature_id, $mapRow.implementation_id, $mapRow.usage_type,
        $mapRow.position, $mapRow.trigger, $mapRow.condition
    ) -join '|'
    if (-not $mappingKeys.Add($mappingKey)) {
        Add-ValidationError "$($fileContracts['03']) has duplicate normalized mapping '$mappingKey'."
    }
}

$booleanValues = @('YES', 'NO', 'UNKNOWN')
Test-AllowedValues $rows01 'in_scope' $booleanValues $fileContracts['01'] $false
Test-AllowedValues $rows02 'dynamic' $booleanValues $fileContracts['02'] $false
Test-AllowedValues $rows02 'requires_auth' $booleanValues $fileContracts['02'] $false
Test-AllowedValues $rows02 'in_scope' $booleanValues $fileContracts['02'] $false
Test-AllowedValues $rows03 'is_primary' $booleanValues $fileContracts['03'] $false
Test-AllowedValues $rows07 'installed' $booleanValues $fileContracts['07'] $false
Test-AllowedValues $rows07 'enabled' $booleanValues $fileContracts['07'] $false
Test-AllowedValues $rows07 'published' $booleanValues $fileContracts['07'] $false
Test-AllowedValues $rows07 'discoverable' $booleanValues $fileContracts['07'] $false
Test-AllowedValues $rows07 'in_scope' $booleanValues $fileContracts['07'] $false
Test-AllowedValues $rows08 'contains_pii' $booleanValues $fileContracts['08'] $false
Test-AllowedValues $rows08 'in_scope' $booleanValues $fileContracts['08'] $false
Test-AllowedValues $rows09 'contains_pii' $booleanValues $fileContracts['09'] $false
Test-AllowedValues $rows09 'enabled' $booleanValues $fileContracts['09'] $false
Test-AllowedValues $rows05 'evidence_level' @('VERIFIED', 'STATIC', 'INFERRED', 'UNKNOWN', 'BLOCKED') $fileContracts['05'] $false
Test-AllowedValues $rows13 'status' @('PASS', 'FAIL', 'NOT_RUN', 'MANUAL', 'BLOCKED', 'NOT_APPLICABLE') $fileContracts['13'] $false

foreach ($coverageRow in $rows06) {
    $total = 0
    $reviewed = 0
    $coverage = 0.0
    if (-not [int]::TryParse([string]$coverageRow.total_items, [ref]$total) -or $total -lt 0) {
        Add-ValidationError "$($fileContracts['06']) has invalid total_items '$($coverageRow.total_items)'."
        continue
    }
    if (-not [int]::TryParse([string]$coverageRow.reviewed_items, [ref]$reviewed) -or $reviewed -lt 0 -or $reviewed -gt $total) {
        Add-ValidationError "$($fileContracts['06']) has invalid reviewed_items '$($coverageRow.reviewed_items)'."
    }
    if (-not [double]::TryParse([string]$coverageRow.coverage_percent, [ref]$coverage) -or $coverage -lt 0 -or $coverage -gt 100) {
        Add-ValidationError "$($fileContracts['06']) has invalid coverage_percent '$($coverageRow.coverage_percent)'."
    }
    if ([string]::IsNullOrWhiteSpace([string]$coverageRow.scope_definition) -or [string]::IsNullOrWhiteSpace([string]$coverageRow.calculation)) {
        Add-ValidationError "$($fileContracts['06']) requires scope_definition and calculation."
    }
}

if ($inventoryProfile -eq 'COMPLETE') {
    $blockingExceptions = @($rows12 | Where-Object {
        $_.status -in @('OPEN', 'BLOCKED') -and $_.severity -in @('HIGH', 'CRITICAL')
    })
    if ($blockingExceptions.Count -gt 0) {
        Add-ValidationError "COMPLETE inventory has $($blockingExceptions.Count) unresolved HIGH/CRITICAL exception(s)."
    }

    foreach ($coverageRow in $rows06) {
        if ([double]$coverageRow.coverage_percent -lt 100 -and $coverageRow.status -eq 'PASS') {
            Add-ValidationError "$($fileContracts['06']) marks '$($coverageRow.coverage_area)' PASS below 100% coverage."
        }
    }
}

foreach ($warningMessage in $validationWarnings) {
    Write-Warning $warningMessage
}

if ($validationErrors.Count -gt 0) {
    foreach ($errorMessage in $validationErrors) {
        Write-Error $errorMessage -ErrorAction Continue
    }
    Write-Host "Inventory validation FAILED with $($validationErrors.Count) error(s)."
    exit 1
}

Write-Host "Inventory validation PASSED for profile $inventoryProfile."
exit 0
