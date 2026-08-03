# Joomla Extension Type Paths

Primary source: [Joomla 6 Extension Structure](https://github.com/duyduyly/php-notebook/blob/joomla/docs/joomla/learning/extensions/joomla-6-extension-structure.md)

Use this reference to map an installed custom extension from the source project to the correct target Joomla paths.

## Component

```text
administrator/components/com_example/   # Backend application and usual manifest location
components/com_example/                 # Site application
api/components/com_example/             # Optional API application
media/com_example/                      # CSS, JavaScript, images, and asset registry
language/<tag>/                         # Site language files
administrator/language/<tag>/           # Administrator and system language files
```

Also inspect template overrides:

```text
templates/<site-template>/html/com_example/
administrator/templates/<admin-template>/html/com_example/
```

## Site Module

```text
modules/mod_example/                    # Installed module and manifest
media/mod_example/                      # Optional assets
language/<tag>/mod_example*.ini         # Site language files
```

## Administrator Module

```text
administrator/modules/mod_example/      # Installed administrator module and manifest
media/mod_example/                      # Optional assets
administrator/language/<tag>/           # Administrator language files
```

## Plugin

```text
plugins/<group>/<name>/                 # Plugin code and manifest
media/plg_<group>_<name>/               # Optional assets
language/<tag>/plg_<group>_<name>*.ini  # Site language files when applicable
administrator/language/<tag>/           # Administrator/system language files
```

The plugin manifest `group` or `folder` must match the parent directory.

## Template

```text
templates/<name>/                       # Site template
administrator/templates/<name>/         # Administrator template
media/templates/site/<name>/            # Site template assets
media/templates/administrator/<name>/   # Administrator template assets
```

## Library

```text
libraries/<name>/                       # Shared code and manifest
media/lib_<name>/                       # Optional library assets
```

## Language

```text
language/<tag>/                         # Site translations
administrator/language/<tag>/           # Administrator translations
```

## Package

A package contains child extension archives before installation:

```text
pkg_example/
├── pkg_example.xml
├── script.php
└── packages/
    ├── com_example.zip
    ├── mod_example.zip
    └── plg_system_example.zip
```

After installation, each child is distributed to the path for its own extension type.

## File Extension

File extensions use manifest-defined destinations. Do not assume a standard runtime path. Read every `<files>` destination and installer-script operation.

## Non-standard path search

Always search these locations for related custom logic and resources:

```text
layouts/
cli/
images/
media/vendor/
libraries/
templates/*/html/
administrator/templates/*/html/
plugins/
modules/
administrator/modules/
```

A path is included in the clone plan when source-code evidence, manifest declarations, runtime references, or database/configuration references connect it to the extension.
