import { LightningElement, api, wire, track } from "lwc";
import utils from "c/generalUtils";
import getPickListValues from "@salesforce/apex/LwcCustomController.fetchPickListValues";
import updateKycDecision from "@salesforce/apex/LwcCustomController.updateKycDecision";
import submitToCoreSystem from "@salesforce/apex/ApplicationController.submitToCoreSystem";
export default class ManualKycDecision extends LightningElement {
  @api objectApiName;
  @api recordId;
  @track collectedInfo = {};
  @track applicationStatus = [];
  @track applicantStatus = [];
  @track showApplicationTab = false;
  @track showApplicantTab = false;
  @track showSpinner = false;

  /**
   * Load Picklist value for components
   * @param {*} param
   */
  @wire(getPickListValues, {
    params: {
      mflow__Application__c: ["mflow__KYCStatus__c"],
      mflow__Applicant__c: ["mflow__KYCStatus__c"]
    }
  })
  PickListValues({ data, error }) {
    if (data) {
      if (data.status === 200) {
        this.applicationStatus = JSON.parse(data.data)?.mflow__Application__c.mflow__KYCStatus__c.filter(
          (item) => item.value === "Passed" || item.value === "Failed"
        );

        this.applicantStatus = JSON.parse(data.data)?.mflow__Applicant__c.mflow__KYCStatus__c.filter(
          (item) => item.value === "Passed" || item.value === "Failed"
        );
        if (this.objectApiName === "mflow__Application__c") {
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
    if (this.objectApiName === "mflow__Application__c") {
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
    if (utils.checkAllValidations(this.template.querySelectorAll(".validation"))) {
      if (this.objectApiName === "mflow__Application__c") {
        return this.updateApplicationKyc();
      } else if (this.objectApiName === "mflow__Applicant__c") {
        return this.updateApplicantKyc();
      }
    }
  }

  /**
   * updateApplicationKyc
   * @returns
   */
  async updateApplicationKyc() {
    try {
      this.showSpinner = true;
      let result = await updateKycDecision({
        params: {
          recordId: this.recordId,
          objectApiName: this.objectApiName,
          status: this.collectedInfo.status
        }
      });

      if (result.status != 200) {
        throw result.data;
      }

      utils.successMessage(this, "Kyc Status updated", "Success");
      let applicationData = JSON.parse(result.data);

      if (applicationData.mflow__Status__c != "Submitted") {
        this.showSpinner = false;
        utils.refreshLwcPage();
        return;
      }

      let result2 = await submitToCoreSystem({
        request: {
          applicationId: this.recordId
        }
      });

      if (result2.status === 200) {
        utils.successMessage(this, "Application Submitted", "Success");
        this.showSpinner = false;
        utils.refreshLwcPage();
      } else {
        throw result2.data;
      }
    } catch (error) {
      console.log("error : " + JSON.stringify(error));
      if (error?.data) {
        utils.errorMessage(this, error.data, "Error");
      } else {
        utils.errorMessage(this, "Something went Wrong", "Error");
      }
      this.showSpinner = false;
      utils.refreshLwcPage();
    }
  }

  /**
   * updateApplicationKyc
   */
  // async updateApplicationKyc() {
  //   this.showSpinner = true;
  //   updateKycDecision({
  //     params: {
  //       recordId: this.recordId,
  //       objectApiName: this.objectApiName,
  //       status: this.collectedInfo.status
  //     }
  //   })
  //     .then((result) => {
  //       console.log("result" + JSON.stringify(result));
  //       if (result.status === 200) {
  //         let applicationData = JSON.parse(result.data);
  //         utils.successMessage(this, "Kyc Status updated", "Success");
  //         if (applicationData.mflow__Status__c === "Submitted") {
  //           submitToCoreSystem({
  //             request: {
  //               applicationId: this.recordId
  //             }
  //           })
  //             .then((result2) => {
  //               if (result2.status === 200) {
  //                 utils.successMessage(this, "Application Submitted", "Success");
  //               } else {
  //                 utils.errorMessage(this, result2.data, "Error");
  //               }
  //               this.showSpinner = false;
  //               utils.refreshLwcPage();
  //             })
  //             .catch((error2) => {
  //               console.log("error : " + JSON.stringify(error2));
  //               this.showSpinner = false;
  //               utils.refreshLwcPage();
  //               utils.errorMessage(this, "Something went Wrong", "Error");
  //             });
  //         } else {
  //           this.showSpinner = false;
  //           utils.refreshLwcPage();
  //         }
  //       } else {
  //         utils.errorMessage(this, result.data, "Error");
  //         this.showSpinner = false;
  //         utils.refreshLwcPage();
  //       }
  //     })
  //     .catch((error) => {
  //       console.log("error : " + JSON.stringify(error));
  //       this.showSpinner = false;
  //       utils.errorMessage(this, "Something went Wrong", "Error");
  //     });
  // }

  /**
   * updateApplicantKyc
   */
  async updateApplicantKyc() {
    try {
      this.showSpinner = true;
      let result = await updateKycDecision({
        params: {
          recordId: this.recordId,
          objectApiName: this.objectApiName,
          status: this.collectedInfo.status
        }
      });

      if (result.status === 200) {
        utils.successMessage(this, "Status Updated", "Success");
      } else {
        utils.errorMessage(this, result.data, "Error");
      }
      this.showSpinner = false;
      utils.refreshLwcPage();
    } catch (error) {
      console.log("error : " + JSON.stringify(error));
      this.showSpinner = false;
      utils.errorMessage(this, "Something went Wrong", "Error");
    }
  }
}
