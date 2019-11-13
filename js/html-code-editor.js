import * as dependencies from "./dependencies";

class NetbuilderHtmlCodeEditor extends HTMLElement {
  connectedCallback() {
    dependencies.ensureCodeMirrorLoaded(() => {
      let editor = CodeMirror(this, {
        value: this.getAttribute("data-html"),
        lineNumbers: true,
        mode: "xml"
      });

      editor.on("change", ev => {
        let html = editor.getValue();
        var event = new CustomEvent("codemirror-change", { detail: html });
        this.dispatchEvent(event);
      });
    });
  }
}

customElements.define("netbuilder-html-code-editor", NetbuilderHtmlCodeEditor);
