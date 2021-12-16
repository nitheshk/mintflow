import { LightningElement, wire, track, api } from "lwc";
import utils from "c/generalUtils";
import fetchRelatedFiles from "@salesforce/apex/LwcCustomController.fetchRelatedFiles";

export default class RelatedFiles extends LightningElement {
  @api objectApiName;
  @api recId;
  @track error;
  @track data = [];
  @track visibility = true;
  @track columns = [
    {
      label: "File Name",
      type: "url",
      typeAttributes: {
        label: { fieldName: "title", type: "text" },
        target: "_self",
        tooltip: { fieldName: "title", type: "text" }
      },
      sortable: false,
      hideDefaultActions: true,
      wrapText: true
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
    }
  ];

  @wire(fetchRelatedFiles, {
    params: {
      relatedEntityId: "a0b0p000001yqYeAAI"
    }
  })
  relatedFiles(data, error) {
    this.record = data;
    console.log("JSON.stringify(result) ::: " + JSON.stringify(data));
    // console.log("JSON.stringify(result.data) ::: " + JSON.parse(data.data));
    // console.log(
    //   "JSON.stringify(result.data.data) ::: " + JSON.stringify(result.data.data)
    // );
    if (data) {
      this.data = JSON.parse(data.data);
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
}
