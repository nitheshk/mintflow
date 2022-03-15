import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class ApplicantStatus extends NavigationMixin(LightningElement) {
  @api record;
  @api sObjectName;
  @api titleName;
  identityVerified = false;
  kycStatus = false;

  renderedCallback() {
    if (this.record.mflow__IsPhoneNumberVerified__c != "Failed") {
      this.identityVerified = true;
    }
    console.log("this.record.mflow__KYCStatus__c::" + this.record.mflow__KYCStatus__c);
    if (this.record.mflow__KYCStatus__c === "Passed") {
      this.kycStatus = true;
    }
  }

  handleNavigate() {
    this[NavigationMixin.Navigate]({
      type: "standard__component",
      attributes: {
        componentName: "c__identityVerificationReport"
      },
      state: {
        c__propertyValue: "500"
      }
    });
  }
}
