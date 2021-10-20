import { LightningElement, api, track } from "lwc";
import readFlows from "@salesforce/apex/LwcCustomController.readFlows";
import { NavigationMixin } from "lightning/navigation";
export default class AppplicationFlow extends NavigationMixin(
  LightningElement
) {
  @track flowData = [];
  @api recordId;

  columnNames = [
    {
      type: "url",
      fieldName: "navUrl",
      label: "Name",
      typeAttributes: { label: { fieldName: "Name" }, target: "_self" }
    },
    {
      type: "text",
      fieldName: "dau01__FlowName__c",
      label: "Flow Name"
    },
    {
      type: "text",
      fieldName: "dau01__Status__c",
      label: "Status"
    },
    {
      type: "text",
      fieldName: "dau01__ServiceName__c",
      label: "Sercice Name"
    }
  ];

  connectedCallback() {
    this.fetchFlows();
  }

  fetchFlows() {
    readFlows({ params: { recordId: this.recordId } })
      .then((result) => {
        if (result.status === 200) {
          console.log("result : " + JSON.stringify(result));
          this.flowData = result.data;
          this.flowData.forEach((element) => {
            if (element?.dau01__SubFlows__r) {
              element._children = element.dau01__SubFlows__r;
              delete element.dau01__SubFlows__r;
              element._children.forEach((childElement) => {
                childElement.navUrl =
                  window.location.origin + "\\" + childElement.Id;
              });
            }
            element.navUrl = window.location.origin + "\\" + element.Id;
          });
        }
      })
      .catch((error) => {
        console.log("Error : " + JSON.stringify(error));
      });
  }
}
