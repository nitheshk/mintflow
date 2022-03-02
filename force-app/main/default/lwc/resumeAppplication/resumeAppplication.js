import { LightningElement, track, api, wire } from "lwc";
import utils from "c/generalUtils";
import fetchApplicants from "@salesforce/apex/LwcCustomController.readApplicationForResume";
import sendResumeEmail from "@salesforce/apex/LwcCustomController.sendResumeApplicationEmail";
import sendFundingEmail from "@salesforce/apex/LwcCustomController.resendFundingRequest";

export default class ResumeAppplication extends LightningElement {
  @api recordId;
  @track application;

  @track fundingFlow = false;
  @track applicationFlow = false;

  @track applicantNames;

  @track selectedApplicant = [];
  @track showSpinner = false;
  @track disableButton = false;

  /**
   * fetch applicants
   * @param {*} param0
   */
  @wire(fetchApplicants, {
    applicationId: "$recordId"
  })
  fetchAllApplicants({ data, error }) {
    if (data) {
      if (data.status === 200) {
        this.application = JSON.parse(data.data);
        if (this.application.mflow__FlowType__c === "ApplicationFlow") {
          this.applicationFlow = true;
        } else if (this.application.mflow__FlowType__c === "FundingFlow") {
          this.fundingFlow = true;
        }
        let applicantNames = [{ label: "All", value: "All" }];
        let applicants = this.application.mflow__ApplicantsTemp__r;
        // eslint-disable-next-line guard-for-in
        for (let key in applicants) {
          applicantNames.push({
            label: `${applicants[key].mflow__ApplicantName__c} (${applicants[key].RecordType.Name}) `,
            value: applicants[key].Id
          });
        }
        this.applicantNames = applicantNames;
      } else {
        console.log("error" + JSON.stringify(error));
      }
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
      utils.errorMessage(this, error.body.message, "Error");
    }
  }

  /**
   * Applicant Names Changed
   * @param {'*'} event
   */
  handleChange(event) {
    this.selectedApplicant = [];
    if (event.detail.value === "All") {
      this.applicantNames
        .filter((item) => {
          return item.value !== "All";
        })
        .forEach((key) => {
          this.selectedApplicant.push(key.value);
        });
    } else {
      this.applicantNames
        .filter((item) => {
          return item.value === event.detail.value;
        })
        .forEach((key) => {
          this.selectedApplicant.push(key.value);
        });
    }
  }

  /**
   * Send Resume Link
   */
  sendResumeEmail() {
    if (
      utils.checkAllValidations(this.template.querySelectorAll(".validation"))
    ) {
      this.showSpinner = true;
      this.disableButton = true;
      sendResumeEmail({
        request: {
          data: JSON.stringify(this.selectedApplicant)
        }
      })
        .then((result) => {
          if (result.status === 200) {
            utils.successMessage(this, "Email sent to Applicant", "Success");
          }
          this.disableButton = false;
        })
        .catch((error) => {
          this.disableButton = false;
          console.log("error : " + JSON.stringify(error));
          utils.errorMessage(this, error.body.message, "Error");
        });
    }
  }

  /**
   * sendFundingEmail
   */
  sendFundingEmail() {
    this.showSpinner = true;
    this.disableButton = true;
    sendFundingEmail({
      request: {
        data: this.recordId
      }
    })
      .then((result) => {
        this.disableButton = false;
        if (result.status === 200) {
          utils.successMessage(this, "Email sent to Succesfully", "Success");
        }
      })
      .catch((error) => {
        this.disableButton = false;
        console.log("error : " + JSON.stringify(error));
        utils.errorMessage(this, error.body.message, "Error");
      });
  }
}
