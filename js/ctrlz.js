const CTRL_KEY_CODE = 17;
const Z_KEY_CODE = 90;

export default class CtrlZ {
  constructor(app) {
    this.app = app;
    this.lastPressedKey = null;
  }

  start() {
    this.onCtrlZ(() => {
      if (this.hasTrix()) {
        if (this.noTrixContentTwice()) {
          this.app.ports.ctrlZPressed.send(null);
        }
      } else {
        this.app.ports.ctrlZPressed.send(null);
      }
    });
  }

  stop() {
    document.removeEventListener("keydown", this.eventHandler);
  }

  onCtrlZ(callback) {
    this.eventHandler = document.addEventListener("keydown", ev => {
      if (ev.ctrlKey && ev.keyCode == 90) {
        callback();
      }
    });
  }

  noTrixContentTwice() {
    let current = this.getTrixContent();
    let previous = this._previousCall;

    if (previous === undefined) {
      this._previousCall = this.getTrixContent();
      return !current;
    }

    if (!current && !previous) {
      this._previousCall = this.getTrixContent();
      return true;
    }

    this._previousCall = this.getTrixContent();
    return false;
  }

  getTrixContent() {
    let trix = document.querySelector("trix-editor");
    if (trix) {
      return trix.value;
    }
  }

  hasTrix() {
    return document.querySelector("trix-editor") != null;
  }
}
