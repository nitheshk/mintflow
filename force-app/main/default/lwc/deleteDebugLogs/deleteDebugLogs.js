import { LightningElement, api } from "lwc";
import deleteLogs from "@salesforce/apex/Logger.deleteLogs";
import utils from "c/generalUtils";
export default class DeleteDebugLogs extends LightningElement {
  /**
   * @Description delete logs
   */
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
