import { LightningElement, api } from "lwc";

export default class ApplicantStatus extends LightningElement {
  @api record;
  @api sObjectName;
  @api titleName;
  identityVerified = false;

  renderedCallback() {
    if (this.record.mflow__IsPhoneNumberVerified__c != "Failed") {
      this.identityVerified = true;
    }
  }
}
