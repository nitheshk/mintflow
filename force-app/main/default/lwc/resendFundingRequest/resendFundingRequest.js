import { LightningElement, api, track } from "lwc";
import utils from "c/generalUtils";
import sendEmail from "@salesforce/apex/LwcCustomController.resendFundingRequest";

export default class ResendFundingRequest extends LightningElement {
  @api objectApiName;
  @api recordId;
  @track disableButton = false;
  sendFundingEmail() {
    this.showSpinner = true;
    this.disableButton = true;
    sendEmail({
      applicantionId: this.recordId
    })
      .then((result) => {
        this.disableButton = false;
        if (result.status === 200) {
          utils.successMessage(this, "Email sent to Succesfully");
        }
      })
      .catch((error) => {
        this.disableButton = false;
        console.log("error : " + JSON.stringify(error));
        utils.errorMessage(this, error.body.message, "Error on sending email");
      });
  }
}
