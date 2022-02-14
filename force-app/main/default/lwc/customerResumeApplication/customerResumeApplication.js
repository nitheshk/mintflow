import { LightningElement, track } from "lwc";
import utils from "c/generalUtils";
import sendResumeEmail from "@salesforce/apex/LwcCustomController.sendResumeApplicationEmail";
import authorize from "@salesforce/apex/LwcCustomController.authorizeCustomer";

export default class CustomerResumeApplication extends LightningElement {
  @track applicantData = {};
  @track isAuthenticated = false;
  @track applications = [];
  @track applicationStatus = [];
  @track showSpinner = false;
  @track selectedApplicant = [];
  handleChange(event) {
    var targetElement = event.target;
    this.applicantData[targetElement.dataset.fieldname] = targetElement.value;
    console.log(this.isAuthenticated);
  }
  handleCancel() {
    this.applicantData = {};
  }
  handleSubmit() {
    if (
      utils.checkAllValidations(this.template.querySelectorAll(".validation"))
    ) {
      this.showSpinner = true;
      authorize({
        params: { applicant: this.applicantData }
      })
        .then((result) => {
          if (result.status === 200) {
            this.isAuthenticated = true;
            this.applications = JSON.parse(result.data)?.filter(
              (item) =>
                item.FinServ__Status__c === "Abandoned" ||
                item.FinServ__Status__c === "In Progress"
            );

            this.applications.forEach((app) => {
              app.mflow__Applicants__r.forEach((element) => {
                if (
                  element.mflow__LastFourDigitsofSSN__c ===
                    this.applicantData.mflow__LastFourDigitsofSSN__c &&
                  element.mflow__LastName__c ===
                    this.applicantData.mflow__LastName__c &&
                  element.mflow__Email__c === this.applicantData.mflow__Email__c
                ) {
                  if (element.mflow__ApplicantType__c === "Primary") {
                    app.isPrimaryLoggedIn = true;
                    element.isPrimaryOrJoint = true;
                  } else if (element.mflow__ApplicantType__c === "Joint") {
                    app.isPrimaryLoggedIn = false;
                    element.isPrimaryOrJoint = true;
                  } else {
                    element.isPrimaryOrJoint = false;
                  }
                }
              });
            });
            console.log(this.applications);
          } else {
            utils.errorMessage(
              this,
              result.data.message,
              "Please enter correct details"
            );
          }
          this.showSpinner = false;
        })
        .catch((error) => {
          console.log("error : " + error);
          utils.errorMessage(this, error.body.message, "Error");
          this.showSpinner = false;
        });
    }
  }
  handleResume(event) {
    console.log("triggered");
    var targetElement = event.target;
    console.log(targetElement.dataset.fieldname);
    this.selectedApplicant.push(targetElement.dataset.fieldname);
    console.log(JSON.stringify(this.selectedApplicant));

    // this.showSpinner = true;
    // this.disableButton = true;
    sendResumeEmail({
      request: {
        data: JSON.stringify(this.selectedApplicant)
      }
    })
      .then((result) => {
        if (result.status === 200) {
          console.log(result);
          utils.successMessage(this, "Email sent to Applicant", "Success");
        }
        // this.disableButton = false;
      })
      .catch((error) => {
        // this.disableButton = false;
        console.log("error : " + JSON.stringify(error));
        utils.errorMessage(this, error.body.message, "Error");
      });
  }
}
