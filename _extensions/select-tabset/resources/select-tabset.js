const tabsets = document.querySelectorAll(".select-tabset");

tabsets.forEach((tabset) => {
  const selectElement = tabset.querySelector("select");
  const tabPanes = tabset.querySelectorAll(".tab-pane");

  selectElement.addEventListener("change", (event) => {
    const id = event.target.value;
    tabPanes.forEach((tabPane) => {
      if (tabPane.id === id || tabPane.classList.contains("active"))
        tabPane.classList.toggle("active");
    });
  });
});
