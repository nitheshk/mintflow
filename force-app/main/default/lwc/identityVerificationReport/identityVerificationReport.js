import { LightningElement, api, wire, track } from "lwc";
import fetchReportData from "@salesforce/apex/LwcCustomController.fetchOOWReportData";
import utils from "c/generalUtils";
export default class IdentityVerificationReport extends LightningElement {
  @api recordId;
  @track itemline;
  @track flowData;
  @track items;
  @api openModal;

  @wire(fetchReportData, {
    applicationId: "$recordId"
  })
  wiredValues({ error, data }) {
    if (data) {
      this.flowData = JSON.parse(data.data);
      console.log(" this.flowData" + JSON.stringify(this.flowData));
      this.items = JSON.parse(JSON.stringify(this.flowData));
    } else if (error) {
      window.console.log(error);
    }
  }
  closeModal() {
    console.log("close called");
    utils.customDispatchEvent(this, "identityverifyclose", {});
  }
}
