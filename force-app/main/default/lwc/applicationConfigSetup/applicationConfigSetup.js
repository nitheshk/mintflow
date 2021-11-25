import { LightningElement, wire, track, api } from "lwc";
import fetchConfigValues from "@salesforce/apex/LwcCustomController.fetchConfigValues";
import updateConfigValues from "@salesforce/apex/LwcCustomController.updateConfigValues";
import deleteLogs from "@salesforce/apex/Logger.deleteLogs";
import utils from "c/generalUtils";
export default class applicationCongifgSetup extends LightningElement() {
  // deleteLog
  @track configData = {};
  @track showSpinner = true;

  @wire(fetchConfigValues)
  AccountRecord({ data, error }) {
    if (data) {
      console.log("data:", JSON.stringify(data));
      if (data.status === 200) {
        this.configData = JSON.parse(data.data);
      }
      this.showSpinner = false;
    } else if (error) {
      console.log("error fetchConfigValues: " + error.body.message);
      this.showSpinner = false;
    }
  }
  handleChange(event) {
    var targetElement = event.target;
    this.configData[targetElement.dataset.fieldname] = targetElement.value;
    console.log(targetElement.value);
    console.log(event);
  }
  handleCheckboxChange(event) {
    var targetElement = event.target;
    if (this.configData[targetElement.dataset.fieldname] === true)
      this.configData[targetElement.dataset.fieldname] = false;
    else this.configData[targetElement.dataset.fieldname] = true;
  }

  handleSave() {
    if (
      utils.checkAllValidations(this.template.querySelectorAll(".validation"))
    ) {
      this.showSpinner = true;
      console.log(JSON.stringify(this.configData));
      updateConfigValues({
        params: {
          configData: JSON.stringify(this.configData)
        }
      })
        .then((result) => {
          if (result.status === 200) {
            this.accountRecord = JSON.parse(JSON.stringify(result.data));
            utils.successMessage(this, "Saved!", "Success");
          } else {
            utils.errorMessage(this, "Error updating config", "Error");
          }
          this.showSpinner = false;
        })
        .catch((error) => {
          console.log("error " + JSON.stringify(error));
          utils.errorMessage(
            this,
            error.body.message,
            "Error creating Account"
          );
          this.showSpinner = false;
        });
    }
  }
  @api invoke() {
    deleteLogs()
      .then((result) => {
        if (result.status === 200) {
          utils.successMessage(this, "Log Deleted", "Success");
        }
      })
      .catch((error) => {
        console.log("Error : " + JSON.stringify(error));
        utils.errorMessage(this, error.body.message, "Error");
      });
  }
}
