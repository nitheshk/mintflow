import { LightningElement, api, wire, track } from "lwc";
import utils from "c/generalUtils";
import getPickListValues from "@salesforce/apex/LwcCustomController.fetchPickListValues";
export default class ApproveKyc extends LightningElement {
  @api objectApiName;
  @api recordId;
  @track applicationFields = {};
  @track applicantFields = {};
  @track applicationKycStatus = [];
  @track applicantKycStatus = [];
  @track showApplicationTab = false;
  @track showApplicantTab = false;

  get approvalTypes() {
    return [
      { label: "Update application", value: "UpdateApplication" },
      {
        label: "Update application and applicant ",
        value: "updateApplicationAndApplicant "
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
        this.applicationKycStatus = JSON.parse(
          data.data
        ).Account.FinServ__Status__c;
        this.applicantKycStatus = JSON.parse(
          data.data
        ).mflow__Applicant__c.mflow__Status__c;
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
      this.applicationFields[targetElement.dataset.fieldname] =
        targetElement.value;
      console.log(JSON.stringify(this.applicationFields));
    } else if (this.objectApiName === "mflow__Applicant__c") {
      this.applicantFields[targetElement.dataset.fieldname] =
        targetElement.value;
      console.log(JSON.stringify(this.applicantFields));
    }
  }
}
