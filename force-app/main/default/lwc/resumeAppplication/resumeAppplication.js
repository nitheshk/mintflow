import { LightningElement, track, api, wire } from "lwc";
import utils from "c/generalUtils";
import fetchApplicants from "@salesforce/apex/LwcCustomController.readApplicationWithApplicants";
import sendEmail from "@salesforce/apex/LwcCustomController.sendResumeApplicationEmail";

export default class ResumeAppplication extends LightningElement {
  @api recordId;
  @track selectedId = [];
  @track selectedApplicant;
  @track showSpinner = false;
  @track applicants = [];
  @track message;
  @track disableButton = false;
  @wire(fetchApplicants, {
    applicationId: "$recordId"
  })
  fetchAllApplicants({ data, error }) {
    if (data) {
      if (data.status === 200) {
        this.applicants = JSON.parse(data.data);
      } else {
        console.log("error" + JSON.stringify(error));
      }
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
      utils.errorMessage(this, error.body.message, "Error fetching record");
    }
  }
  handleChange(event) {
    let targetElement = event.target;
    this.selectedApplicant = targetElement.options.find(
      (opt) => opt.value === event.detail.value
    ).label;
    this.selectedId = [];
    if (this.selectedApplicant === "All") {
      this.selectedId = JSON.parse(targetElement.value);
    } else {
      this.selectedId.push(targetElement.value);
    }
    this.message = "Selected " + this.selectedApplicant;
  }
  sendResumeEmail() {
    this.disableButton = true;
    if (
      utils.checkAllValidations(this.template.querySelectorAll(".validation"))
    ) {
      this.showSpinner = true;
      sendEmail({
        applicantIds: JSON.stringify(this.selectedId)
      })
        .then((result) => {
          if (result.status === 200) {
            this.disableButton = false;
            this.message = "Email sent to " + this.selectedApplicant;
            utils.successMessage(this, "Email sent");
          }
        })
        .catch((error) => {
          this.disableButton = false;
          console.log("error : " + JSON.stringify(error));
          utils.errorMessage(
            this,
            error.body.message,
            "Error on sending email"
          );
        });
    }
  }
}
