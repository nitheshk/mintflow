import { LightningElement, wire, track } from "lwc";
import utils from "c/generalUtils";
import fetchRelatedFiles from "@salesforce/apex/LwcCustomController.fetchRelatedFiles";
import { NavigationMixin } from "lightning/navigation";
import {
  subscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import application360Details from "@salesforce/messageChannel/Application360RelatedFiles__c";
export default class FilePrivewInLWC extends NavigationMixin(LightningElement) {
  @track sObjectName;
  @track recordIds = [];
  @track error;
  @track showFile;
  subscription = null;
  @track files;

  @wire(MessageContext)
  messageContext;

  renderedCallback() {
    this.subscription = subscribe(
      this.messageContext,
      application360Details,
      (data) => {
        console.log(data);
        this.sObjectName = data.sObjectName;
        this.recordIds = data.recordIds;
        console.log(
          "recordid =",
          this.recordIds,
          "object name = ",
          this.sObjectName
        );
        if (this.recordIds != null) {
          this.relatedFiles();
        }
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  relatedFiles() {
    fetchRelatedFiles({
      relatedIds: JSON.stringify(this.recordIds)
    })
      .then((result) => {
        if (result && result.status === 200) {
          this.files = JSON.parse(result.data);
          if (this.files != null && this.files.length > 0) {
            this.showFile = true;
          } else {
            this.showFile = false;
          }
        } else {
          console.log("in else", result);
        }
      })
      .catch((error) => {
        console.log("error : ", error);
        utils.errorMessage(this, error.body.message, "Error fetching record");
      });
  }
  // Reteriving the files to preview
  filePreview(event) {
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "filePreview"
      },
      state: {
        selectedRecordId: event.currentTarget.dataset.id
      }
    });
  }
}
