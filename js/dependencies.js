/**
 * Ensures Editor.JS is loaded on the page.
 *
 * @param {function} callback Called after editor.js is loaded.
 */
export function ensureTrixEditorLoaded(callback) {
  let script = document.createElement("script");
  script.src = "https://cdnjs.cloudflare.com/ajax/libs/trix/1.2.0/trix.js";
  script.onload = () => {
    let link = document.createElement("link");
    link.rel = "stylesheet";
    link.href = "https://cdnjs.cloudflare.com/ajax/libs/trix/1.2.0/trix.css";
    link.onload = callback;

    document.head.appendChild(link);
  };

  document.head.appendChild(script);
}

/**
 * Ensures CodeMirror is loaded on the page.
 *
 * @param {function} callback Called after editor.js is loaded.
 */
export function ensureCodeMirrorLoaded(callback) {
  if (window.CodeMirror) {
    return callback();
  }

  let script = document.createElement("script");
  script.src =
    "https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.48.4/codemirror.min.js";

  script.onload = () => {
    let html = document.createElement("script");
    html.src =
      "https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.48.4/mode/xml/xml.min.js";

    html.onload = () => {
      let link = document.createElement("link");
      link.rel = "stylesheet";
      link.href =
        "https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.48.4/codemirror.min.css";
      link.onload = callback;
      document.head.appendChild(link);
    };

    document.head.appendChild(html);
  };

  document.head.appendChild(script);
}

/**
 * Ensures Anime.JS (animation library) is loaded on the page.
 *
 * @param {function} callback Called after editor.js is loaded.
 */
export function ensureAnimeJSLoaded(callback) {
  let script = document.createElement("script");
  script.src =
    "https://cdnjs.cloudflare.com/ajax/libs/animejs/2.2.0/anime.min.js";
  script.onload = callback;
  document.head.appendChild(script);
}
