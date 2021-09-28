import { track, api, wire } from "lwc";
import utils from "c/generalUtils";
import constants from "c/validationFormatUtils";
import getPickListValues from "@salesforce/apex/LWCDealerSiteController.fetchPickListValues";
export default class DealerRegFinancialAccountInformation extends constants {
  @api dealerRecord;
  @track dealerRecordEdited = {};
  @api currentStep;
  @track isRendered = false;
  @track industry = [];

  //renderedCallback
  renderedCallback() {
    if (this.dealerRecord && !this.isRendered) {
      this.isRendered = true;
    }
  }

  // Dispatch dealer record value and current step on previous event in financial account information page
  handlePrev() {
    utils.customDispatchEvent(this, "dealerfinancialaccountinfochange", {
      collectedInfo: this.dealerRecordEdited,
      currentStep: --this.currentStep
    });
  }

  // Dispatch dealer record value and current step on next event in contactinformation page
  handleNext() {
    if (
      utils.checkAllValidations(this.template.querySelectorAll(".validation"))
    ) {
      utils.customDispatchEvent(this, "dealerfinancialaccountinfochange", {
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

  @wire(getPickListValues, {
    params: { Lead: ["Industry"] }
  })
  PickListValues({ data, error }) {
    if (data) {
      if (data.status === 200) {
        this.industry = data.data.Lead.Industry;
      } else {
        console.log("error " + JSON.stringify(data));
      }
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
      utils.errorMessage(this, error.body.message, "Error fetching record");
    }
  }
}
