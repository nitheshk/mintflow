import { track } from "lwc";
import createEmployee from "@salesforce/apex/LWCDealerSiteController.createDealerEmployee";
import constants from "c/validationFormatUtils";
import utils from "c/generalUtils";

export default class FinInstEmployeeRegister extends constants {
  @track contactData = {};
  @track showEmployeeRegPage = true;
  @track showCompletionRegPage = false;

  handleChange(event) {
    var targetElement = event.target;
    this.contactData[targetElement.dataset.fieldname] = targetElement.value;
  }

  //handle Save
  handleSave() {
    if (
      utils.checkAllValidations(this.template.querySelectorAll(".validation"))
    ) {
      createEmployee({
        params: { contact: this.contactData }
      })
        .then((result) => {
          console.log("result : " + JSON.stringify(result));
          if (result.status === 200) {
            this.showEmployeeRegPage = false;
            this.showCompletionRegPage = true;
            utils.successMessage(this, "User Created", "Success");
          } else {
            utils.errorMessage(this, result.data.message, "Error");
          }
        })
        .catch((error) => {
          console.log("error : " + JSON.stringify(error));
          utils.errorMessage(this, error.body.message, "Error creating user");
        });
    }
  }

  HandleshowEmployeeRegPage() {
    this.contactData = {};
    this.showCompletionRegPage = false;
    this.showEmployeeRegPage = true;
  }

  //cancel event
  handleCancel() {
    this.contactData = {};
  }
}
