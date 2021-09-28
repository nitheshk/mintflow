import { LightningElement, track, api } from "lwc";
import lwcResource from "@salesforce/resourceUrl/LWCResource";

export default class DealerRegistrationMainPage extends LightningElement {
  steps = [
    { label: "Start Page", value: 1 },
    { label: "Verification Page", value: 2 },
    { label: "Registration", value: 3 }
  ];
  @api wizardType;
  @track currentStep;
  @track leadData;
  backgroundUrl = lwcResource + "/img/darkside.png";
  arrowUrl = lwcResource + "/img/arrow.svg";
  logo = lwcResource + "/img/logo.png";
  bannerUrl = lwcResource + "/img/Group2.png";
  dealerUrl = lwcResource + "/img/loan-card.png";

  renderedCallback() {
    this.template
      .querySelector(".backImage")
      .style.setProperty("--my-back", `url("${this.backgroundUrl}")`);
    this.template
      .querySelector(".dealer-card")
      .style.setProperty("--my-dealer", `url("${this.dealerUrl}")`);

    if (!this.currentStep) {
      this.currentStep = 1;
    }
  }

  get isStepOne() {
    return this.currentStep === 1;
  }
  get isStepTwo() {
    return this.currentStep === 2;
  }
  get isStepThree() {
    return this.currentStep === 3;
  }

  handlePageChange(event) {
    if (event.detail) {
      this.currentStep = event.detail.currentStep;
      this.leadData = event.detail.result;
    }
  }
}
