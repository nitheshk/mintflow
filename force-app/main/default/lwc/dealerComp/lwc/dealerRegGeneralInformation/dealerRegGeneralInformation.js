import { api, track, wire } from "lwc";
import constants from "c/validationFormatUtils";
import utils from "c/generalUtils";
import getPickListValues from "@salesforce/apex/LWCDealerSiteController.fetchPickListValues";
export default class DealerRegGeneralInformation extends constants {
  @api dealerRecord;
  @track dealerRecordEdited = {};
  @api currentStep;
  @track isRendered = false;
  @track salutation = [];

  renderedCallback() {
    if (this.dealerRecord && !this.isRendered) {
      this.isRendered = true;
    }
  }
  // Dispatch dealer record value and current step on next event in contactinformation page
  handleNext() {
    if (
      utils.checkAllValidations(this.template.querySelectorAll(".validation"))
    ) {
      utils.customDispatchEvent(this, "dealergeneralinfochange", {
        collectedInfo: this.dealerRecordEdited,
        currentStep: ++this.currentStep
      });
    }
  }

  handleChange(event) {
    let targetElement = event.target;
    this.dealerRecordEdited[targetElement.dataset.fieldname] =
      targetElement.value;
  }

  @wire(getPickListValues, {
    params: { Lead: ["Salutation"] }
  })
  PickListValues({ data, error }) {
    if (data) {
      if (data.status === 200) {
        this.salutation = data.data.Lead.Salutation;
      } else {
        console.log("error " + JSON.stringify(data));
      }
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
      utils.errorMessage(this, error.body.message, "Error fetching record");
    }
  }
}
