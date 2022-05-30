import { LightningElement, api, track, wire } from "lwc";
import utils from "c/generalUtils";

import getApplicantNames from "@salesforce/apex/LwcCustomController.fetchApplicantNames";
import create from "@salesforce/apex/LwcCustomController.createDocumentRequest";

import documentRequestSobject from "@salesforce/schema/DocumentRequest__c";
import comments from "@salesforce/schema/DocumentRequest__c.Comments__c";
import documentType from "@salesforce/schema/DocumentRequest__c.DocumentType__c";
import name from "@salesforce/schema/DocumentRequest__c.Name__c";
import required from "@salesforce/schema/DocumentRequest__c.Required__c";
import status from "@salesforce/schema/DocumentRequest__c.Status__c";

export default class CreateDocumentRequest extends LightningElement {
  @api recordId;
  @track applicantNames = [];
  @track disabled = false;
  selectedApplicant = "";

  documentRequestObj = {
    type: documentRequestSobject,
    fields: {
      Comments__c: comments,
      DocumentType__c: documentType,
      Name__c: name,
      Required__c: required,
      Status__c: status
    }
  };

  @wire(getApplicantNames, {
    applicationId: "$recordId"
  })
  wireApplicantNames(result) {
    console.log("result.data ::: " + JSON.stringify(result));
    if (result.data) {
      this.applicantNames = JSON.parse(result.data?.data);
    }
  }

  /**
   * @param {*} event
   */
  selectApplicantHandler(event) {
    this.selectedApplicant = event.target.value;
    console.log("this.selectedApplicant : " + this.selectedApplicant);
  }

  /**
   * Handle Submit
   * @param {*} event
   */
  handleSubmit(event) {
    event.preventDefault();

    this.disabled = true;
    const docReqObj = Object.assign(
      {
        mflow__Application__c: this.recordId,
        mflow__Applicant__c: this.selectedApplicant
      },
      event.detail.fields
    );

    create({ documentRequestObj: docReqObj })
      .then((result) => {
        if (result.status === 200) {
          utils.successMessage(this, "Created Successfully", "Success");
          this.handleCancel();
        } else {
          console.log(JSON.stringify(result.data));
          utils.errorMessage(this, "Something Went Wrong", "Error");
        }
      })
      .catch((error) => {
        utils.errorMessage(this, "Something went Wrong", "Error");
        console.log(JSON.stringify(error));
      })
      .finally(() => (this.disabled = false));
  }

  /**
   * handleCancel
   */
  handleCancel() {
    const inputFields = this.template.querySelectorAll("lightning-input-field");
    if (inputFields) {
      inputFields.forEach((field) => {
        field.reset();
      });
    }
    this.selectedApplicant = null;
  }
}
