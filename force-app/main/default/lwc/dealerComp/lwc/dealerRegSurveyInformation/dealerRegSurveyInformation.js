import { LightningElement, api, track } from "lwc";
import { customDispatchEvent, errorMessage } from "c/generalUtils";
import surveyTemplates from "@salesforce/apex/LWCDealerSiteController.fetchSurveyTemplates";
import surveyUtils from "c/surveyUtils";

export default class DealerRegSurveyInformation extends LightningElement {
  @api dealerRecord;
  @track dealerRecordEdited = {};
  @api currentStep;
  @track isRendered = false;
  @track dealerSurvey = [];

  //renderedCallback
  renderedCallback() {
    if (this.dealerRecord && !this.isRendered) {
      if (this.dealerRecord?.dau01__Surveys__r?.records) {
        this.dealerSurvey = JSON.parse(
          JSON.stringify(this.dealerRecord.dau01__Surveys__r.records)
        );
        surveyUtils.initSurvey(this.dealerSurvey).then((result) => {
          console.log(result);
          this.isRendered = true;
        });
      } else {
        surveyTemplates({ params: { templateName: "DealerSurvey" } })
          .then((data) => {
            this.dealerSurvey = JSON.parse(JSON.stringify(data.data));
            surveyUtils.initSurvey(this.dealerSurvey).then((result) => {
              console.log(result);
              this.isRendered = true;
            });
          })
          .catch((error) => {
            console.log(error);
            errorMessage(this, error.body.message, "Error creating record");
          });
      }
    }
  }

  handleChange(event) {
    surveyUtils.surveyHandleChange(this.dealerSurvey, event);
  }

  // Dispatch dealer record value and current step on previous event in financial account information page
  handlePrev() {
    customDispatchEvent(this, "dealersurveyinfochange", {
      collectedInfo: this.dealerRecordEdited,
      currentStep: --this.currentStep
    });
  }

  // Dispatch dealer record value and current step on next event in contactinformation page
  handleNext(event) {
    let nextStep = this.currentStep + 1;
    let dealerRecordEditedCopy = JSON.parse(
      JSON.stringify(this.dealerRecordEdited)
    );
    dealerRecordEditedCopy.dau01__Surveys__r = {
      totalSize: this.dealerSurvey.length,
      done: true,
      records: this.dealerSurvey
    };

    customDispatchEvent(this, "dealersurveyinfonext", {
      collectedInfo: dealerRecordEditedCopy,
      currentStep: nextStep
    });
  }
}
