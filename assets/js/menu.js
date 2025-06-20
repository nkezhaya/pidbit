(function() {
  const handler = (e, { btn, menu, blockClass, checkOutsideClick }) => {
    const hideMenu = () => {
      menu.classList.remove(blockClass);
      menu.classList.add("hidden");
    };

    const showMenu = () => {
      menu.classList.add(blockClass);
      menu.classList.remove("hidden");
    };

    const isVisible = () => !menu.classList.contains("hidden");

    if (btn.contains(e.target)) {
      if (isVisible()) {
        hideMenu();
      } else {
        showMenu();
      }
    } else if (checkOutsideClick && !menu.contains(e.target)) {
      hideMenu();
    }
  };

  document.addEventListener("click", e => {
    const btn = document.getElementById("user-menu-button");
    const menu = document.getElementById("user-menu");

    handler(e, { btn, menu, blockClass: "block", checkOutsideClick: true });
  });

  document.addEventListener("click", e => {
    const btn = document.getElementById("mobile-menu-button");
    const menu = document.getElementById("mobile-menu");

    handler(e, { btn, menu, blockClass: "sm:block" });
  });
}());
