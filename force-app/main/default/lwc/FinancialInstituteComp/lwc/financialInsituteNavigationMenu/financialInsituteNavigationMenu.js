import { api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import menu from "c/navigationMenu";
import lwcResource from "@salesforce/resourceUrl/LWCResource";
export default class FinancialInsituteNavigationMenu extends NavigationMixin(
  menu
) {
  @api menuName;
  @api logoName;
  @api sectionLabel;
  @track logoUrl;
  @track isEmployeePage;
  @track isDealerPage;
  connectedCallback() {
    this.logoUrl = lwcResource + "/img/" + this.logoName;
  }

  renderedCallback() {
    if (this.menuItems && this.menuItems.length > 0 && this.currentState) {
      this.menuItems.map((item) => {
        if (
          item.label === "Employees" &&
          item.position == this.currentPosition
        ) {
          this.isEmployeePage = true;
        } else if (
          item.label === "Dealers" &&
          item.position == this.currentPosition
        ) {
          this.isDealerPage = true;
        }
        return item;
      });
    }
  }

  // Navigate to filePreview Page
  navigateToInvite(event) {
    var pageName = event.target.dataset.fieldname;
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        pageName: pageName
      },
      state: {
        position: this.currentPosition
      }
    });
  }
}
