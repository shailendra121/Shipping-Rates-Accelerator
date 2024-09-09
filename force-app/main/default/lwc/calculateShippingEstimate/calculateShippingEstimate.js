import { LightningElement, api, track, wire } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from "lightning/navigation";
import getShippingEstimateConfigDetail from "@salesforce/apex/CalculateShippingEstimateCtrl.getShippingEstimateConfigDetail";

export default class CalculateShippingEstimate extends NavigationMixin(LightningElement) {
  @api recordId;
  error;
  isLoading = false;
  preferenceData;
  defaultPreferanceID;
  showDisplayReviewScreen = false;
  hasShippingEstimateConfiguration = false;
  shippingEstimateConfig;

  @wire(getShippingEstimateConfigDetail, { recordId: "$recordId"})
  getShippingEstimateConfigDetail({ data, error }) {
    this.isLoading = true;
    if (data) {
      console.log("data.4321...", data);
      this.showDisplayReviewScreen = data.showDisplayReviewScreen;
      this.shippingEstimateConfig = data.shippingEstimateConfig;
      //console.log(':::wrapper::', this.shippingEstimateConfig);
      this.hasShippingEstimateConfiguration = true;
      if(data.shippingPreferances) {
        this.preferenceData = data.shippingPreferances;
        for (const objData of data.shippingPreferances) {
          if (objData.Astonous_SM__Default__c == true) {
            this.defaultPreferanceID = objData.Id;
          }
        }
      }
      this.isLoading = false;
    } else if (error) {
      this.error = error;
      this.isLoading = false;
    }
  }
}