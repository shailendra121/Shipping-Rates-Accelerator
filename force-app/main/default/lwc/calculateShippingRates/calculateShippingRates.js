import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import fetchAllShippingRates from "@salesforce/apex/CalculateShippingEstimateCtrl.fetchAllShippingRates";
import updateRecordShippingCost from "@salesforce/apex/CalculateShippingEstimateCtrl.updateRecordShippingCost";

const columns = [
    {
        label: "Service Type",
        fieldName: "serviceType",
        type: "text",
        initialWidth: 210
    },
    {
        label: "Expected Delivery Date",
        fieldName: "expectedDeliveryDate",
        type: "date",
        initialWidth: 150
    },
    {
        label: "Total Weight",
        fieldName: "totalWeight",
        type: "text",
        initialWidth: 100
    },
    {
        label: "Total Surcharge",
        fieldName: "totalSurcharge",
        type: "text",
        initialWidth: 100
    },
    {
        label: "Total Charge",
        fieldName: "totalCharge",
        type: "text",
        initialWidth: 120
    },
    {
        label: "Apply Rate",
        type: "button",
        typeAttributes: {
        label: "Apply Rate",
        title: "Apply Rate",
        disabled: false,
        variant: "brand"
        },
        initialWidth: 120,
        cellAttributes: { alignment: "center" }
    }
];

export default class CalculateShippingRates extends NavigationMixin(LightningElement) {
    @api recordId;
    @api preferanceId;
    @api shippingEstimateConfigWrapper;

    columns = columns;
    upsRates = [];
    fedexRates = [];
    uspsRates = [];
    data = [];
    activeSections = ["upsSection", "fedexSection", "uspsSection"];
    spinner = true;
    fedexNotWorking = false;

    connectedCallback() {
        fetchAllShippingRates(
            {   recordId: this.recordId,
                preferanceId: this.preferanceId,
                estimateConfigWrapper: this.shippingEstimateConfigWrapper
            }
        )
        .then((data) => {
            if (data) {
                data.forEach((element) => {
                if (element.shippingCarrier === "FedEx") {
                    this.fedexRates = element.shippingRates;
                } else if (element.shippingCarrier === "UPS") {
                    this.upsRates = element.shippingRates;
                } else if (element.shippingCarrier === "USPS") {
                    this.uspsRates = element.shippingRates;
                }
                });

                console.log("OUTPUT For FedEx: ", this.fedexRates);
                console.log("OUTPUT For USPS: ", this.uspsRates);
                console.log("OUTPUT For UPS: ", this.upsRates);
                this.spinner = false;
            }
        })
        .catch((error) => {
            console.log("OUTPUT error: ", error);
            if (error) {
            // this.handleError(error);
            }
        })
        .finally(() => {
            console.log("Inside finally: ");
            this.spinner = false;
        });
    }
    

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            mode: "dismissable",
            message: message
        });
        this.dispatchEvent(event);
    }

    applyShippingRate(event) {
        this.error = "";
        this.spinner = true;
        this.isLoading = true;
        const shippingCost = event.detail.row.totalCharge;
        console.log(":::Shipping Cost:::", shippingCost);
        let shippingEstimateConfigWrapper = JSON.parse(this.shippingEstimateConfigWrapper);
        let estimateFieldName = shippingEstimateConfigWrapper.estimateFieldToUpdate;
        if(!estimateFieldName || estimateFieldName === '' || estimateFieldName === undefined) {
            estimateFieldName = '';
        }
        console.log(this.recordId, ":::estimateFieldName:::", estimateFieldName, ":::totalCharge:::", shippingCost);

        updateRecordShippingCost({ recordId: this.recordId, estimateFieldName : estimateFieldName,  totalCharge: shippingCost })
        .then((result) => {
            console.log("result is", JSON.stringify(result));
            console.log("result id is", result.Id);
            // Navigate to the Shipment page
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: result.Id,
                    actionName: "view"
                }
            });
            this.isLoading = false;
            this.showToast("Success", "Rate applied successfully.", "success");
        })
        .catch((error) => {
            this.error = error;
            this.isLoading = false;
        });
    }
}