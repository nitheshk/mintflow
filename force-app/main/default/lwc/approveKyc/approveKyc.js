import { LightningElement, api, wire, track } from "lwc";
import utils from "c/generalUtils";
import getPickListValues from "@salesforce/apex/LwcCustomController.fetchPickListValues";

export default class ApproveKyc extends LightningElement {
  @api objectApiName;
  @api recordId;
  @track kycStatus = [];
  @track value = "initial";
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
    params: { Account: ["FinServ__KYCStatus__c"] }
  })
  PickListValues({ data, error }) {
    if (data) {
      if (data.status === 200) {
        console.log(JSON.parse(data.data));
        console.log(JSON.parse(data.data).Account);
        console.log(JSON.parse(data.data).Account.FinServ__KYCStatus__c);
        console.log("objectname =" + this.objectApiName);
        this.kycStatus = JSON.parse(data.data).Account.FinServ__KYCStatus__c;
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
}
