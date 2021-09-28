import { LightningElement, api } from "lwc";

export default class SpinnerUtils extends LightningElement {
  @api visible = false;
  @api size = "large";
}
