import { api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import menu from "c/navigationMenu";
import lwcResource from "@salesforce/resourceUrl/LWCResource";
import FORM_FACTOR from "@salesforce/client/formFactor";
export default class FinancialInsituteNavigationMenu extends NavigationMixin(menu) {
  @api menuName;
  @api logoName;
  @api sectionLabel;
  @api hideMenuLabel = false;
  @track logoUrl;
  connectedCallback() {
    this.logoUrl = lwcResource + "/img/" + this.logoName;
    if (FORM_FACTOR) {
      if (FORM_FACTOR == "Small") {
        this.hideMenuLabel = true;
      }
    }
  }
}
