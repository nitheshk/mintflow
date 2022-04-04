import { LightningElement, track, api, wire } from "lwc";
import utils from "c/generalUtils";
import resubmitApplication from "@salesforce/apex/LwcCustomController.resubmitApplication";
import lwcRecordLevelVisibility from "@salesforce/apex/LwcCustomController.lwcRecordLevelVisibility";
import { getRecord } from "lightning/uiRecordApi";
export default class ResubmitApplication extends LightningElement {
  @api objectApiName;
  @api recordId;
  @api filter;
  @track showSpinner = false;
  @track record;
  /**
   * refresh the current record data
   * @param {*} param0
   */
  @wire(getRecord, { recordId: "$recordId", fields: ["$objectApiName" + ".Id"] })
  getCurrentRecord({ data }) {
    if (data) {
      lwcRecordLevelVisibility({
        params: {
          recordId: this.recordId,
          objectApiName: this.objectApiName,
          filter: this.filter
        }
      }).then((result) => {
        if (result.status === 200) {
          this.record = JSON.parse(result.data);
        } else {
          this.record = null;
        }
      });
    }
  }

  /**
   * Resubmit
   */
  Resubmit() {
    this.showSpinner = true;
    resubmitApplication({
      applicationId: this.recordId
    })
      .then((result) => {
        if (result.status === 200) {
          utils.successMessage(this, "Application added to queue");
        } else {
          utils.errorMessage(this, result.data, "Error");
        }
        this.showSpinner = false;
        utils.refreshLwcPage();
      })
      .catch((error) => {
        this.showSpinner = false;
        console.log("error : " + JSON.stringify(error));
        utils.errorMessage(this, "Something went Wrong", "Error");
      });
  }
}
