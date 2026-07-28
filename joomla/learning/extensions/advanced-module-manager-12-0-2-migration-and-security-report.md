# Advanced Module Manager 12.0.2 Migration and Security Report for Joomla 6

## Conclusion

For a Joomla 3 to Joomla 6 migration, upgrade **Advanced Module Manager 7.5.1** to **Advanced Module Manager 12.0.2**.

- **7.5.1** is outdated and is not suitable for Joomla 6.
- **12.0.2** is the latest stable release verified on 28 July 2026.
- **12.0.2** was released on **24 July 2026**.
- It officially supports **Joomla 4, Joomla 5, and Joomla 6**.
- The vendor requires **PHP 8.1 or later** and **MySQL 5 or later**.
- Version **7.5.1 is affected by CVE-2026-63683** because the affected range is 1.0.0 through 11.0.1.
- Version **12.0.2 is outside the published affected range** for CVE-2026-63683.

## 1. Extension Information

| Field | Value |
|---|---|
| Extension | Advanced Module Manager |
| Vendor | Regular Labs |
| Current project version | 7.5.1 |
| Recommended Joomla 6 version | 12.0.2 |
| Latest stable version | 12.0.2 |
| Release date | 24 July 2026 |
| Supported Joomla versions | Joomla 4, Joomla 5, Joomla 6 |
| Minimum PHP version | PHP 8.1 |
| Minimum database version | MySQL 5 |
| Editions | Free and Professional |
| Migration priority | Critical |
| Migration risk | Medium |

## 2. Purpose and Main Features

Advanced Module Manager replaces and extends Joomla's standard Module Manager.

It allows modules to be displayed based on conditions such as:

- Menu items and homepage.
- Joomla content, articles, categories, and tags.
- Date and time.
- User groups and users.
- Devices, operating systems, and browsers.
- Components and templates.
- URLs.
- IP addresses and geolocation in the Professional edition.
- Custom PHP conditions in the Professional edition.

After installation, Joomla's normal module-management link points to Advanced Module Manager instead of the standard `com_modules` interface.

## 3. Version Comparison

| Item | Version 7.5.1 | Version 12.0.2 |
|---|---|---|
| Target Joomla generation | Joomla 3 era | Joomla 4, 5, and 6 |
| Joomla 6 support | No | Yes |
| Current vendor support | No | Yes |
| Security status | Affected by CVE-2026-63683 | Outside the published affected range |
| Recommended for production | No | Yes |
| Migration action | Remove from target build | Install and validate on Joomla 6 |

## 4. Latest Version and Release Information

The verified latest stable release is:

```text
Advanced Module Manager 12.0.2
Release date: 24 July 2026
Compatible with: Joomla 4, Joomla 5, Joomla 6
```

The release fixes an issue where batch updates of multiple Regular Labs extensions could fail after updating the first extension.

## 5. Security Assessment

### 5.1 CVE-2026-63683

| Field | Value |
|---|---|
| CVE | CVE-2026-63683 |
| Published date | 22 July 2026 |
| Weakness | Improper authentication / trust of spoofable forwarded headers |
| CWE | CWE-290 |
| Affected versions | 1.0.0 through 11.0.1 |
| Version 7.5.1 | Affected |
| Version 12.0.2 | Not included in the published affected range |

The vulnerability concerns IP and GeoIP conditions trusting spoofable forwarded headers. A remote client could potentially bypass location-based rules when proxy or forwarded-header handling is not sufficiently trusted.

This matters when Advanced Module Manager conditions are used for:

- IP-based module visibility.
- Country or geolocation-based module visibility.
- Restricting sensitive modules by network location.

### Important security rule

Module visibility conditions must not be treated as the main authorization mechanism for sensitive content.

Use Joomla ACL, component-level permission checks, authenticated API authorization, and server-side validation for real access control.

### 5.2 Target-version statement

No public advisory reviewed for this report identifies version 12.0.2 as affected by CVE-2026-63683. This does not guarantee that the release has no undiscovered vulnerabilities; it only confirms that 12.0.2 is outside the currently published affected range.

## 6. Joomla 3 to Joomla 6 Migration Guidance

Regular Labs documents that Joomla 3 assignments can be converted to the newer Conditions system when Advanced Module Manager is installed on Joomla 4, 5, or 6.

Recommended migration flow:

```text
1. Back up the Joomla 3 source code and database.
2. Record all existing module assignments and Advanced Module Manager rules.
3. Update the Joomla 3 site to Joomla 3.10 if following the vendor's sequential migration path.
4. Update compatible Regular Labs extensions on the Joomla 3 site.
5. Prepare the Joomla 6 staging environment.
6. Use PHP 8.1 or later.
7. Install Advanced Module Manager 12.0.2 using Joomla's Extension Installer.
8. Verify conversion of old assignments into Condition Sets.
9. Review every condition instead of assuming automatic conversion is perfect.
10. Test the website before production deployment.
```

Do not copy the version 7.5.1 extension directories directly into Joomla 6.

## 7. Installation and Upgrade Notes

Advanced Module Manager can be installed through:

```text
System → Install → Extensions
```

You may also use the Regular Labs Extension Manager.

When updating Advanced Module Manager:

- You normally do not need to uninstall the existing extension first.
- Installing a newer package updates the extension files automatically.
- A major-version upgrade may change or lose some configuration values.
- Always back up the database and source code before updating.
- Perform the upgrade on staging first.

For Professional updates, configure the Regular Labs Download Key in the Regular Labs Extension Manager or install the Professional package over the existing version.

## 8. Free and Professional Edition Mapping

Keep the same edition during migration when the project depends on Professional-only rules.

```text
Advanced Module Manager Free 7.5.1
→ Advanced Module Manager Free 12.0.2
```

or:

```text
Advanced Module Manager Professional 7.5.1
→ Advanced Module Manager Professional 12.0.2
```

Professional-only capabilities include items such as:

- IP-address conditions.
- Geolocation conditions.
- User conditions.
- Detailed date and time rules.
- Article custom-field conditions.
- Third-party content integrations.
- Custom PHP conditions.
- Additional module rendering controls.

Installing the Free edition on Joomla 6 can remove access to conditions that existed in a Joomla 3 Professional installation.

## 9. Verification Checklist

### Installation

- [ ] Advanced Module Manager 12.0.2 is installed.
- [ ] The Regular Labs system plugin is installed and enabled.
- [ ] Joomla reports no package-installation errors.
- [ ] The extension opens without PHP or database errors.
- [ ] The correct Free or Professional edition is installed.

### Conditions and assignments

- [ ] Menu assignments work.
- [ ] Homepage conditions work.
- [ ] Category and article conditions work.
- [ ] Language conditions work.
- [ ] User-group conditions work.
- [ ] Device, operating-system, and browser conditions work.
- [ ] URL conditions work.
- [ ] Shared Condition Sets were converted correctly.
- [ ] IP and GeoIP rules were reviewed carefully.

### Regression testing

- [ ] Frontend modules appear on the correct pages.
- [ ] Modules do not appear on excluded pages.
- [ ] Logged-in and guest users see the correct modules.
- [ ] Mobile and desktop conditions work.
- [ ] SEF URLs do not change the expected conditions.
- [ ] Cache does not cause incorrect module visibility.
- [ ] Custom templates and module chrome render correctly.
- [ ] No module condition is being used as the only authorization control.

## 10. Recommended Migration Report Entry

| Field | Recommended value |
|---|---|
| Extension | Advanced Module Manager |
| Current version | 7.5.1 |
| Target version | 12.0.2 |
| Latest stable version | 12.0.2 |
| Release date | 24 July 2026 |
| Joomla 6 compatible | Yes |
| Minimum PHP | 8.1 |
| Current-version vulnerability | CVE-2026-63683 |
| Target-version status | Outside the published affected range |
| Required action | Install the Joomla 6-compatible package and validate converted conditions |
| Priority | Critical |
| Risk | Medium |

## 11. Official Sources

- Product page: <https://regularlabs.com/advancedmodulemanager>
- Download and latest version: <https://regularlabs.com/advancedmodulemanager/download>
- Changelog: <https://regularlabs.com/advancedmodulemanager/changelog>
- Official documentation: <https://docs.regularlabs.com/advancedmodulemanager>
- Installation guide: <https://docs.regularlabs.com/advancedmodulemanager/getting-started/installation>
- Installation FAQ: <https://docs.regularlabs.com/advancedmodulemanager/faqs/installation>
- Joomla 3 migration guidance: <https://docs.regularlabs.com/advancedmodulemanager/faqs/upgrading-from-joomla3-to-joomla4>
- CVE-2026-63683: <https://nvd.nist.gov/vuln/detail/CVE-2026-63683>

## Final Recommendation

Do not reuse Advanced Module Manager 7.5.1 on Joomla 6. Install version **12.0.2** on a Joomla 6 staging environment, preserve the same Free or Professional edition, validate all converted Condition Sets, and give special attention to IP and GeoIP rules affected by the historical vulnerability.