import { LightningElement } from "lwc";
import lwcResource from "@salesforce/resourceUrl/LWCResource";

export default class OnlineContactUs extends LightningElement {
  backgroundUrl = lwcResource + "/img/contactUs.PNG";

  renderedCallback() {
    this.template
      .querySelector(".backImage")
      .style.setProperty("--my-back", `url("${this.backgroundUrl}")`);
  }
}
