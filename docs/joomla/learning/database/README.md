# Joomla Database Documentation

This directory contains database documentation organized by Joomla major version.

## Table of Contents

- [Joomla 3 Database](#joomla-3-database)
- [Directory Structure](#directory-structure)
- [How to Use This Documentation](#how-to-use-this-documentation)

## Joomla 3 Database

- [Joomla 3 Database Structure and ERD](./joomla-3/README.md)

The Joomla 3 document includes:

- core database table groups;
- important columns and logical relationships;
- database prefix usage;
- content, category, menu, module, user, ACL, tag, field, extension, language, and session tables;
- Mermaid ERD and focused relationship diagrams;
- Joomla 3 to Joomla 6 migration guidance;
- migration-sensitive tables and a validation checklist.

## Directory Structure

```text
database/
├── README.md
└── joomla-3/
    └── README.md
```

## How to Use This Documentation

1. Open the [Joomla 3 Database Structure and ERD](./joomla-3/README.md).
2. Use its table of contents to navigate directly to the required database area.
3. Review the high-level ERD before writing SQL or migration scripts.
4. Follow the migration order and checklist before moving data to Joomla 6.

> The diagrams describe the Joomla 3 core database at a logical level. Third-party and custom extensions may add separate tables and relationships.
