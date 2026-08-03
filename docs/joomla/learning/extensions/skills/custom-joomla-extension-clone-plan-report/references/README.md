# Clone Plan Skill References

This directory contains the validation knowledge used by the `custom-joomla-extension-clone-plan-report` skill.

## Reference order

1. [Joomla 6 Extension Structure](https://github.com/duyduyly/php-notebook/blob/joomla/docs/joomla/learning/extensions/joomla-6-extension-structure.md)
2. [Extension Type Paths](./extension-type-paths.md)
3. [Discover Requirements](./discover-requirements.md)
4. [Database Schema Checklist](./database-schema-checklist.md)
5. [Coverage Rules](./coverage-rules.md)

## Usage rule

Read the primary Joomla structure document first, classify the extension type, and then apply only the reference rules relevant to that type.

Do not require Component-only folders for Modules, Plugins, Templates, Libraries, Languages, Packages, or File extensions.

When the source extension conflicts with the expected Joomla structure, report the difference as evidence. Do not silently rewrite or normalize the source logic during plan generation.
