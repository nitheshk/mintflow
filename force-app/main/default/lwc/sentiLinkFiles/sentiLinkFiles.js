import { LightningElement, track, wire, api } from "lwc";
import fetchReportDetail from "@salesforce/apex/SentiLinkReportController.fetchReportDetail";

export default class SentiLinkFiles extends LightningElement {
  @api objectApiName;
  @api recordId;
  @track error;
  @track data = [];
  @track visibility;
  @track columns = [
    {
      label: "File Name",
      fieldName: "reportUrl",
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

  @wire(fetchReportDetail, {
    partyId: "$recordId"
  })
  wireReportDetail(result) {
    this.record = result;
    console.log("record ::: " + JSON.stringify(result));
    if (result.data) {
      this.data = result.data;
      if (this.data != null && this.data.length > 0) {
        this.visibility = true;
      } else {
        this.visibility = false;
      }
    } else if (result.error) {
      this.error = result.error;
    }
  }
}
