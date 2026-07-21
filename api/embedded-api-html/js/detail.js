import { formatDate, getFeaturedImage, getPost } from "./api.js";

const postElement = document.querySelector("#post");
const loading = document.querySelector("#loading");
const alertBox = document.querySelector("#alert");
const postId = new URLSearchParams(window.location.search).get("id");

async function init() {
  if (!postId) {
    loading.classList.add("d-none");
    alertBox.textContent = "Missing post ID. Example: detail.html?id=159";
    alertBox.classList.remove("d-none");
    return;
  }

  try {
    const post = await getPost(postId);
    const image = document.querySelector("#post-image");

    document.title = `${post.title.rendered} | WordPress API Blog`;
    document.querySelector("#post-date").textContent = formatDate(post.date);
    document.querySelector("#post-title").innerHTML = post.title.rendered;
    document.querySelector("#post-content").innerHTML = post.content.rendered;

    image.src = getFeaturedImage(post);
    image.alt = post.title.rendered;

    postElement.classList.remove("d-none");
  } catch (error) {
    console.error(error);
    alertBox.textContent =
      "Cannot load this article. Check the post ID, API URL, and CORS settings.";
    alertBox.classList.remove("d-none");
  } finally {
    loading.classList.add("d-none");
  }
}

init();
