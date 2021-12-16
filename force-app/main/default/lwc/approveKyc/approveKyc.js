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

  get approvalTypes() {
    return [
      { label: "Update application", value: "UpdateApplication" },
      {
        label: "Update application and applicant",
        value: "updateApplicationAndApplicant"
      },
      {
        label: "Update application and primary",
        value: "updateApplicationAndPrimary"
      }
    ];
  }

  @wire(getPickListValues, {
    params: {
      Account: ["FinServ__Status__c"],
      mflow__Applicant__c: ["mflow__Status__c"]
    }
  })
  PickListValues({ data, error }) {
    if (data) {
      if (data.status === 200) {
        this.applicationStatus = JSON.parse(
          data.data
        ).Account.FinServ__Status__c.filter(
          (item) => item.value === "Approved" || item.value === "Rejected"
        );

        this.applicantStatus = JSON.parse(
          data.data
        ).mflow__Applicant__c.mflow__Status__c.filter(
          (item) => item.value === "Approved" || item.value === "Rejected"
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
        })
        .catch((error) => {
          console.log("error : " + JSON.stringify(error));
          utils.errorMessage(this, error.body.message, "Error");
        });
    }
  }
}
