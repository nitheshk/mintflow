import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class ApplicantStatus extends NavigationMixin(LightningElement) {
  @api record;
  @api sObjectName;
  @api titleName;
  identityVerified = false;
  kycStatus = false;
  openModal = false;
  @track OOWText;
  renderedCallback() {
    if (this.record.mflow__IsPhoneNumberVerified__c != "Failed") {
      this.identityVerified = true;
    }
    if (this.record.mflow__KYCStatus__c === "Passed") {
      this.kycStatus = true;
    }

    if (
      this.record.mflow__OOWCorrectAnswers__c === undefined &&
      this.record.mflow__OOWTotalQuestions__c === undefined
    ) {
      this.OOWText = "Not answered any questions yet.";
    } else {
      this.OOWText =
        this.record.mflow__OOWCorrectAnswers__c +
        " out of " +
        this.record.mflow__OOWTotalQuestions__c +
        "  questions answered correctly.";
    }
  }

  handleNavigate() {
    this.openModal = true;
  }

  handleIdentityVerifyClose() {
    this.openModal = false;
  }
}
