import { LightningElement, wire, track } from "lwc";
import utils from "c/generalUtils";
import fetchRelatedFiles from "@salesforce/apex/LwcCustomController.fetchRelatedFiles";
import { NavigationMixin } from "lightning/navigation";
import { subscribe, APPLICATION_SCOPE, MessageContext } from "lightning/messageService";
import application360Details from "@salesforce/messageChannel/ViewRelatedFiles__c";
export default class FilePrivewInLWC extends NavigationMixin(LightningElement) {
  @track titleName;
  @track recordIds = [];
  @track error;
  @track showFile;
  @track message = "No files to display";
  subscription = null;
  @track files;

  @wire(MessageContext)
  messageContext;

  /**
   * renderedCallback
   */
  renderedCallback() {
    this.subscription = subscribe(
      this.messageContext,
      application360Details,
      (data) => {
        this.showFile = true;
        this.titleName = data.titleName + " Files";
        this.recordIds = data.recordIds;
        if (this.recordIds != null) {
          this.relatedFiles();
        }
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  /**
   * relatedFiles
   */
  relatedFiles() {
    fetchRelatedFiles({
      relatedIds: JSON.stringify(this.recordIds)
    })
      .then((result) => {
        if (result && result.status === 200) {
          this.files = JSON.parse(result.data);
        } else {
          console.log("error : ", result);
          utils.errorMessage(this, result.body, "Error fetching record");
        }
      })
      .catch((error) => {
        console.log("error : ", error);
        utils.errorMessage(this, error.body.message, "Error fetching record");
      });
  }

  /**
   *  Reteriving the files to preview
   * @param {*} event
   */
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
