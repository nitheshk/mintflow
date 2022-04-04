import { LightningElement, track, api, wire } from "lwc";
import utils from "c/generalUtils";
import { getRecord } from "lightning/uiRecordApi";
import fetchApplication from "@salesforce/apex/LwcCustomController.readApplicationForResume";
import sendResumeEmail from "@salesforce/apex/LwcCustomController.sendResumeApplicationEmail";

export default class ResumeAppplication extends LightningElement {
  @api objectApiName;
  @api recordId;
  @api filter;
  @track record;
  @track applicantNames;
  @track selectedApplicant = [];
  @track showSpinner = false;

  /**
   * refresh the current record data
   * @param {*} param0
   */
  @wire(getRecord, { recordId: "$recordId", fields: ["$objectApiName" + ".Id"] })
  getCurrentRecord({ data, error }) {
    if (data) {
      fetchApplication({
        params: {
          recordId: this.recordId,
          objectApiName: this.objectApiName,
          filter: this.filter
        }
      }).then((result) => {
        if (result.status === 200) {
          this.record = JSON.parse(result.data);

          let applicantNames = [{ label: "All", value: "All" }];
          let applicants = this.record.mflow__Applicants__r;
          // eslint-disable-next-line guard-for-in
          for (let key in applicants) {
            applicantNames.push({
              label: `${applicants[key].mflow__ApplicantName__c} (${applicants[key].RecordType.Name}) `,
              value: applicants[key].Id
            });
          }
          this.applicantNames = applicantNames;
        } else {
          this.record = null;
        }
      });
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
    if (utils.checkAllValidations(this.template.querySelectorAll(".validation"))) {
      this.showSpinner = true;
      sendResumeEmail({
        request: {
          data: JSON.stringify(this.selectedApplicant)
        }
      })
        .then((result) => {
          if (result.status === 200) {
            utils.successMessage(this, "Email sent to Applicant", "Success");
          }
          this.showSpinner = false;
        })
        .catch((error) => {
          this.showSpinner = false;
          console.log("error : " + JSON.stringify(error));
          utils.errorMessage(this, error.body.message, "Error");
        });
    }
  }
}
