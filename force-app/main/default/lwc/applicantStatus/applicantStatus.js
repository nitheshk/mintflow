import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getBaseUrl from "@salesforce/apex/ApplicantController.getBaseURL";

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

  handleIdentityVerifyClose() {
    this.openModal = false;
  }

  handleKYCNavigate() {
    console.log("baseurl test");
    var data;
    getBaseUrl({
      request: {}
    })
      .then((result) => {
        if (result.status === 200) {
          data = JSON.parse(result.data);
          console.log("baseurl::" + JSON.stringify(data));
          var siteUrl = data + "/apex/mflow__AlloyKYCReport?id=" + this.record.Id;
          this[NavigationMixin.Navigate](
            {
              type: "standard__webPage",
              attributes: {
                url: siteUrl
              }
            },
            false
          );
        }
      })
      .catch((error) => {
        console.log("Error : " + JSON.stringify(error));
        utils.errorMessage(this, error.body.message, "Error");
      });
  }

  handleNavigate() {
    this.openModal = true;
  }
}
