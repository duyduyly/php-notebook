# Joomla 6 Migration Behavior Checklist

## Authentication and Access

- [ ] Approved users can sign in.
- [ ] Blocked users remain blocked.
- [ ] Access levels behave correctly.
- [ ] Create, edit, publish, and delete permissions are correct.
- [ ] No user receives unintended administrator access.

## Content

- [ ] Articles open on the frontend and save in the backend.
- [ ] Categories display the expected articles.
- [ ] Publishing and featured states are correct.
- [ ] Metadata, images, links, and languages are correct.
- [ ] Workflow stages behave correctly.

## Menus and Routing

- [ ] The homepage is correct.
- [ ] Article and category menu items open mapped records.
- [ ] Parent-child menu structure is correct.
- [ ] Important legacy URLs work or redirect.
- [ ] No unexpected 404 pages are found.

## Modules and Templates

- [ ] Required module types are installed.
- [ ] Header and footer positions are valid.
- [ ] All-pages, include, and exclude assignments are correct.
- [ ] Module access, language, and parameters are correct.

## Extended Content and Operations

- [ ] Tags and custom fields display correctly.
- [ ] Media files exist and load.
- [ ] Content plugin syntax renders correctly.
- [ ] Category, menu, tag, and ACL trees are valid.
- [ ] Joomla database schema check passes.
- [ ] Cache and Smart Search are rebuilt.
- [ ] Logs contain no migration-related fatal errors.
- [ ] Every skipped or failed record is explained.
