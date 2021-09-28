import { track, api } from "lwc";
import utils from "c/generalUtils";
import constants from "c/validationFormatUtils";
export default class DealerRegContactInformation extends constants {
  @api dealerRecord;
  @track dealerRecordEdited = {};
  @api currentStep;
  @track isRendered = false;

  //renderedCallback
  renderedCallback() {
    if (this.dealerRecord && !this.isRendered) {
      this.isRendered = true;
    }
  }
  // Dispatch dealer record value and current step on previous event in contact information page
  handlePrev() {
    utils.customDispatchEvent(this, "dealercontactinfochange", {
      collectedInfo: this.dealerRecordEdited,
      currentStep: --this.currentStep
    });
  }

  // Dispatch dealer record value and current step on next event in contact information page
  handleNext() {
    if (
      utils.checkAllValidations(this.template.querySelectorAll(".validation"))
    ) {
      utils.customDispatchEvent(this, "dealercontactinfochange", {
        collectedInfo: this.dealerRecordEdited,
        currentStep: ++this.currentStep
      });
    }
  }

  /**
   *
   * @param {*} event
   */
  handleChange(event) {
    var targetElement = event.target;
    this.dealerRecordEdited[targetElement.dataset.fieldname] =
      targetElement.value;
  }
}
