import { LightningElement, track, api } from "lwc";
import { customDispatchEvent } from "c/generalUtils";
import lwcResource from "@salesforce/resourceUrl/LWCResource";

export default class DealerRegVerificationPage extends LightningElement {
  @api currentStep;
  @api leadData;
  @track mobileNumber;
  isRendered = false;
  bannerUrl = lwcResource + "/img/otp_banner.png";

  renderedCallback() {
    this.template
      .querySelector(".otp-banner")
      .style.setProperty("--my-banner", `url("${this.bannerUrl}")`);
    if (this.leadData && !this.isRendered) {
      this.mobileNumber = this.leadData.MobilePhone
        ? this.leadData.MobilePhone.slice(
            0,
            this.leadData.MobilePhone.slice.length - 6
          )
        : null;
      this.mobileNumber = this.mobileNumber ? this.mobileNumber + "****" : null;
      this.isRendered = true;
    }
  }
  //handleNext
  handleNext() {
    if (!this.leadData) {
      return;
    }
    customDispatchEvent(this, "steptwo", {
      currentStep: ++this.currentStep,
      result: this.leadData
    });
  }
}
