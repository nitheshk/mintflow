import { LightningElement, track, wire, api } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import updateLeadAndSurveyRecords from "@salesforce/apex/LWCDealerSiteController.updateLeadAndSurveyRecords";
import fetchRecord from "@salesforce/apex/LWCDealerSiteController.fetchLeadAndSurvey";
import utils from "c/generalUtils";
import lwcResource from "@salesforce/resourceUrl/LWCResource";

export default class DealerRegister extends LightningElement {
  steps = [
    { label: "Personal Information", value: 1 },
    { label: "Contact Information", value: 2 },
    { label: "Additional Information", value: 3 },
    { label: "Survey", value: 4 },
    { label: "Agreement", value: 5 },
    { label: "Document", value: 6 }
  ];
  @api wizardType;
  @track currentStep;
  @track dealerRecord = {};
  @track recordId;
  @track isRegistrationCompleted = false;
  backgroundUrl = lwcResource + "/img/confetti-woman.png";

  renderedCallback() {
    if (!this.currentStep) {
      this.currentStep = 1;
    }
    if (this.isRegistrationCompleted) {
      this.template
        .querySelector(".backImage")
        .style.setProperty("--my-back", `url("${this.backgroundUrl}")`);
    }
  }

  /**
   * Not required using nav bar
   * @param {*} event
   */
  handleProgressClick() {
    /* if (this.currentStep >= event.detail) {
      this.currentStep = event.detail;
    } */
  }

  /**
   * Fetch Record Id from Url
   * @param {*} currentPageReference
   */
  @wire(CurrentPageReference)
  fetchUrlParameters(currentPageReference) {
    if (currentPageReference) {
      this.recordId = currentPageReference.state.id || null;
    }
  }

  /**
   * Fetch dealer record
   * @param {*} param0
   */
  @wire(fetchRecord, {
    leadId: "$recordId",
    params: {
      isEncrypted: true,
      templateName: "DealerSurvey"
    }
  })
  fetchDealerRecordResult({ data, error }) {
    if (data) {
      //console.log("result : " + JSON.stringify(data));
      if (data.status === 200) {
        this.dealerRecord = { ...data.data };
        if (this.dealerRecord.dau01__Surveys__r) {
          this.dealerRecord.dau01__Surveys__r = {
            totalSize: this.dealerRecord.dau01__Surveys__r.length,
            done: true,
            records: this.dealerRecord.dau01__Surveys__r
          };
        }
      } else {
        this.dealerRecord = null;
      }
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
      this.validRecord = false;
      utils.errorMessage(this, error.body.message, "Error fetching record");
    }
  }

  /**
   * Collect dealer information from different pages and save in dealerRecord
   * @param {*} event
   */
  handleAnyDealerInfoChange(event) {
    const collectedInfo = event.detail.collectedInfo;
    // update all changes for reactive communication between pages
    if (collectedInfo) {
      this.dealerRecord = {
        ...this.dealerRecord,
        ...collectedInfo
      };
    }
    if (event.detail.currentStep) {
      this.currentStep = event.detail.currentStep;
    }
  }

  //updateSurveyInfo
  updateSurveyInfo(event) {
    this.updateLeadRecord(event, null);
  }

  /**
   * update lead record
   * @param {*} event
   * @param {*} eventType
   */
  updateLeadRecord(event, eventType) {
    this.dealerRecord = {
      ...this.dealerRecord,
      ...event.detail.collectedInfo
    }; // Top level dealer record information

    let dealerRecordCopy = JSON.parse(JSON.stringify(this.dealerRecord));

    if (dealerRecordCopy.dau01__Surveys__r) {
      dealerRecordCopy.dau01__Surveys__r?.records?.map((element) => {
        delete element.isCheckBox;
        delete element.isLabel;
        delete element.isPicklist;
        delete element.isTextBox;
        delete element.Label;
        return element;
      });
    }

    updateLeadAndSurveyRecords({
      params: {
        leadRecord: JSON.stringify(dealerRecordCopy),
        eventType: eventType
      }
    })
      .then((result) => {
        if (result.status === 200) {
          dealerRecordCopy = { ...result.data };
          if (dealerRecordCopy.dau01__Surveys__r) {
            dealerRecordCopy.dau01__Surveys__r = {
              totalSize: dealerRecordCopy.dau01__Surveys__r.length,
              done: true,
              records: dealerRecordCopy.dau01__Surveys__r
            };
            this.dealerRecord = { ...dealerRecordCopy };
          }
          this.currentStep = event.detail.currentStep;
        } else if (result.status === 500) {
          console.log("error : " + JSON.stringify(result.data));
          utils.errorMessage(
            this,
            result?.data?.message,
            "Error on submitting the data, PLease validate the information entered"
          );
        }
        //utils.successMessage(this, "Dealer Registered", "Success");
      })
      .catch((error) => {
        console.log("error : " + JSON.stringify(error));
        utils.errorMessage(
          this,
          error.body.message,
          "Error on submitting the data, PLease validate the information entered"
        );
      });
  }

  /**
   * Finish of dealer submit flow
   * @param {*} event
   */
  submitDealerInfoChange(event) {
    this.updateLeadRecord(event, "LeadSubmit");
    this.isRegistrationCompleted = true;
  }

  //stepper
  get isStepOne() {
    return this.currentStep === 1;
  }
  get isStepTwo() {
    return this.currentStep === 2;
  }
  get isStepThree() {
    return this.currentStep === 3;
  }
  get isStepFour() {
    return this.currentStep === 4;
  }
  get isStepFive() {
    return this.currentStep === 5;
  }
  get isStepSix() {
    return this.currentStep === 6;
  }
}
