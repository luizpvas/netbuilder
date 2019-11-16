import "../css/app.css";
import "./html-content-editor";
import "./html-code-editor";
import "./html-content";
import CtrlZ from "./ctrlz";
import * as dependencies from "./dependencies";
import { Elm } from "../elm/Main.elm";

const MOVING_ANIMATION_DURATION = 300;

class NetBuilderEditor extends HTMLElement {
  connectedCallback() {
    dependencies.ensureAnimeJSLoaded(() => {
      let app = Elm.Main.init({
        node: this,
        flags: null
      });

      this.ctrlZ = new CtrlZ(app);
      this.ctrlZ.start();

      app.ports.startMovingContainerDown.subscribe(containerId => {
        requestAnimationFrame(() => {
          let allContainers = Array.from(
            document.querySelectorAll(".container")
          );

          let allContainersIds = allContainers.map(c => c.id);

          let movingDownIndex = allContainersIds.indexOf(containerId);
          let movingUpIndex = movingDownIndex + 1;

          let movingDown = allContainers[movingDownIndex];
          let movingUp = allContainers[movingUpIndex];

          runMoveAnimation(movingDown, movingUp, () => {
            app.ports.movingDownFinished.send(parseInt(containerId));
          });
        });
      });

      app.ports.startMovingContainerUp.subscribe(containerId => {
        requestAnimationFrame(() => {
          let allContainers = Array.from(
            document.querySelectorAll(".container")
          );

          let allContainersIds = allContainers.map(c => c.id);

          let movingUpIndex = allContainersIds.indexOf(containerId);
          let movingDownIndex = movingUpIndex - 1;

          let movingUp = allContainers[movingUpIndex];
          let movingDown = allContainers[movingDownIndex];

          runMoveAnimation(movingDown, movingUp, () => {
            app.ports.movingUpFinished.send(parseInt(containerId));
          });
        });
      });
    });
  }

  disconnectedCallback() {
    console.log("disconnected!");
  }
}

function runMoveAnimation(movingDown, movingUp, callback) {
  let movingDownRect = movingDown.parentNode.getBoundingClientRect();
  let movingUpRect = movingUp.parentNode.getBoundingClientRect();

  anime({
    targets: movingDown,
    translateY: movingUpRect.height,
    duration: MOVING_ANIMATION_DURATION,
    easing: "linear"
  });

  anime({
    targets: movingUp,
    translateY: -movingDownRect.height,
    duration: MOVING_ANIMATION_DURATION,
    easing: "linear"
  });

  setTimeout(() => {
    callback();

    requestAnimationFrame(() => {
      movingDown.style.transform = "";
      movingUp.style.transform = "";
    });
  }, MOVING_ANIMATION_DURATION + 100);
}

customElements.define("netbuilder-editor", NetBuilderEditor);
