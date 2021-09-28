import { LightningElement, track, wire, api } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import fetchRecord from "@salesforce/apex/LWCDealerSiteController.fetchLeadAndSurvey";
import utils from "c/generalUtils";
import lwcResource from "@salesforce/resourceUrl/LWCResource";

export default class DealerRegStartPage extends LightningElement {
  @api currentStep;
  @track recordId;
  @track leadData;
  @track isRendered = false;
  @track isProgress = false;
  backgroundUrl = lwcResource + "/img/base.png";

  /**
   * @param {*} currentPageReference
   */
  // Fetch Record Id from Url
  @wire(CurrentPageReference)
  fetchUrlParameters(currentPageReference) {
    if (currentPageReference) {
      this.recordId = currentPageReference.state.id || null;
    }
  }

  renderedCallback() {
    this.template
      .querySelector(".back-image")
      .style.setProperty("--my-back", `url("${this.backgroundUrl}")`);
  }

  /**
   * Fetch dealer record
   * @param {*} param0
   */
  @wire(fetchRecord, {
    leadId: "$recordId",
    params: {
      isEncrypted: true,
      validateLink: true,
      templateName: "ignore"
    }
  })
  fetchDealerRecordResult({ data, error }) {
    if (data) {
      //console.log("result : " + JSON.stringify(data));
      if (data.status === 200) {
        this.leadData = data.data;
        if (this.leadData.Status === "Working - Contacted") {
          this.isProgress = true;
        }
      } else if (data.status === 500) {
        utils.errorMessage(this, data.data.message, "Error");
        this.leadData = null;
      } else {
        utils.errorMessage(
          this,
          "We are sorry, Unable to find your data",
          "Error"
        );
        this.leadData = null;
      }
      this.isRendered = true;
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
      this.leadData = null;
      utils.errorMessage(
        this,
        "We are sorry, Unable to find your data",
        "Error"
      );
      this.isRendered = true;
    }
  }

  /**
   * Load next component
   */
  handleNext() {
    if (!this.leadData) {
      return;
    }
    utils.customDispatchEvent(this, "stepone", {
      currentStep: ++this.currentStep,
      result: this.leadData
    });
  }
}
