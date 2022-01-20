import { LightningElement, track, api, wire } from "lwc";
import timezone from "@salesforce/i18n/timeZone";
import { publish, MessageContext } from "lightning/messageService";
import application360Details from "@salesforce/messageChannel/ViewRelatedFiles__c";

//controller
import fetchFieldDetails from "@salesforce/apex/LwcCustomController.fetchFieldDetails";

export default class RecordDetailView extends LightningElement {
  @api record;
  @api sObjectName;
  @api fieldSetName;
  @api titleName;
  @track showSpinner = false;
  @api hideHeader = false;
  @api hideNullValues = false;
  results = [];
  @track dataLoaded = false;
  @wire(MessageContext)
  messageContext;
  renderedCallback() {
    //console.log("Child renderedCallback::: " + JSON.stringify(this.record.Id));
    if (this.record && !this.dataLoaded) {
      //console.log("Child this.record ::: " + JSON.stringify(this.record));
      this.showSpinner = true;
      fetchFieldDetails({
        params: {
          sObjectName: this.sObjectName,
          fieldSetName: this.fieldSetName
        }
      })
        .then((data) => {
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
                this.results.push(tempData);
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
              this.results.push(tempData);
            }
          }
          this.dataLoaded = true;
        })
        .catch((error) => {
          console.log(error);
        });
      this.showSpinner = false;
    }
  }

  /**
   *showRelatedFiles
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
