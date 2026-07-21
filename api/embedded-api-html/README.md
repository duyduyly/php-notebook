# Embed a WordPress API blog in a static HTML website

This example shows how to fetch WordPress posts with the REST API and render them in a plain HTML, CSS, JavaScript, and Bootstrap 5 website.

## What you will build

- A blog listing with Bootstrap cards
- Featured images via WordPress `_embed`
- Pagination via the `X-WP-TotalPages` response header
- A detail page selected by `?id=POST_ID`
- Loading and error states
- Shared API helper functions

## Folder structure

```text
embedded-api-html/
├── index.html
├── detail.html
├── README.md
├── css/
│   └── style.css
└── js/
    ├── api.js
    ├── blog.js
    └── detail.js
```

## API endpoints

List posts:

```text
https://p15.projs.ifdemo.com/gdsglobal/wp-json/wp/v2/posts?page=1&per_page=6&_embed=1
```

Get one post:

```text
https://p15.projs.ifdemo.com/gdsglobal/wp-json/wp/v2/posts/159?_embed=1
```

The `_embed=1` parameter includes related resources such as the featured image in `post._embedded["wp:featuredmedia"]`.

## Run the example

ES modules usually do not work correctly when an HTML file is opened directly with `file://`. Start a local HTTP server from this folder.

With PHP:

```bash
php -S localhost:8000
```

Or with Python:

```bash
python -m http.server 8000
```

Then open:

```text
http://localhost:8000/index.html
```

Example detail URL:

```text
http://localhost:8000/detail.html?id=159
```

## How the code works

### 1. Shared API helper

`js/api.js` contains the API base URL and reusable functions:

- `fetchJson(url)`: checks the HTTP status and parses JSON.
- `getPosts(page, perPage)`: requests a page of posts and reads the total page count.
- `getPost(id)`: requests one post.
- `getFeaturedImage(post)`: safely reads the embedded featured image.
- `formatDate(date)`: formats the WordPress date.

Change `API_BASE_URL` in this file to use another WordPress website.

### 2. Blog listing

`index.html` contains a reusable `<template>` for each post card. `js/blog.js` clones that template, fills it with API data, and creates pagination links.

The current page comes from the URL:

```js
const currentPage =
  Number(new URLSearchParams(window.location.search).get("page")) || 1;
```

### 3. Detail page

Each card links to `detail.html?id=POST_ID`. `js/detail.js` reads the ID, fetches the matching post, and renders `post.content.rendered`.

WordPress content may include images, video, or iframe embeds. The CSS keeps those elements responsive.

## Copy into another project

Copy the entire `embedded-api-html` folder, then:

1. Update `API_BASE_URL` in `js/api.js`.
2. Replace the Bootstrap CDN version if your project already loads Bootstrap.
3. Adjust colors and layout in `css/style.css`.
4. Keep the relative file paths unchanged, or update the imports and links.

## Common problems

### CORS error

The WordPress server must allow requests from the HTML website domain. If you cannot change the WordPress CORS configuration, create a same-origin PHP/backend proxy and call that proxy from JavaScript.

### `Failed to fetch dynamically imported module`

Do not open the page directly with `file://`. Use a local server.

### Featured image is missing

Confirm the request contains `_embed=1` and that the post has a featured image. The example uses a placeholder when no image exists.

### SEO limitation

Client-side rendering is convenient, but search crawlers may not index it as reliably as server-rendered HTML. For SEO-critical pages, fetch and render the WordPress content in PHP or another server-side layer.

## Security note

The example uses `innerHTML` because WordPress returns rendered HTML. Only do this with content from a WordPress site you trust and control. Sanitize untrusted HTML before inserting it into the page.
