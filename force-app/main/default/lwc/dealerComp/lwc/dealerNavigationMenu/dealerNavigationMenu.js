import { api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import menu from "c/navigationMenu";
import lwcResource from "@salesforce/resourceUrl/LWCResource";
export default class DealerNavigationMenu extends NavigationMixin(menu) {
  @api menuName;
  @api logoName;
  @api sectionLabel;
  @track logoUrl;
  @track isEmployeePage;
  connectedCallback() {
    this.logoUrl = lwcResource + "/img/" + this.logoName;
  }

  renderedCallback() {
    if (this.menuItems && this.currentState) {
      const result = this.menuItems.find(({ label, position }) => {
        return label === "Employees" && position == this.currentPosition;
      });
      if (result) {
        this.isEmployeePage = true;
      }
    }
  }

  // Navigate to filePreview Page
  navigateToInvite() {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        pageName: "EmployeeInvite"
      },
      state: {
        position: this.currentPosition
      }
    });
  }
}
