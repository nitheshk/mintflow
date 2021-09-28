import { api, LightningElement, track } from "lwc";
import getContentDetails from "@salesforce/apex/FileController.fetchContentVersionByEntityId";
import deleteContentVersion from "@salesforce/apex/FileController.deleteContentVersion";
import generatePublicUrl from "@salesforce/apex/FileController.generatePublicUrl";
import getLoginURL from "@salesforce/apex/GenericUtils.fetchLoginURL";
import { NavigationMixin } from "lightning/navigation";

const columns = [
  {
    label: "Title",
    fieldName: "Title",
    wrapText: true,
    cellAttributes: {
      iconName: { fieldName: "icon" },
      iconPosition: "left"
    }
  },
  {
    label: "Created Date",
    fieldName: "CreatedDate",
    cellAttributes: {
      iconName: "standard:user",
      iconPosition: "left"
    }
  },
  { label: "File Size", fieldName: "Size" },
  {
    label: "Preview",
    type: "button",
    typeAttributes: {
      label: "Preview",
      name: "Preview",
      variant: "brand-outline",
      iconName: "utility:preview",
      iconPosition: "right"
    }
  }
  /*{
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
  @api usedInCommunity;
  @api showFilters;
  @api accept = ".csv,.doc,.xsl,.pdf,.png,.jpg,.jpeg,.docx,.doc";
  @api showDownload;
  @api showDelete;
  @track dataList;
  @track columnsList = columns;
  isLoading = false;
  @track openModal = false;
  @track iframeUrl;
  @api modelPreview;

  connectedCallback() {
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

  previewFile(file) {
    console.log("FileUrl preview : " + file.fileUrl);
    console.log("FileUrl preview : " + file.downloadUrl);
    this.isLoading = true;

    if (this.modelPreview) {
      generatePublicUrl({
        contentVersionId: file.Id
      })
        .then((result) => {
          console.log("result:", JSON.stringify(result));
          if (result.status === 200) {
            this.iframeUrl = result?.data?.DistributionPublicUrl;
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
    } else {
      if (!this.usedInCommunity) {
        this[NavigationMixin.Navigate]({
          type: "standard__namedPage",
          attributes: {
            pageName: "filePreview"
          },
          state: {
            selectedRecordId: file.ContentDocumentId
          }
        });
      } else if (this.usedInCommunity) {
        console.log("fileurl:", file.fileUrl);
        this[NavigationMixin.Navigate](
          {
            type: "standard__webPage",
            attributes: {
              url: file.fileUrl
            }
          },
          false
        );
      }
    }
  }

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

  handleSync() {
    let imageExtensions = ["png", "jpg", "gif"];
    let supportedIconExtensions = [
      "ai",
      "attachment",
      "audio",
      "box_notes",
      "csv",
      "eps",
      "excel",
      "exe",
      "flash",
      "folder",
      "gdoc",
      "gdocs",
      "gform",
      "gpres",
      "gsheet",
      "html",
      "image",
      "keynote",
      "library_folder",
      "link",
      "mp4",
      "overlay",
      "pack",
      "pages",
      "pdf",
      "ppt",
      "psd",
      "quip_doc",
      "quip_sheet",
      "quip_slide",
      "rtf",
      "slide",
      "stypi",
      "txt",
      "unknown",
      "video",
      "visio",
      "webex",
      "word",
      "xml",
      "zip"
    ];

    this.isLoading = true;
    getContentDetails({
      entityId: this.recordId,
      ignoreVersionData: true
    })
      .then((result) => {
        if (result.status !== 200) {
          return;
        }
        let finalData = JSON.parse(JSON.stringify(result.data));
        let baseUrl = this.getBaseUrl();
        finalData.forEach((file) => {
          file.downloadUrl =
            baseUrl +
            "sfc/servlet.shepherd/document/download/" +
            file.ContentDocumentId;
          file.fileUrl =
            baseUrl +
            "sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=" +
            file.Id;
          file.Size = this.formatBytes(file.ContentSize, 2);
          let fileType = file.FileType.toLowerCase();
          if (imageExtensions.includes(fileType)) {
            file.icon = "doctype:image";
          } else {
            if (supportedIconExtensions.includes(fileType)) {
              file.icon = "doctype:" + fileType;
            }
          }
        });
        this.dataList = finalData;
      })
      .catch((error) => {
        console.error("**** error **** \n ", error);
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  handleUploadFinished() {
    this.handleSync();
  }
  formatBytes(bytes, decimals) {
    if (bytes == 0) return "0 Bytes";
    let k = 1024,
      dm = decimals || 2,
      sizes = ["Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"],
      i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + " " + sizes[i];
  }

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
