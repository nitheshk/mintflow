import { track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import createUser from "@salesforce/apex/LWCFinancialInstituteSiteController.createFinInstEmployeeAccount";
import constants from "c/validationFormatUtils";
import utils from "c/generalUtils";

export default class FinInstEmployeeRegister extends NavigationMixin(
  constants
) {
  @track contactData = {};
  isEmployeeCreated = false;
  @track showSpinner = false;

  handleChange(event) {
    var targetElement = event.target;
    this.contactData[targetElement.dataset.fieldname] = targetElement.value;
  }

  handleSave() {
    if (
      utils.checkAllValidations(this.template.querySelectorAll(".validation"))
    ) {
      this.showSpinner = true;
      createUser({
        params: { contact: this.contactData }
      })
        .then((result) => {
          if (result.status === 200) {
            this.isEmployeeCreated = true;
            utils.successMessage(this, "Employee Registered", "Success");
          } else {
            utils.errorMessage(
              this,
              result.data.message,
              "Error on contact creation, May be an employee with same email address exists"
            );
          }
          this.showSpinner = false;
        })
        .catch((error) => {
          console.log("error : " + error);
          utils.errorMessage(
            this,
            error.body.message,
            "Error creating employee data"
          );
          this.showSpinner = false;
        });
    }
  }

  handleCancel() {
    this.contactData = {};
  }

  HandleshowEmployeeRegPage() {
    this.contactData = {};
    this.isEmployeeCreated = false;
  }
}
