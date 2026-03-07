document.addEventListener("DOMContentLoaded", function () {
  const toggle = document.querySelector("[data-nav-toggle]");
  const menu = document.querySelector("[data-nav-menu]");
  if (toggle && menu) {
    toggle.addEventListener("click", function () {
      menu.classList.toggle("open");
    });
  }

  const yearNode = document.querySelector("[data-year]");
  if (yearNode) {
    yearNode.textContent = new Date().getFullYear();
  }

  const path = window.location.pathname.split("/").pop() || "index.html";
  document.querySelectorAll("[data-nav-menu] a").forEach(a => {
    const href = a.getAttribute("href");
    if ((path === "" && href === "index.html") || href === path) {
      a.classList.add("active");
    }
  });
});
