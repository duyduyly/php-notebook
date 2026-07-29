# Documentation Website Structure

## 1. What kind of website is this?

This project is a static documentation website generated from Markdown files by MkDocs Material and published with GitHub Pages.

The content flow is:

```text
Markdown files
      ↓
MkDocs build
      ↓
Static HTML, CSS, and JavaScript
      ↓
GitHub Pages
```

It is suitable for technical notes, tutorials, learning roadmaps, developer handbooks, and online books.

## 2. Project structure

```text
php-notebook/
├── mkdocs.yml
├── requirements.txt
├── docs/
│   ├── index.md
│   ├── explain.md
│   ├── cms/
│   │   └── overview.md
│   ├── php/
│   │   └── overview.md
│   ├── drupal/
│   │   └── overview.md
│   ├── wordpress/
│   │   └── overview.md
│   └── joomla/
│       └── overview.md
└── .github/
    └── workflows/
        └── deploy-docs.yml
```

Each top-level folder represents one main documentation area. Its `overview.md` file introduces the lessons contained in that area.

## 3. What happens when a nested folder is added?

This branch intentionally does not define a manual `nav` section in `mkdocs.yml`. MkDocs therefore generates the navigation menu from the folder and Markdown file structure automatically.

For example, adding this structure:

```text
docs/php/
├── overview.md
└── extensions/
    ├── introduction.md
    ├── installation.md
    └── examples.md
```

will automatically add an `extensions` section and its three pages to the website navigation during the next build.

The website structure will not break as long as:

- The files use the `.md` extension.
- Internal links point to valid files.
- File and folder names do not conflict only by uppercase and lowercase letters.
- The MkDocs build completes successfully.

## 4. Important navigation behavior

Automatic navigation follows the file and folder tree, but ordering is generally based on file names. To control order, use numeric prefixes such as:

```text
01-introduction.md
02-installation.md
03-examples.md
```

A file named `overview.md` appears as an Overview page inside its folder. If you want the folder URL itself to open the overview page, use `index.md` instead. You may also keep `overview.md` when that explicit page name is preferred.

If a manual `nav:` section is added to `mkdocs.yml` later, new files will no longer automatically appear unless that navigation configuration is updated.

## 5. Local development

```bash
pip install -r requirements.txt
mkdocs serve
```

Then open:

```text
http://127.0.0.1:8000
```

## 6. Deployment

The GitHub Actions workflow builds this branch when changes are pushed to `structure`.

In the repository settings, configure:

```text
Settings → Pages → Build and deployment → Source: GitHub Actions
```
