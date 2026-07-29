# Documentation Website Demo — Structure and Deployment Guide

## 1. Purpose of this file

This file is a reference document for the `structure` branch.

It does not configure GitHub Actions, MkDocs, Python, or GitHub Pages. It only explains how the demo documentation website is organized, what each file does, why the folders are arranged this way, and how the project can be published as a website.

Because this file is stored inside the `docs/` directory, MkDocs treats it as a normal documentation page and may include it in the generated website navigation. However, changing this file does not change the deployment logic. Deployment behavior is controlled by `.github/workflows/deploy-docs.yml`.

## 2. What type of website is this?

This project is a **static documentation website**.

It can also be described as:

- A Markdown-based documentation site.
- A technical handbook.
- An online programming book.
- A personal knowledge base.
- A learning-note website.

The website is called static because it does not require a running PHP application, database, CMS backend, or server-side API after it has been built.

The final website consists mainly of generated HTML, CSS, JavaScript, images, and other static assets.

## 3. Main technologies

| Technology | Responsibility |
|---|---|
| Markdown | Stores the documentation content in `.md` files |
| MkDocs | Converts Markdown files into a static website |
| Material for MkDocs | Provides the visual theme, navigation, search, and documentation UI |
| Python and pip | Install and run MkDocs and its dependencies |
| GitHub repository | Stores the source files and version history |
| GitHub Actions | Automatically builds and deploys the website |
| GitHub Pages | Hosts the generated static website publicly |

## 4. Complete project flow

```text
Developer writes or updates Markdown files
                ↓
Changes are committed and pushed to GitHub
                ↓
GitHub Actions detects the push to the structure branch
                ↓
The workflow checks out the repository
                ↓
Python is prepared on a temporary Ubuntu runner
                ↓
Dependencies from requirements.txt are installed
                ↓
MkDocs reads mkdocs.yml and the docs/ directory
                ↓
MkDocs converts Markdown into HTML, CSS, and JavaScript
                ↓
The generated site/ directory is uploaded as a Pages artifact
                ↓
GitHub Pages publishes the artifact
                ↓
The documentation website becomes available online
```

GitHub does not directly display the Markdown files as the final documentation website. GitHub Actions first runs MkDocs to convert them into a website, and GitHub Pages then hosts the generated output.

## 5. Project structure

```text
php-notebook/
├── README.md
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

## 6. Why this structure is used

The structure separates the project into three main areas:

```text
Configuration
├── mkdocs.yml
└── requirements.txt

Documentation content
└── docs/

Automation and deployment
└── .github/workflows/
```

This separation is useful because documentation writers can normally work only inside `docs/`, while the website configuration and deployment automation remain stable.

## 7. Root-level files

### 7.1 `README.md`

`README.md` is the introduction displayed on the GitHub repository page.

Its main audience is repository visitors and contributors. It is not automatically the MkDocs homepage because MkDocs uses `docs/index.md` as the website homepage.

Typical responsibilities:

- Explain what the repository contains.
- Show setup commands.
- Link to the deployed documentation website.
- Explain contribution rules.

### 7.2 `mkdocs.yml`

`mkdocs.yml` is the primary MkDocs configuration file.

MkDocs looks for this file at the repository root when the following commands run:

```bash
mkdocs serve
mkdocs build
```

The current file contains several configuration groups.

#### Site metadata

```yaml
site_name: PHP & CMS Documentation
site_description: A Markdown-based documentation website for PHP and CMS learning notes
site_author: Alan
repo_name: duyduyly/php-notebook
repo_url: https://github.com/duyduyly/php-notebook
```

Responsibilities:

- `site_name`: Defines the website title.
- `site_description`: Describes the website for metadata and integrations.
- `site_author`: Identifies the documentation author.
- `repo_name`: Defines the repository name shown by the theme.
- `repo_url`: Connects the website to the GitHub repository.

#### Navigation behavior

The current file intentionally does not contain a manual `nav:` section.

```yaml
# The nav section is intentionally omitted.
# MkDocs will automatically build navigation from the docs folder tree.
```

Without a manual `nav`, MkDocs discovers Markdown files inside `docs/` and generates navigation from the folder structure.

This is useful for a growing notebook because new Markdown files can appear automatically after the next build.

#### Theme configuration

```yaml
theme:
  name: material
  language: en
```

- `name: material` tells MkDocs to use Material for MkDocs instead of the basic MkDocs theme.
- `language: en` configures theme labels and interface text in English.

The `features` list enables interface behavior:

| Feature | Purpose |
|---|---|
| `navigation.tabs` | Shows major sections as navigation tabs when supported by the layout |
| `navigation.sections` | Groups related pages into sections |
| `navigation.expand` | Expands navigation sections |
| `navigation.top` | Adds a return-to-top control |
| `navigation.footer` | Adds previous and next page navigation in the footer |
| `content.code.copy` | Adds a copy button to code blocks |
| `search.suggest` | Shows search suggestions |
| `search.highlight` | Highlights matching search terms |

#### Plugins

```yaml
plugins:
  - search
```

The search plugin creates a client-side search index while MkDocs builds the website. It allows readers to search the generated documentation without requiring a database or backend search server.

#### Markdown extensions

The `markdown_extensions` section enables additional Markdown features beyond basic Markdown.

| Extension | Purpose |
|---|---|
| `admonition` | Supports note, warning, tip, and danger blocks |
| `attr_list` | Allows attributes to be added to Markdown elements |
| `tables` | Supports Markdown tables |
| `footnotes` | Supports footnotes |
| `toc` | Generates a table of contents and heading anchors |
| `pymdownx.details` | Supports collapsible detail blocks |
| `pymdownx.superfences` | Improves fenced code blocks and nested content |
| `pymdownx.highlight` | Adds syntax highlighting options |
| `pymdownx.tabbed` | Supports tabbed content |
| `pymdownx.tasklist` | Supports task-list checkboxes |

#### What happens during a build?

When this command runs:

```bash
mkdocs build --strict
```

MkDocs performs the following work:

1. Reads `mkdocs.yml`.
2. Scans the `docs/` directory.
3. Parses each Markdown file.
4. Applies the configured Markdown extensions.
5. Applies the Material theme.
6. Generates navigation and search data.
7. Writes the finished website into the `site/` directory.

The `--strict` option causes warnings to fail the build. This is useful for detecting broken documentation configuration, invalid links reported by MkDocs, or other build warnings before deployment.

### 7.3 `requirements.txt`

`requirements.txt` is the Python dependency list for the documentation project.

Its current content is:

```text
mkdocs-material
```

This tells pip to install Material for MkDocs. The package also installs MkDocs and the dependencies required by the configured Material features.

The workflow uses this command:

```bash
pip install -r requirements.txt
```

The same command should be used locally so that the local environment and GitHub Actions use the same dependency list.

#### Why is this file needed?

Without `requirements.txt`, GitHub Actions would not know which Python packages to install before running `mkdocs build`.

Benefits include:

- Reproducible setup.
- One installation command.
- Shared dependencies for all contributors.
- Easier CI configuration.
- Easier future upgrades.

#### Recommended improvement

For stronger build stability, dependency versions can be pinned:

```text
mkdocs-material==<approved-version>
```

Without a pinned version, a future workflow run may install a newer release. That may provide improvements, but it can also introduce unexpected behavior. A demo may use an unpinned dependency, while a production documentation site should normally use reviewed versions.

## 8. The `docs/` directory

`docs/` is the documentation source directory used by MkDocs.

Only files placed under this directory become documentation pages or static website assets by default.

### 8.1 `docs/index.md`

`docs/index.md` is the homepage of the generated website.

It maps to the website root:

```text
https://duyduyly.github.io/php-notebook/
```

This is different from the repository `README.md`.

### 8.2 `docs/explain.md`

This is the current reference guide.

Its responsibility is to explain the demo structure. It does not install dependencies, build the website, configure GitHub Pages, or run a workflow.

Because it is located under `docs/`, it is still converted into a normal website page by MkDocs.

### 8.3 Topic folders

The following folders represent major documentation domains:

```text
docs/cms/
docs/php/
docs/drupal/
docs/wordpress/
docs/joomla/
```

This grouping makes the documentation scalable. Each area can later contain its own lessons, tutorials, references, installation guides, migration notes, and examples.

### 8.4 `overview.md` files

Each main topic folder contains an `overview.md` file.

Examples:

```text
docs/php/overview.md
docs/joomla/overview.md
```

The overview page introduces the full learning area and can later contain:

- Learning goals.
- Prerequisites.
- Lesson order.
- Links to child topics.
- Recommended study paths.
- Version support notes.

In this demo, each overview contains a simple hello message for its section.

## 9. Nested folders and automatic navigation

Suppose the following files are added:

```text
docs/php/
├── overview.md
└── extensions/
    ├── 01-introduction.md
    ├── 02-installation.md
    └── 03-examples.md
```

Because `mkdocs.yml` does not define a manual `nav`, MkDocs will discover the new folder and files during the next build.

The generated navigation will conceptually look like:

```text
PHP
├── Overview
└── Extensions
    ├── Introduction
    ├── Installation
    └── Examples
```

The structure should not break merely because a new nested folder is added.

However, these rules should be followed:

- Use `.md` for documentation pages.
- Keep paths and filenames predictable.
- Avoid filenames that differ only by uppercase and lowercase letters.
- Update internal links when moving or renaming files.
- Do not create conflicting output paths.
- Run `mkdocs build --strict` before publishing important changes.

### Ordering

Automatic navigation commonly follows discovered file and folder names. Numeric prefixes provide predictable lesson order:

```text
01-introduction.md
02-installation.md
03-examples.md
```

### `overview.md` versus `index.md`

An `overview.md` file appears as a named Overview page in its folder.

An `index.md` file represents the default page for that folder URL.

For example:

```text
docs/php/index.md
```

can map naturally to:

```text
/php/
```

The current demo uses `overview.md` because the goal is to make the introductory page explicit. A future production structure may use `index.md` for cleaner folder landing pages.

### Manual navigation

If a `nav:` section is added later, navigation becomes manually controlled.

Example:

```yaml
nav:
  - Home: index.md
  - PHP:
      - Overview: php/overview.md
```

After manual navigation is introduced, newly added files do not automatically appear unless `mkdocs.yml` is updated.

## 10. The `.github/` directory

`.github/` is a special repository directory recognized by GitHub.

It can contain GitHub-specific configuration such as:

- GitHub Actions workflows.
- Issue templates.
- Pull request templates.
- Dependabot configuration.
- Code ownership rules.

For this demo, it contains only the deployment workflow.

## 11. `.github/workflows/deploy-docs.yml`

This YAML file defines a GitHub Actions workflow.

GitHub automatically recognizes YAML files inside:

```text
.github/workflows/
```

The file is not part of the documentation content. It is an automation definition executed by GitHub Actions.

### Workflow name

```yaml
name: Deploy documentation
```

This is the name shown in the repository Actions tab.

### Triggers

```yaml
on:
  push:
    branches:
      - structure
  workflow_dispatch:
```

The workflow runs when:

1. A commit is pushed to the `structure` branch.
2. A user manually starts it from the GitHub Actions interface.

Changes on another branch do not trigger this workflow unless the trigger configuration is changed.

### Permissions

```yaml
permissions:
  contents: read
  pages: write
  id-token: write
```

| Permission | Purpose |
|---|---|
| `contents: read` | Allows the workflow to read repository files |
| `pages: write` | Allows the workflow to publish to GitHub Pages |
| `id-token: write` | Allows secure identity-based authentication for deployment |

The workflow receives only the permissions it needs instead of broad repository write access.

### Concurrency

```yaml
concurrency:
  group: pages
  cancel-in-progress: false
```

This groups Pages deployments so that simultaneous deployments are managed safely.

With `cancel-in-progress: false`, an existing deployment is not automatically cancelled when another run starts.

### Build job

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
```

GitHub creates a temporary Ubuntu virtual machine called a runner.

The build job then performs these steps.

#### Checkout repository

```yaml
- name: Checkout repository
  uses: actions/checkout@v4
```

Downloads the repository contents into the runner.

#### Set up Python

```yaml
- name: Set up Python
  uses: actions/setup-python@v5
  with:
    python-version: "3.x"
```

Installs or activates a compatible Python 3 environment.

#### Install dependencies

```yaml
- name: Install dependencies
  run: pip install -r requirements.txt
```

Installs Material for MkDocs and its Python dependencies.

#### Build the website

```yaml
- name: Build website
  run: mkdocs build --strict
```

Reads `mkdocs.yml` and converts `docs/` into the generated `site/` directory.

#### Configure GitHub Pages

```yaml
- name: Configure GitHub Pages
  uses: actions/configure-pages@v5
```

Prepares metadata and settings needed by the Pages deployment process.

#### Upload the Pages artifact

```yaml
- name: Upload Pages artifact
  uses: actions/upload-pages-artifact@v3
  with:
    path: site
```

Packages the generated `site/` directory as a deployment artifact.

The workflow uploads `site/`, not the original Markdown source, because `site/` contains the final HTML website.

### Deploy job

```yaml
deploy:
  needs: build
```

The deploy job waits for the build job to finish successfully.

```yaml
- name: Deploy to GitHub Pages
  id: deployment
  uses: actions/deploy-pages@v4
```

This action publishes the uploaded artifact to GitHub Pages.

If the build fails, deployment does not run.

## 12. Why GitHub can deploy this website

GitHub can deploy the site because all required parts are present:

1. The repository contains source documentation.
2. `requirements.txt` defines the required build software.
3. `mkdocs.yml` defines how MkDocs should build the site.
4. The workflow installs the software and runs the build.
5. MkDocs generates a static `site/` directory.
6. The workflow uploads that directory as a Pages artifact.
7. The deploy action publishes the artifact.
8. GitHub Pages serves the static files over HTTPS.

GitHub Pages does not execute PHP, Python, Joomla, Drupal, WordPress, or a database. Python and MkDocs run only during the build process inside GitHub Actions. The final deployed result is static.

## 13. Required GitHub Pages setting

The repository must use GitHub Actions as the Pages source:

```text
Repository
→ Settings
→ Pages
→ Build and deployment
→ Source: GitHub Actions
```

If Pages is still configured to deploy from a branch, GitHub may continue showing an older Jekyll or branch-based site instead of the MkDocs artifact.

## 14. Local development

Install dependencies:

```bash
pip install -r requirements.txt
```

Start a local development server:

```bash
mkdocs serve
```

Open:

```text
http://127.0.0.1:8000
```

MkDocs watches the documentation files and usually rebuilds the local preview when they change.

## 15. Local production-style validation

Run:

```bash
mkdocs build --strict
```

Expected output directory:

```text
site/
```

The `site/` directory is generated output and normally should not be manually edited. Changes should be made in `docs/` or `mkdocs.yml`, followed by another build.

## 16. Responsibilities by file and folder

| Path | Responsibility | Used during build? | Published as content? |
|---|---|---:|---:|
| `README.md` | Repository introduction | No | No |
| `mkdocs.yml` | MkDocs site configuration | Yes | No |
| `requirements.txt` | Python dependency list | Yes | No |
| `docs/index.md` | Website homepage | Yes | Yes |
| `docs/explain.md` | Demo reference guide | Yes, as Markdown content | Yes |
| `docs/*/overview.md` | Topic overview pages | Yes | Yes |
| `.github/workflows/deploy-docs.yml` | Build and deployment automation | Yes, by GitHub Actions | No |
| `site/` | Generated static website | Created by build | Yes, as final deployed output |

## 17. Files that should normally be edited

For regular documentation work:

```text
docs/**/*.md
```

For website appearance, plugins, or navigation:

```text
mkdocs.yml
```

For Python package changes:

```text
requirements.txt
```

For build and deployment behavior:

```text
.github/workflows/deploy-docs.yml
```

## 18. Common failure cases

### The old GitHub Pages website is still displayed

Possible cause:

- Pages is configured to deploy from a branch instead of GitHub Actions.
- The workflow has not run successfully.
- The browser is showing cached content.

### A new Markdown file does not appear

Possible cause:

- The file is outside `docs/`.
- The file does not use the `.md` extension.
- A manual `nav:` configuration was added but not updated.
- The latest workflow run failed.

### The workflow fails during dependency installation

Possible cause:

- An invalid dependency was added to `requirements.txt`.
- A package version is unavailable or incompatible.

### The workflow fails during `mkdocs build --strict`

Possible cause:

- Invalid YAML in `mkdocs.yml`.
- Unsupported theme feature or Markdown extension.
- A warning is promoted to an error by `--strict`.
- A referenced file or configuration entry is invalid.

### The website has no useful content

Possible cause:

- Markdown pages are empty.
- `docs/index.md` has no homepage content.

## 19. Recommended production improvements

For a long-term documentation website, consider:

- Pinning dependency versions in `requirements.txt`.
- Adding a `.gitignore` entry for `site/`.
- Adding link checking.
- Adding Markdown linting.
- Adding spelling checks.
- Defining a consistent lesson template.
- Using `index.md` for section landing pages.
- Adding explicit `nav:` when strict ordering becomes more important than automatic discovery.
- Protecting the deployment branch.
- Reviewing GitHub Action version updates.

## 20. Summary

This branch demonstrates a documentation-as-code architecture:

```text
Markdown content
+ MkDocs configuration
+ Python dependencies
+ GitHub Actions automation
+ GitHub Pages hosting
= Public static documentation website
```

The structure is simple, version-controlled, scalable, and appropriate for technical learning material covering PHP, CMS concepts, Drupal, WordPress, and Joomla.
