import { LightningElement, track, api, wire } from "lwc";
import timezone from "@salesforce/i18n/timeZone";
import { publish, MessageContext } from "lightning/messageService";
import application360Details from "@salesforce/messageChannel/Application360RelatedFiles__c";

//controller
import fetchFieldDetails from "@salesforce/apex/LwcCustomController.fetchFieldDetails";
const fieldsets = [
  { Name: "Contact Information", apiName: "mflow__ContactInformation" },
  { Name: "Personal Information", apiName: "mflow__PersonalInformation" },
  { Name: "Status Information", apiName: "mflow__StatusInformation" }
];
export default class ApplicantRecordDetailView extends LightningElement {
  @api record;
  @api sObjectName;
  @api titleName;
  @track showSpinner = false;
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

            if (Array.isArray(this.record)) {
              // eslint-disable-next-line guard-for-in
              for (let d in this.record) {
                let tempData = [];
                for (let keyValue in result) {
                  if (
                    !this.hideNullValues ||
                    this.record[d][result[keyValue].key]
                  ) {
                    if (result[keyValue].type === "REFERENCE") {
                      continue;
                    }
                    if (result[keyValue].type === "DATETIME") {
                      let dt = new Date(this.record[d][result[keyValue].key]);
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
                      if (result[keyValue].key === "id") {
                        this.idList.push(this.record[d][result[keyValue].key]);
                      }
                      tempData.push({
                        key: result[keyValue].value,
                        value: this.record[d][result[keyValue].key],
                        apiname: result[keyValue].key,
                        type: result[keyValue].type
                      });
                    }
                  }
                }
                if (tempData.length > 0) {
                  results.push(tempData);
                  this.completeLayout.push(results);
                }
              }
            } else {
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
                    if (result[keyValue].key === "id") {
                      this.idList.push(this.record[result[keyValue].key]);
                    }
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
            }
            this.dataLoaded = true;
          })
          .catch((error) => {
            console.log(error);
          });
      });
    }
  }
  showRelatedFiles() {
    var idList = [];
    console.log("record in detailview =", this.record);
    if (Array.isArray(this.record)) {
      this.record.forEach((element) => {
        idList.push(element.Id);
      });
    } else {
      idList.push(this.record.Id);
    }
    const data = {
      recordIds: idList,
      titleName: this.titleName
    };

    publish(this.messageContext, application360Details, data);
  }
}
