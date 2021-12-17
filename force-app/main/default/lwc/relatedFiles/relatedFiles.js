import { LightningElement, wire, track, api } from "lwc";
import utils from "c/generalUtils";
import fetchRelatedFiles from "@salesforce/apex/LwcCustomController.fetchRelatedFiles";
import { NavigationMixin } from "lightning/navigation";

export default class RelatedFiles extends NavigationMixin(LightningElement) {
  @api objectApiName;
  @api recId;
  @track error;
  @track data = [];
  @track visibility = true;
  @track columns = [
    {
      label: "File Name",
      fieldName: "title",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      wrapText: true,
      fixedWidth: 150
      // type: "url",

      // typeAttributes: {
      //   label: { fieldName: "title", type: "text" },
      //   target: "_self",
      //   tooltip: { fieldName: "title", type: "text" }
      // },
      // sortable: false,
      // hideDefaultActions: true,
      // wrapText: true
    },
    {
      label: "Document type",
      fieldName: "documentType",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      wrapText: true,
      fixedWidth: 150
    },
    {
      label: "Timestamp",
      fieldName: "createDate",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      wrapText: true
    },
    {
      label: "Preview",
      type: "button",
      typeAttributes: {
        label: "Preview",
        name: "Preview",
        variant: "brand-outline",
        iconName: "utility:preview",
        iconPosition: "right",
        fieldName: "contentDocumentId",
        onclick: this.previewFile(fieldName)
      }
    }
  ];

  @wire(fetchRelatedFiles, {
    params: {
      relatedEntityId: "a0b0p000001yqYeAAI"
    }
  })
  relatedFiles(result, error) {
    if (result && result.data && result.data.status === 200) {
      const { data: fileData = "" } = result.data;
      console.log("fileData aft parse", JSON.parse(fileData));
      // console.log("data.data stgif", data && data.data ? JSON.parse(data.data));
      // console.log(data.data ? JSON.parse(data.data) : JSON.parse(data));
      this.data = JSON.parse(fileData);
      if (this.data != null && this.data.length > 0) {
        this.visibility = true;
      } else {
        this.visibility = false;
      }
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
      utils.errorMessage(this, error.body.message, "Error fetching record");
    }
  }
  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    console.log(actionName);
    console.log(row);
    switch (actionName) {
      case "Preview":
        this.previewFile(row);
        break;
      default:
    }
  }
  previewFile(file) {
    // console.log(file);
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
