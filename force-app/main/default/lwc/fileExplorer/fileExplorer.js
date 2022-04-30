import { api, LightningElement, track, wire } from "lwc";
import fetchContentVersionByEntityIds from "@salesforce/apex/FileController.fetchContentVersionByEntityIds";
import deleteContentVersion from "@salesforce/apex/FileController.deleteContentVersion";
import generatePublicUrl from "@salesforce/apex/FileController.generatePublicUrl";
import getLoginURL from "@salesforce/apex/GenericUtils.fetchLoginURL";
import { NavigationMixin } from "lightning/navigation";
import { subscribe, APPLICATION_SCOPE, MessageContext } from "lightning/messageService";
import application360Details from "@salesforce/messageChannel/ViewRelatedFiles__c";
import timezone from "@salesforce/i18n/timeZone";

const columns = [
  {
    label: "Title",
    type: "button",
    wrapText: false,
    typeAttributes: {
      label: { fieldName: "Title" },
      name: "Preview",
      variant: "base"
    }
  },
  {
    label: "Created Date",
    fieldName: "CreatedDate"
  },
  { label: "File Size", fieldName: "Size" }
  /*
  {
    label: "View",
    type: "button",
    typeAttributes: {
      label: "View",
      name: "Preview",
      variant: "brand-outline",
      iconName: "utility:preview",
      iconPosition: "right"
    }
  },
  {
    label: "Download",
    type: "button",
    typeAttributes: {
      label: "Download",
      name: "Download",
      variant: "brand",
      iconName: "action:download",
      iconPosition: "right"
    }
  },
  {
    label: "Delete",
    type: "button",
    typeAttributes: {
      label: "Delete",
      name: "Delete",
      variant: "destructive",
      iconName: "standard:record_delete",
      iconPosition: "right"
    }
  }*/
];

export default class FileExplorer extends NavigationMixin(LightningElement) {
  @api title;
  @api showFileUpload;
  @api showsync;
  @api recordId;
  @track recordIds = [];
  @api usedInCommunity;
  @api showFilters;
  @api accept;
  @api showDownload;
  @api showDelete;
  @track dataList;
  @track columnsList = columns;
  isLoading = false;
  @track openModal = false;
  @track iframeUrl;
  @api modelPreview;

  connectedCallback() {
    if (this.recordId) {
      this.recordIds.push(this.recordId);
    }
    this.handleSync();
  }
  /*
  renderedCallback() {
    
    if (this.showDownload === false) {
      console.log("showDownload:", this.showDownload);
      this.columnsList = this.columns?.filter((item) => {
        return item.label !== "Download";
      });

      console.log(
        " this.columnsList:showDownload",
        JSON.stringify(this.columnsList)
      );
    }
    if (this.showDelete === false) {
      console.log("showDelete:", this.showDelete);
      this.columnsList = this.columns?.filter((item) => {
        return item.label !== "Delete";
      });
      console.log(
        " this.columnsList:showDelete",
        JSON.stringify(this.columnsList)
      );
    } 
  }*/

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
        this.titleName = data.titleName + " Files";
        this.recordIds = data.recordIds;
        if (this.recordIds != null) {
          this.handleSync();
        }
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  get showFileHeader() {
    return this.showFilters || this.showFileUpload;
  }

  /**
   * get content data
   */
  handleSync() {
    console.log("this.recordIds:", JSON.stringify(this.recordIds));
    this.isLoading = true;
    fetchContentVersionByEntityIds({
      request: {
        header: JSON.stringify({
          entityIds: this.recordIds
        })
      }
    })
      .then((result) => {
        console.log(" result :", result);
        if (result.status !== 200 || result.data == null) {
          return;
        }

        let finalData = JSON.parse(result.data);
        let baseUrl = this.getBaseUrl();
        finalData.forEach((file) => {
          file.downloadUrl = baseUrl + "sfc/servlet.shepherd/document/download/" + file.ContentDocumentId;
          // file.fileUrl =
          //   baseUrl + "sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=" + file.Id;
          file.Size = this.formatBytes(file.ContentSize, 2);
          file.CreatedDate = new Date(file.CreatedDate).toLocaleString("en-US", { timeZone: timezone });
        });
        this.dataList = finalData;
      })
      .catch((error) => {
        console.error("**** error **** \n ", error);
        this.dataList = [];
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  /**
   *
   * @returns
   */
  getBaseUrl() {
    let baseUrl = "https://" + window.location.host + "/";
    getLoginURL()
      .then((result) => {
        if (result.status === 200) {
          baseUrl = result.data;
          window.console.log(baseUrl);
        }
      })
      .catch((error) => {
        console.error("Error: \n ", error);
      });
    return baseUrl;
  }
  /**
   *
   * @param {*} bytes
   * @param {*} decimals
   * @returns
   */
  formatBytes(bytes, decimals) {
    if (bytes == 0) return "0 Bytes";
    let k = 1024,
      dm = decimals || 2,
      sizes = ["Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"],
      i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + " " + sizes[i];
  }

  /**
   *
   * @param {*} event
   */
  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
      case "Preview":
        this.previewFile(row);
        break;
      case "Download":
        this.downloadFile(row);
        break;
      case "Delete":
        this.handleDeleteFiles(row);
        break;
      default:
    }
  }

  /**
   *
   * @param {*} file
   */
  previewFile(file) {
    console.log("FileUrl preview : " + file.downloadUrl);
    if (this.usedInCommunity) {
      this.isLoading = true;
      generatePublicUrl({
        request: {
          header: JSON.stringify({
            contentVersionId: file.Id
          })
        }
      })
        .then((result) => {
          if (result.status === 200) {
            this.iframeUrl = JSON.parse(result.data)?.DistributionPublicUrl;
            if (this.iframeUrl) {
              this.openModal = true;
            }
          }
        })
        .catch((error) => {
          console.error("**** error **** \n ", error);
        })
        .finally(() => {
          this.isLoading = false;
        });
    } else if (!this.usedInCommunity) {
      this[NavigationMixin.Navigate]({
        type: "standard__namedPage",
        attributes: {
          pageName: "filePreview"
        },
        state: {
          selectedRecordId: file.ContentDocumentId
        }
      });
    }
  }

  /**
   *
   * @param {*} file
   */
  downloadFile(file) {
    this[NavigationMixin.Navigate](
      {
        type: "standard__webPage",
        attributes: {
          url: file.downloadUrl
        }
      },
      false
    );
  }

  /**
   *
   * @param {*} row
   */
  handleDeleteFiles(row) {
    this.isLoading = true;

    deleteContentVersion({
      contentDocumentId: row.ContentDocumentId
    })
      .then((result) => {
        if (result.status === 200) {
          this.dataList = this.dataList.filter((item) => {
            return item.ContentDocumentId !== row.ContentDocumentId;
          });
        }
      })
      .catch((error) => {
        console.error("**** error **** \n ", error);
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  /**
   *
   */
  handleUploadFinished() {
    this.recordIds = [];
    this.recordIds.push(this.recordId);
    this.handleSync();
  }

  /**
   *
   * @param {*} event
   */
  handleSearch(event) {
    let value = event.target.value;
    let name = event.target.name;
    if (name === "Title") {
      this.dataList = this.dataList.filter((file) => {
        return file.Title.toLowerCase().includes(value.toLowerCase());
      });
    }
  }

  showModal() {
    this.openModal = true;
  }

  closeModal() {
    this.openModal = false;
    this.iframeUrl = null;
  }
}
