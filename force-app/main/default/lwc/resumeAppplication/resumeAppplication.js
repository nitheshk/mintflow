import { LightningElement, track, api, wire } from "lwc";
import utils from "c/generalUtils";
import fetchApplicants from "@salesforce/apex/LwcCustomController.readApplicationWithApplicants";
import sendEmail from "@salesforce/apex/LwcCustomController.sendResumeApplicationEmail";

export default class ResumeAppplication extends LightningElement {
  @api recordId;
  @track selectedId = [];
  @track showSpinner = false;
  @track applicants = [];
  @wire(fetchApplicants, {
    applicationId: "$recordId"
  })
  fetchAllApplicants({ data, error }) {
    if (data) {
      if (data.status === 200) {
        this.applicants = JSON.parse(data.data);
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
    console.log(targetElement.options);
    this.selectedId = [];
    this.selectedId = targetElement.value.split(",");
  }
  sendResumeEmail() {
    if (
      utils.checkAllValidations(this.template.querySelectorAll(".validation"))
    ) {
      this.showSpinner = true;
      sendEmail({
        applicantIds: JSON.stringify(this.selectedId)
      }).then((result) => {
        if (result.status === 200) {
          utils.successMessage(this, "Email sent");
        }
      });
    }
  }
}
