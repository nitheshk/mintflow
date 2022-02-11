import { LightningElement, track } from "lwc";
import utils from "c/generalUtils";
import authorize from "@salesforce/apex/LwcCustomController.authorizeCustomer";

export default class CustomerResumeApplication extends LightningElement {
  @track applicantData = {};
  @track isAuthenticated = false;
  @track applications = [];
  handleChange(event) {
    var targetElement = event.target;
    this.applicantData[targetElement.dataset.fieldname] = targetElement.value;
    console.log(this.isAuthenticated);
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
            console.log(result);
            this.isAuthenticated = true;
            console.log(this.isAuthenticated);
            this.applications = result.data.filter(
              (item) => item.FinServ__Status__c === "Abandoned"
            );
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
}
