const API_BASE_URL =
  "https://p15.projs.ifdemo.com/gdsglobal/wp-json/wp/v2";

export async function fetchJson(url) {
  const response = await fetch(url);

  if (!response.ok) {
    throw new Error(`Request failed with status ${response.status}`);
  }

  return {
    data: await response.json(),
    headers: response.headers,
  };
}

export async function getPosts(page = 1, perPage = 6) {
  const url = new URL(`${API_BASE_URL}/posts`);
  url.searchParams.set("page", page);
  url.searchParams.set("per_page", perPage);
  url.searchParams.set("_embed", "1");

  const { data, headers } = await fetchJson(url);

  return {
    posts: data,
    totalPages: Number(headers.get("X-WP-TotalPages")) || 1,
  };
}

export async function getPost(id) {
  const url = new URL(`${API_BASE_URL}/posts/${id}`);
  url.searchParams.set("_embed", "1");

  const { data } = await fetchJson(url);
  return data;
}

export function getFeaturedImage(post) {
  return (
    post?._embedded?.["wp:featuredmedia"]?.[0]?.source_url ||
    "https://placehold.co/1200x675?text=No+featured+image"
  );
}

export function formatDate(date) {
  return new Intl.DateTimeFormat("en", {
    dateStyle: "long",
  }).format(new Date(date));
}
