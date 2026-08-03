# Joomla Discover Requirements

Primary source: [Joomla 6 Extension Structure](https://github.com/duyduyly/php-notebook/blob/joomla/docs/joomla/learning/extensions/joomla-6-extension-structure.md)

Use this checklist to decide whether copied extension files are ready for Joomla Discover.

## Required checks

- [ ] Files are copied to the correct installed Joomla path.
- [ ] The manifest exists in the extension root expected by Joomla.
- [ ] The manifest XML is well-formed.
- [ ] The manifest `type` matches the extension type.
- [ ] The client is correct for Site or Administrator extensions.
- [ ] The technical name or element matches the extension directory.
- [ ] A plugin group matches its parent folder.
- [ ] Every manifest-declared file and folder exists.
- [ ] Namespace paths match the real `src` location when namespaces are declared.
- [ ] Declared installer scripts, media, languages, and SQL paths exist.
- [ ] There is no broken or conflicting registration in `#__extensions`.
- [ ] Required PHP files pass syntax validation.

## Typical manifest locations

```text
Component:           administrator/components/com_example/example.xml
Site module:         modules/mod_example/mod_example.xml
Administrator module: administrator/modules/mod_example/mod_example.xml
Plugin:              plugins/system/example/example.xml
Site template:       templates/example/templateDetails.xml
Administrator template: administrator/templates/example/templateDetails.xml
Library:             libraries/example/example.xml
```

Package and File extensions depend on their manifest and destination declarations.

## Status values

### Ready

All applicable Discover checks pass and no blocking registration conflict exists.

### Conditional

The extension should be detectable, but an unresolved SQL, dependency, namespace, or registration condition remains.

### Not ready

A required installed path, manifest, declared file, extension identity, or registration condition is invalid.

## Important limitation

A successful Discover operation proves only that Joomla detected and registered the installed extension structure.

It does not prove:

- Database schema completeness.
- Business-data completeness.
- Runtime behavior.
- Permission correctness.
- Dependency availability.
- Joomla/PHP compatibility.

The report must validate these areas separately.
