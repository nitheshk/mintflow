import { LightningElement, track, api, wire } from "lwc";
import utils from "c/generalUtils";
import resubmitTheApplication from "@salesforce/apex/LwcCustomController.resubmitTheApplication";

export default class ResubmitApplication extends LightningElement {
  @track showSpinner = false;
  @track disableButton = false;
  @api recordId;
  Resubmit() {
    this.showSpinner = true;
    this.disableButton = true;
    resubmitTheApplication({
      applicationId: this.recordId
    })
      .then((result) => {
        if (result.status === 200) {
          utils.successMessage(this, "Application added to queue");
        }
        this.disableButton = false;
        utils.refreshLwcPage();
      })
      .catch((error) => {
        this.disableButton = false;
        console.log("error : " + JSON.stringify(error));
        utils.errorMessage(this, error.body.message, "Error");
      });
  }
}
