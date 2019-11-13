import * as dependencies from "./dependencies";

class NetbuilderHtmlContentEditor extends HTMLElement {
  connectedCallback() {
    dependencies.ensureTrixEditorLoaded(() => {
      let id = new Date().getTime().toString();

      this.innerHTML = `<input type="hidden" id="${id}">`;

      let hiddenInput = this.querySelector('input[type="hidden"]');
      hiddenInput.value = this.getAttribute("data-html");

      this.insertAdjacentHTML(
        "beforeend",
        `<trix-editor input="${id}"></trix-editor>`
      );

      let editor = this.querySelector("trix-editor");

      editor.addEventListener("trix-change", ev => {
        let html = hiddenInput.value;
        var event = new CustomEvent("trix-change", { detail: html });
        this.dispatchEvent(event);
      });
    });
  }
}

customElements.define(
  "netbuilder-html-content-editor",
  NetbuilderHtmlContentEditor
);
