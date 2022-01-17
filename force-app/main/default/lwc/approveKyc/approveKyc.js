import { LightningElement, api, wire, track } from "lwc";
import utils from "c/generalUtils";
import getPickListValues from "@salesforce/apex/LwcCustomController.fetchPickListValues";
import updateKycDecision from "@salesforce/apex/LwcCustomController.updateKycDecision";
export default class ApproveKyc extends LightningElement {
  @api objectApiName;
  @api recordId;
  @track collectedInfo = {};
  @track applicationStatus = [];
  @track applicantStatus = [];
  @track showApplicationTab = false;
  @track showApplicantTab = false;
  @track showSpinner = false;

  get approvalTypes() {
    return [
      { label: "Approve Application", value: "ApproveApplication" },
      {
        label: "Approve Application And Applicants",
        value: "ApproveApplicationAndApplicants"
      }
    ];
  }

  /**
   * Load Picklist value for components
   * @param {*} param
   */
  @wire(getPickListValues, {
    params: {
      Account: ["FinServ__KYCStatus__c"],
      mflow__Applicant__c: ["mflow__KYCStatus__c"]
    }
  })
  PickListValues({ data, error }) {
    if (data) {
      if (data.status === 200) {
        this.applicationStatus = JSON.parse(
          data.data
        )?.Account.FinServ__KYCStatus__c.filter(
          (item) => item.value === "Passed" || item.value === "Failed"
        );

        this.applicantStatus = JSON.parse(
          data.data
        ).mflow__Applicant__c.mflow__KYCStatus__c.filter(
          (item) => item.value === "Passed" || item.value === "Failed"
        );
        if (this.objectApiName === "Account") {
          this.showApplicationTab = true;
        } else if (this.objectApiName === "mflow__Applicant__c") {
          this.showApplicantTab = true;
        }
      } else {
        console.log("error " + JSON.stringify(data));
      }
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
      utils.errorMessage(this, error.body.message, "Error fetching record");
    }
  }

  /**
   * Change in the Event of status picklist values
   * @param {*} event
   */
  handleChange(event) {
    let targetElement = event.target;
    if (this.objectApiName === "Account") {
      this.collectedInfo[targetElement.dataset.fieldname] = targetElement.value;
      console.log(JSON.stringify(this.collectedInfo));
    } else if (this.objectApiName === "mflow__Applicant__c") {
      this.collectedInfo[targetElement.dataset.fieldname] = targetElement.value;
      console.log(JSON.stringify(this.collectedInfo));
    }
  }

  /**
   * update kyc status of application and applicants
   */
  updateStatus() {
    if (
      utils.checkAllValidations(this.template.querySelectorAll(".validation"))
    ) {
      this.showSpinner = true;
      updateKycDecision({
        params: {
          recordId: this.recordId,
          objectApiName: this.objectApiName,
          status: this.collectedInfo.status,
          approvalType: this.collectedInfo.approvalType
        }
      })
        .then((result) => {
          console.log("result" + JSON.stringify(result));
          this.showSpinner = false;
          utils.successMessage(this, "Status Updated", "Success");
          utils.refreshLwcPage();
        })
        .catch((error) => {
          console.log("error : " + JSON.stringify(error));
          this.showSpinner = false;
          utils.errorMessage(this, error.body.message, "Error");
        });
    }
  }
}
