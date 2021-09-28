import { LightningElement, api } from "lwc";

export default class ProgressBarUtils extends LightningElement {
  @api steps;
  @api type;
  @api currentStep;

  /**
   * wizard type indicator
   */
  get isIndicator() {
    return this.type === "indicator";
  }

  /**
   * wizard type bar
   */
  get isBar() {
    return this.type === "bar";
  }

  /**
   * wizard type path
   */
  get isPath() {
    return this.type === "path";
  }

  /**
   *  get prograa bar value in percentage
   */
  get progress() {
    let position = 0;
    let i = 0;
    this.steps.forEach((step) => {
      if (step.value === this.currentStep) {
        position = i;
      }
      i++;
    });

    return (100 * position) / (this.steps.length - 1);
  }

  /**
   * pass click event to parent component
   * @param {*} event
   */
  handleOnStepClick(event) {
    this.dispatchEvent(
      new CustomEvent("headerslot", {
        detail: event.target.value
      })
    );
  }
}
