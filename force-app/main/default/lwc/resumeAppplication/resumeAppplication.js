import { LightningElement, track, api, wire } from "lwc";
import utils from "c/generalUtils";
import fetchApplicants from "@salesforce/apex/LwcCustomController.readApplicationWithApplicants";

export default class ResumeAppplication extends LightningElement {
  @api recordId;
  @track applicants = [];

  get options() {
    return [
      { label: "New", value: "new" },
      { label: "In Progress", value: "inProgress" },
      { label: "Finished", value: "finished" }
    ];
  }

  @wire(fetchApplicants, {
    applicationId: "$recordId"
  })
  fetchAllApplicants({ data, error }) {
    if (data) {
      if (data.status === 200) {
        console.log("data =" + JSON.stringify(JSON.parse(data.data)));
        // this.applicants = data.data.Lead.Salutation;
      } else {
        console.log("error " + JSON.stringify(data));
      }
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
      utils.errorMessage(this, error.body.message, "Error fetching record");
    }
  }
}
