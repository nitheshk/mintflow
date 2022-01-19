import { LightningElement, track, api, wire } from "lwc";
import timezone from "@salesforce/i18n/timeZone";
import { publish, MessageContext } from "lightning/messageService";
import application360Details from "@salesforce/messageChannel/Application360RelatedFiles__c";

//controller
import fetchFieldDetails from "@salesforce/apex/LwcCustomController.fetchFieldDetails";
export default class ApplicantRecordDetailView extends LightningElement {
  @api record;
  @api sObjectName;
  @api titleName;
  //@track showSpinner = false;
  @api hideHeader = false;
  @api hideNullValues = false;
  @track contactResult = [];
  @track personalResult = [];
  @track statusResult = [];
  @track fieldsets = [
    "mflow__ContactInformation",
    "mflow__PersonalInformation",
    "mflow__StatusInformation"
  ];
  @track dataLoaded = false;

  @wire(MessageContext)
  messageContext;
  renderedCallback() {
    //console.log("Child renderedCallback::: " + JSON.stringify(this.record.Id));
    if (this.record && !this.dataLoaded) {
      //console.log("Child this.record ::: " + JSON.stringify(this.record));
      this.fieldsets.forEach((element) => {
        fetchFieldDetails({
          params: {
            sObjectName: this.sObjectName,
            fieldSetName: element
          }
        })
          .then((data) => {
            console.log(data);
            //console.log("FiledNames result ::: " + JSON.stringify(data));
            let result = data.status === 200 ? JSON.parse(data.data) : [];

            let tempData = [];
            for (let keyValue in result) {
              if (!this.hideNullValues || this.record[result[keyValue].key]) {
                if (result[keyValue].type === "REFERENCE") {
                  continue;
                }
                if (result[keyValue].type === "DATETIME") {
                  let dt = new Date(this.record[result[keyValue].key]);
                  tempData.push({
                    key: result[keyValue].value,
                    value:
                      dt instanceof Date && !isNaN(dt)
                        ? dt.toLocaleString("en-US", { timeZone: timezone })
                        : "",
                    apiname: result[keyValue].key,
                    type: result[keyValue].type
                  });
                } else {
                  tempData.push({
                    key: result[keyValue].value,
                    value: this.record[result[keyValue].key],
                    apiname: result[keyValue].key,
                    type: result[keyValue].type
                  });
                }
              }
            }
            if (tempData.length > 0) {
              if (element === "mflow__ContactInformation") {
                this.contactResult.push(tempData);
              } else if (element === "mflow__PersonalInformation") {
                this.personalResult.push(tempData);
              } else if (element === "mflow__StatusInformation") {
                this.statusResult.push(tempData);
              }
            }
            this.dataLoaded = true;
          })
          .catch((error) => {
            console.log(error);
          });
      });
    }
  }

  /**
   * showRelatedFiles
   */
  showRelatedFiles() {
    let idList = [];
    if (Array.isArray(this.record)) {
      this.record.forEach((element) => {
        idList.push(element.Id);
      });
    } else {
      idList.push(this.record.Id);
    }

    publish(this.messageContext, application360Details, {
      recordIds: idList,
      titleName: this.titleName
    });
  }
}
