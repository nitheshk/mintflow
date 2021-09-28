import { LightningElement, api } from "lwc";

export default class WizardUtils extends LightningElement {
  @api wizardType;
  @api steps;
  @api current;

  handleHeaderSlot(event) {
    this.dispatchEvent(
      new CustomEvent("progressclick", {
        detail: event.detail
      })
    );
  }
}
