import { LightningElement, track, api, wire } from "lwc";
//controller
import readApplicationWithChild from "@salesforce/apex/LwcCustomController.readApplicationWithChild";
import { publish, MessageContext } from "lightning/messageService";
import application360Details from "@salesforce/messageChannel/ViewRelatedFiles__c";

export default class Application360View extends LightningElement {
  @api recordId;
  @api applicationId;
  @track record;

  @wire(MessageContext)
  messageContext;

  /**
   * readApplicationWithChild
   * @param {*} result
   */
  @wire(readApplicationWithChild, {
    applicationId: "$recordId"
  })
  readData(result) {
    //console.log("recordId ::: " + JSON.stringify(this.recordId));
    if (result.data) {
      //console.log("result.data   : " + result.data);
      if (result.data.status === 200) {
        this.record = JSON.parse(result.data.data);
        //console.log("record ::: " + JSON.stringify(this.record));
      }
    } else if (result.error) {
      this.error = result.error;
      console.log("error : " + JSON.stringify(result.error));
    }
  }

  handleActive(event) {
    let idList = [];
    let targetElement = event.target;
    switch (targetElement.dataset.objectname) {
      case "mflow__Applicant__c":
        {
          idList = [targetElement.dataset.recordid];
        }
        break;
      case "mflow__IdentificationDocuments__r":
      case "mflow__ContactPointAddresses__r":
      case "mflow__Employments__r":
        {
          let applicant = this.record?.mflow__ApplicantsTemp__r?.filter(
            (element) => element.Id === targetElement.dataset.recordid
          );

          if (Array.isArray(applicant)) {
            applicant[0][targetElement.dataset.objectname]?.forEach(function (
              element
            ) {
              idList.push(element.Id);
            });
          }
        }
        break;
      default:
        break;
    }

    if (idList.length) {
      publish(this.messageContext, application360Details, {
        recordIds: idList,
        titleName: "View related"
      });
    }
  }
}
