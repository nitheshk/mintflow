import { LightningElement, track, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import fetchRecord from "@salesforce/apex/LWCDealerSiteController.fetchLeadAndSurvey";
import approveLead from "@salesforce/apex/LWCFinancialInstituteSiteController.approveLead";
import rejectLead from "@salesforce/apex/LWCFinancialInstituteSiteController.rejectLead";
import resetInviteLink from "@salesforce/apex/LWCFinancialInstituteSiteController.resetDealerInviteLink";
import surveyTemplates from "@salesforce/apex/LWCFinancialInstituteSiteController.fetchSurveyTemplates";
import utils from "c/generalUtils";
import surveyUtils from "c/surveyUtils";

export default class DealerRecordPage extends LightningElement {
  @track recordId;
  @track dealerRecord = {};
  //flag
  @track showSpinner = false;
  @track showLeadConvertBtn = false;
  @track showLinkResetBtn = false;
  @track showModelSpinner = false;
  @track openModal = false;
  //FI survey
  @track finInstSurvey;
  @track dealerSurvey;
  @track disableApproveBtn = true;
  @track disableRejectBtn = false;

  /**
   * Set Current page reference
   * @param {*} currentPageReference
   */
  @wire(CurrentPageReference)
  fetchUrlParameters(currentPageReference) {
    if (currentPageReference) {
      this.recordId = currentPageReference.state.id || null;
    }
  }

  /**
   * fetch initial lead record
   * @param {*} param0
   */
  @wire(fetchRecord, {
    leadId: "$recordId",
    params: {
      isEncrypted: false
    }
  })
  fetchDealerRecordResult({ data, error }) {
    this.showSpinner = true;
    if (data) {
      if (data.status === 200) {
        this.dealerRecord = { ...data.data };
        this.initSurvey();
        this.showSpinner = false;
      } else {
        this.dealerRecord = null;
        this.showSpinner = false;
      }
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
      this.showSpinner = false;
      utils.errorMessage(this, error.body.message, "Error fetching record");
    }
  }

  get showBtnAction() {
    return this.showLeadConvertBtn || this.showLinkResetBtn;
  }

  /**
   * Set survey
   */
  initSurvey() {
    if (this.dealerRecord) {
      this.showLinkResetBtn =
        this.dealerRecord.Status === "Working - Contacted" ||
        this.dealerRecord.Status === "Under Review"
          ? true
          : false;
      this.showLeadConvertBtn =
        this.dealerRecord.Status === "Under Review" ? true : false;

      if (this.dealerRecord?.dau01__Surveys__r) {
        this.dealerSurvey = JSON.parse(
          JSON.stringify(
            this.dealerRecord?.dau01__Surveys__r.filter((element) => {
              return element.dau01__TemplateName__c === "DealerSurvey";
            })
          )
        );

        surveyUtils.initSurvey(this.dealerSurvey).then((result) => {
          this.displayLeadConvertButtons(this.finInstSurvey);
          console.log(result);
        });

        this.finInstSurvey = JSON.parse(
          JSON.stringify(
            this.dealerRecord?.dau01__Surveys__r.filter((element) => {
              return element.dau01__TemplateName__c === "DealerApprovalSurvey";
            })
          )
        );

        surveyUtils.initSurvey(this.finInstSurvey).then((result) => {
          console.log(result);
        });
      }

      if (this.dealerRecord.Status !== "Working - Contacted") {
        if (this.finInstSurvey == null || this.finInstSurvey?.length == 0) {
          surveyTemplates({ params: { templateName: "DealerApprovalSurvey" } })
            .then((data) => {
              this.finInstSurvey = JSON.parse(JSON.stringify(data.data));
              surveyUtils.initSurvey(this.finInstSurvey).then((result) => {
                this.displayLeadConvertButtons(this.finInstSurvey);
                console.log(result);
              });
            })
            .catch((error) => {
              console.log(error);
              utils.errorMessage(
                this,
                error.body.message,
                "Error creating record"
              );
            });
        }
      }
    }
  }

  /**
   * show approve or reject buttons
   */
  displayLeadConvertButtons(data) {
    let filterData = data?.filter((element) => {
      return element.dau01__QuestionCode__c === "Q8";
    });
    if (filterData.length > 0) {
      if (filterData[0].dau01__Answer__c) {
        this.disableApproveBtn = false;
        this.disableRejectBtn = true;
      } else {
        this.disableApproveBtn = true;
        this.disableRejectBtn = false;
      }
    }
  }

  /**
   * Handle Survey answer
   * @param {*} event
   */
  handleSurveyChange(event) {
    surveyUtils.surveyHandleChange(this.finInstSurvey, event).then((result) => {
      this.displayLeadConvertButtons(this.finInstSurvey);
      console.log("result:", result);
    });
  }

  /**
   * Handle Lead Value change
   * @param {*} event
   */
  handleLeadChange(event) {
    var targetElement = event.target;
    this.dealerRecord[targetElement.dataset.fieldname] = targetElement.value;
  }

  /**
   * Handle approval process of lead
   */
  handleLeadConversion(event) {
    let leadStatus = event.target.dataset.status;

    try {
      this.showModelSpinner = true;
      if (
        !utils.checkAllValidations(
          this.template.querySelectorAll(".validation")
        )
      ) {
        this.showModelSpinner = false;
        return;
      }

      let leadRecordCopy = JSON.parse(JSON.stringify(this.dealerRecord));

      if (this.finInstSurvey) {
        leadRecordCopy.dau01__Surveys__r = {
          totalSize: this.finInstSurvey.length,
          done: true,
          records: JSON.parse(JSON.stringify(this.finInstSurvey))
        };

        leadRecordCopy.dau01__Surveys__r?.records?.map((element) => {
          delete element.isCheckBox;
          delete element.isLabel;
          delete element.isPicklist;
          delete element.isTextBox;
          delete element.Label;
          return element;
        });

        if (leadStatus === "Approve") {
          approveLead({
            params: {
              leadRecord: leadRecordCopy
            }
          }).then((data) => {
            if (data.status === 200) {
              this.dealerRecord = { ...data.data };
              this.initSurvey();
              this.closeModal();
              this.showModelSpinner = false;
              utils.successMessage(
                this,
                "Lead has Approved successfully",
                "Success"
              );
            } else {
              this.closeModal();
              utils.errorMessage(this, data.data.message, "Error");
              this.showModelSpinner = false;
            }
          });
        } else if (leadStatus === "Reject") {
          rejectLead({
            params: {
              leadRecord: leadRecordCopy
            }
          }).then((data) => {
            if (data.status === 200) {
              this.dealerRecord = { ...data.data };
              this.initSurvey();
              this.closeModal();
              this.showModelSpinner = false;
              utils.successMessage(
                this,
                "Lead has Rejected successfully",
                "Success"
              );
            } else {
              this.closeModal();
              utils.errorMessage(this, data.data.message, "Error");
              this.showModelSpinner = false;
            }
          });
        }
      }
    } catch (error) {
      console.log("error:", JSON.stringify(error));
      this.showModelSpinner = false;
    }
  }

  //model pop up
  showModal() {
    this.openModal = true;
  }
  closeModal() {
    this.openModal = false;
  }

  /**
   * reset dealer invite link
   */
  resetDealerInviteLink() {
    this.showSpinner = true;
    resetInviteLink({ params: { leadId: this.dealerRecord.Id } })
      .then((result) => {
        if (result.status === 200) {
          this.dealerRecord = { ...result.data };
          this.initSurvey();
          utils.successMessage(
            this,
            "User will receive a new link shortly via Email",
            "Success"
          );
        } else {
          utils.errorMessage(this, "Unable to Reset the Link", "Error");
        }
        this.showSpinner = false;
      })
      .catch((error) => {
        this.showSpinner = false;
        console.log("error:", JSON.stringify(error));
      });
  }
}
