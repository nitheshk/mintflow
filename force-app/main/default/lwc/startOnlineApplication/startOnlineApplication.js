import { LightningElement, api } from "lwc";
import startApplication from "@salesforce/apex/ApplicationController.startApplication";
import utils from "c/generalUtils";
export default class StartOnlineApplication extends LightningElement {
  @api objectApiName;
  @api recordId;

  /**
   * @Description start application
   * @param {*} event
   */
  start(event) {
    startApplication({
      request: {
        header: JSON.stringify({
          recordId: this.recordId,
          sObjectName: this.objectApiName
        })
      }
    })
      .then((result) => {
        console.log("result:", JSON.stringify(result));
        if (result.status === 200) {
          window.open(result.data.url, "_blank");
        }
      })
      .catch((error) => {
        console.log("Error : " + JSON.stringify(error));
        utils.errorMessage(this, error.body.message, "Error");
      });
  }
}
