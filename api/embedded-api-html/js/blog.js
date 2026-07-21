import { formatDate, getFeaturedImage, getPosts } from "./api.js";

const postList = document.querySelector("#post-list");
const template = document.querySelector("#post-card-template");
const pagination = document.querySelector("#pagination");
const loading = document.querySelector("#loading");
const alertBox = document.querySelector("#alert");

const params = new URLSearchParams(window.location.search);
const currentPage = Math.max(1, Number(params.get("page")) || 1);

function renderPosts(posts) {
  postList.replaceChildren();

  posts.forEach((post) => {
    const card = template.content.cloneNode(true);
    const image = card.querySelector(".post-card__image");

    image.src = getFeaturedImage(post);
    image.alt = post.title.rendered;
    card.querySelector(".post-card__date").textContent = formatDate(post.date);
    card.querySelector(".post-card__title").innerHTML = post.title.rendered;
    card.querySelector(".post-card__excerpt").innerHTML = post.excerpt.rendered;
    card.querySelector(".post-card__link").href = `./detail.html?id=${post.id}`;

    postList.append(card);
  });
}

function renderPagination(totalPages) {
  pagination.replaceChildren();

  for (let page = 1; page <= totalPages; page += 1) {
    const item = document.createElement("li");
    const link = document.createElement("a");

    item.className = `page-item${page === currentPage ? " active" : ""}`;
    link.className = "page-link";
    link.href = `?page=${page}`;
    link.textContent = page;
    link.setAttribute("aria-label", `Go to page ${page}`);

    item.append(link);
    pagination.append(item);
  }
}

async function init() {
  try {
    const { posts, totalPages } = await getPosts(currentPage);
    renderPosts(posts);
    renderPagination(totalPages);
  } catch (error) {
    console.error(error);
    alertBox.textContent =
      "Cannot load posts. Check the API URL, internet connection, and CORS settings.";
    alertBox.classList.remove("d-none");
  } finally {
    loading.classList.add("d-none");
  }
}

init();
