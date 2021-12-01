import { LightningElement, track, api } from "lwc";
import timezone from "@salesforce/i18n/timeZone";

//controller
import fetchFieldDetails from "@salesforce/apex/LwcCustomController.fetchFieldDetails";

export default class RecordDetailView extends LightningElement {
  @api record;
  @api sObjectName;
  @api filedSetName;
  @api titleName;
  @api hideHeader = false;
  @api hideNullValues = false;
  results = [];
  @track dataLoaded = false;

  renderedCallback() {
    //console.log("Child renderedCallback::: " + JSON.stringify(this.record.Id));
    if (this.record && !this.dataLoaded) {
      //console.log("Child this.record ::: " + JSON.stringify(this.record));
      fetchFieldDetails({
        params: {
          sObjectName: this.sObjectName,
          filedSetName: this.filedSetName
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
    }
  }
}
