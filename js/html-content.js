class NetbuilderHtmlContent extends HTMLElement {
  connectedCallback() {
    this.innerHTML = this.getAttribute("data-html");
  }
}

customElements.define("netbuilder-html-content", NetbuilderHtmlContent);
