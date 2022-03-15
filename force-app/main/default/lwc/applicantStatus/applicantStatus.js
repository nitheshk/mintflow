import { LightningElement, api } from "lwc";

export default class ApplicantStatus extends LightningElement {
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
}
