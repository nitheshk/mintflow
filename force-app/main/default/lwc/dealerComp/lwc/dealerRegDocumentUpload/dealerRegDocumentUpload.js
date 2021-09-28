import { LightningElement, api, track, wire } from "lwc";
import utils from "c/generalUtils";
import fetchDocumentRequests from "@salesforce/apex/LWCDealerSiteController.fetchDocumentRequests";
import linkContentVersionToEntity from "@salesforce/apex/LWCDealerSiteController.linkContentVersionToEntity";
import deleteFile from "@salesforce/apex/LWCDealerSiteController.deleteFilesByEntityId";
export default class DealerRegDocumentUpload extends LightningElement {
  @api dealerRecord = {};
  @track dealerRecordEdited = {};
  @api currentStep;
  @track showSpinner = false;
  @track docments = [];
  get acceptedFormats() {
    return [".jpeg", ".jpg", ".csv", ".png", ".doc", ".docx", ".pdf"];
  }

  @wire(fetchDocumentRequests, { leadId: "$dealerRecord.Id" })
  fetchDocumentRequestResult({ data, error }) {
    if (data) {
      if (data.status === 200) {
        this.docments = JSON.parse(JSON.stringify(data.data));
      } else {
        this.docments = null;
      }
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
      utils.errorMessage(this, error.body.message, "Error fetching documents");
    }
  }

  /**
   * selected document
   * @param {*} id
   * @returns
   */
  fetchSelectedDocument(id) {
    return this.docments.find((element) => {
      return id === element.Id;
    });
  }

  /**
   * handle call after document uplaoded to salesforce
   * @param {*} event
   */
  handleUploadFinished(event) {
    const uploadedFiles = event.detail.files;
    this.showSpinner = true;
    let selectedDocument = this.fetchSelectedDocument(event.target.dataset.id);
    linkContentVersionToEntity({
      params: {
        contentVersionId: uploadedFiles[0].contentVersionId,
        entityIds: [this.dealerRecord.Id, selectedDocument.Id]
      }
    })
      .then((result) => {
        if (result.status === 200) {
          selectedDocument.dau01__ContentDocumentId__c =
            result.data.ContentDocumentId;
          selectedDocument.uploadedFileName = uploadedFiles[0].name;
          utils.successMessage(
            this,
            `${uploadedFiles[0].name} uploaded successfully`,
            "Success"
          );
        } else if (result.status === 500) {
          utils.errorMessage(this, result.data.message, "Error");
        } else {
          utils.errorMessage(this, `File not uploaded`, "Failed");
        }
      })
      .catch((error) => {
        console.log(error);
        utils.errorMessage(this, `File not uploaded`, "Failed");
      })
      .finally(() => {
        this.showSpinner = false;
      });
  }

  /**
   * Delete file by entity id
   * @param {*} event
   */
  handleDelete(event) {
    this.showSpinner = true;
    let selectedDocument = this.fetchSelectedDocument(event.target.dataset.id);
    deleteFile({ entityId: selectedDocument.Id })
      .then((result) => {
        if (result.status === 200) {
          utils.successMessage(
            this,
            `${selectedDocument.uploadedFileName} deleted successfully!!`,
            "Success"
          );
          selectedDocument.uploadedFileName = "";
          selectedDocument.dau01__ContentDocumentId__c = "";
        } else {
          utils.errorMessage(
            this,
            `Error while deleting ${selectedDocument.uploadedFileName}`,
            "error"
          );
        }
      })
      .catch((error) => {
        console.log(error);
        utils.errorMessage(
          this,
          error?.body?.message,
          `Error while deleting ${selectedDocument.uploadedFileName}`
        );
      })
      .finally(() => {
        this.showSpinner = false;
      });
  }

  // Dispatch dealer record value and current step on previous event in financial account information page
  handlePrev() {
    utils.customDispatchEvent(this, "documentuploadchange", {
      collectedInfo: this.dealerRecordEdited,
      currentStep: --this.currentStep
    });
  }

  // Dispatch dealer record value and current step on next event in contactinformation page
  submitDealerInfo() {
    utils.customDispatchEvent(this, "submitdealerinfochange", {});
  }
}
