import { LightningElement, track, api, wire } from "lwc";
//controller
import readApplicationWithChild from "@salesforce/apex/LwcCustomController.readApplicationWithChild";

export default class Application360View extends LightningElement {
  @api recordId;
  @api applicationId;
  @track record;
  // @api statusInformation = "mflow__StatusInformation";

  @wire(readApplicationWithChild, {
    applicationId: "$recordId"
  })
  readData(result) {
    //console.log("recordId ::: " + JSON.stringify(this.recordId));
    if (result.data) {
      //console.log("result.data   : " + result.data);
      if (result.data.status === 200) {
        this.record = JSON.parse(result.data.data);
        //console.log("record ::: " + JSON.stringify(this.record));
      }
    } else if (result.error) {
      this.error = result.error;
      console.log("error : " + JSON.stringify(result.error));
    }
  }

  printApplication() {
    window.print();
  }
}
