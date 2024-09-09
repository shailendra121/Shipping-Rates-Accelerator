import { LightningElement, api, track, wire } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from "lightning/navigation";
//import getDefaultPreferanceID from "@salesforce/apex/CalculateShippingEstimateCtrl.getDefaultPreferanceID";
import createDefaultRequest from "@salesforce/apex/CalculateShippingEstimateCtrl.createDefaultRequest";
import getProductList from "@salesforce/apex/CalculateShippingEstimateCtrl.fetchRecordProductList";
import fetchShippingRates from "@salesforce/apex/CalculateShippingEstimateCtrl.fetchShippingRates";
import updateRecordShippingCost from "@salesforce/apex/CalculateShippingEstimateCtrl.updateRecordShippingCost";

import {
  ACCESSORIALS_OPTIONS,
  columns,
  machinable,
  packagingTypesForFedEx,
  packagingTypesForRoadRunner,
  packagingTypesForUPS,
  packagingTypesForXPO,
  packagingTypesFprUSPS,
  serviceProvider,
  serviceTypeForRoadRunner,
  serviceTypeForXPO,
  serviceTypeForFedEx,
  serviceTypeForUPS,
  serviceTypeForUSPS,
  signatureOptions
} from "./constants";

export default class ShippingPreferenceForEstimate extends NavigationMixin(LightningElement) {
  @api recordId;
  @api preferanceID;
  @api preferenceData;
  @api shippingEstimateConfig;

  error;
  isLoading = false;
  preferanceOptions;
  @track productFields;
  //@track packagingTypesFprUSPS;

  serviceProviderOptions = serviceProvider;
  serviceTypeOptions = serviceTypeForUPS;
  packagingTypeOptions = packagingTypesForUPS;
  machinableOptions = machinable;
  signatureOptions = signatureOptions;
  accessorialOptions = ACCESSORIALS_OPTIONS;

  products;
  @track rateList = [];
  displayRates = false;
  columns = columns;

  @track selectedValuesof = {
    serviceProvider: "FedEx",
    serviceType: "All",
    packagingType: "All",
    shippingDate: new Date().toISOString().slice(0, 10),
    machinable: "true",
    accessorials: []
  };

  @track selectedValuesof = {
    serviceProvider: "XPO",
    accessorials: []
  };

  @track selectedValuesof = {
    //  preferance : '',
    serviceProvider: "UPS",
    serviceType: "All",
    packagingType: "02",
    shippingDate: new Date().toISOString().slice(0, 10),
    machinable: "true",
    accessorials: [],
    objectName: "Quote",
    pkgLst: [],
    preferanceID: "",
    recordId: "",
    recipientAddress: {
      contactPersonName: "",
      companyName: "",
      city: "",
      phoneNumber: "",
      streetLine: "",
      state: "",
      postalCode: "",
      country: "",
      isItResidentialAddress: false
    }
  };

  @wire(createDefaultRequest, { recordId: "$recordId", estimateConfigWrapper : "$shippingEstimateConfig"})
  ratingRequestHandler({ data, error }) {
    this.isLoading = true;
    //Assigning preferenceId and preferenceOptions
    if (this.preferenceData) {
      let pref = [];
      for (const objData of this.preferenceData) {
        pref = [...pref, { label: objData.Name, value: objData.Id }];
      }
      this.selectedValuesof.preferanceID = this.preferanceID;
      this.preferanceOptions = pref;
      this.selectedValuesof.recordId = this.recordId;
    }

    if (data) {
      console.log("data.4321...", data);
      this.selectedValuesof.recipientAddress = {
        contactPersonName: data.recipientAddress.contactPersonName,
        companyName: data.recipientAddress.companyName,
        city: data.recipientAddress.city,
        phoneNumber: data.recipientAddress.phoneNumber,
        streetLine: data.recipientAddress.streetLine,
        state: data.recipientAddress.state,
        postalCode: data.recipientAddress.postalCode,
        country: data.recipientAddress.country,
        isItResidentialAddress: data.recipientAddress.isItResidentialAddress
      };
      this.isLoading = false;
      console.log(
        "receipient address is",
        this.selectedValuesof.recipientAddress
      );
    } else if (error) {
      this.error = error;
      this.isLoading = false;
    }
  }

  @wire(getProductList, { recordId: "$recordId", estimateConfigWrapper : "$shippingEstimateConfig" })
  lineItems({ data, error }) {
    console.log("lineitems method is calling");
    if (data) {
      let products = [];
      this.productFields = [...data];
      console.log("Products ->" + this.productFields);
      let productArray = [];
      for (let i = 0; i < this.productFields.length; i++) {
        let packageObject = {};
        packageObject.weight = this.productFields[i].productGrossWeight;
        packageObject.insuredValue = this.productFields[i].unitPrice;

        packageObject.dimensionsLength = this.productFields[i].productLength;
        console.log("Hello Package", packageObject.dimensionsLength);
        packageObject.dimensionsWidth = this.productFields[i].productWidth;
        packageObject.dimensionsHeight = this.productFields[i].productHeight;
        packageObject.quantity = this.productFields[i].quantity;
        packageObject.productId = this.productFields[i].productId;
        packageObject.productName = this.productFields[i].productName;
        //"/apex/Example?recId=" + row[ "Id" ] + "&checkBool=true";
        packageObject.href = "/" + this.productFields[i].productId;
        packageObject.signatureOption = "NO_SIGNATURE_REQUIRED";

        products.push(packageObject);

        if (productArray.length > 0) {
          packageObject.index = productArray[productArray.length - 1].index + 1;
        } else {
          packageObject.index = 1;
        }
        productArray.push(packageObject);
      }
      this.productFields = productArray;
      this.products = products;
      this.selectedValuesof.pkgLst = this.products;
      console.log("products were populated");
      console.log("modified package list is", this.selectedValuesof.pkgLst);
    } else if (error) {
      console.log("Error from wire getLineItems : ", error);
    }
  }

  createRow(productFields) {
    let productList = this.products;
    let packageObject = {};
    packageObject.weight = null;
    packageObject.insuredValue = null;
    packageObject.dimensionsLength = null;
    packageObject.dimensionsWidth = null;
    packageObject.dimensionsHeight = null;
    packageObject.quantity = null;
    packageObject.productId = null;
    packageObject.productId = null;
    packageObject.productName = null;

    productList.push(packageObject);
    this.products = productList;
    packageObject.href = "#";
    if (productFields.length > 0) {
      packageObject.index = productFields[productFields.length - 1].index + 1;
    } else {
      packageObject.index = 1;
    }
    this.productFields = [...productFields, packageObject];
  }

  /**
   * Adds a new row
   */
  addNewRow() {
    this.createRow(this.productFields);
  }

  /**
   * Removes the selected row
   */
  removeRow(event) {
    let toBeDeletedRowIndex = event.target.name;

    let productFields = [];
    for (let i = 0; i < this.products.length; i++) {
      let tempRecord = Object.assign({}, this.products[i]); //cloning object
      if (tempRecord.index !== toBeDeletedRowIndex) {
        productFields.push(tempRecord);
      }
    }

    for (let i = 0; i < productFields.length; i++) {
      productFields[i].index = i + 1;
    }

    this.productFields = [...productFields];
    this.products = [...this.productFields];
    this.selectedValuesof.pkgLst = this.products;
  }

  handleInputChange(event) {
    let index = event.target.dataset.id;
    let fieldName = event.target.name;
    let value = event.target.value;
    for (let i = 0; i < this.products.length; i++) {
      if (this.products[i].index === parseInt(index)) {
        this.products[i][fieldName] = value;
        console.log("product index  : ", this.products[i].index);
      }
    }
  }

  handleSignatureChange(event) {
    let selectedOptionValue = event.detail.value;
    let index = event.target.name;
    this.products[index - 1].signatureOption = selectedOptionValue;
  }

  changeHandler(event) {
    const { value, name } = event.target;
    if (name.startsWith("recipientAddress.")) {
      const addressField = name.split(".")[1];
      this.selectedValuesof.recipientAddress = {
        ...this.selectedValuesof.recipientAddress,
        [addressField]: value
      };
    } else if (name == "ckeckbox") {
      const newValue = event.target.checked;
      this.selectedValuesof.recipientAddress.isItResidentialAddress = newValue;
      console.log(
        "after change isItResidentialAddress",
        this.selectedValuesof.recipientAddress.isItResidentialAddress
      );
    } else {
      this.selectedValuesof = { ...this.selectedValuesof, [name]: value };
      if (name == "preferanceID") {
        this.preferanceID = this.selectedValuesof.preferanceID;
      }
    }
    console.log("after change seleted values are => ", this.selectedValuesof);
  }
  handleAccessorialChange(e) {
    this.selectedValuesof.accessorials = e.detail.value;
  }

  hideAddressFields() {
    console.log('<<loading address component>>');
    let countryField = this.template.querySelector('.slds-form-element[data-field="country"]');
    console.log(':::countryField:::', countryField);
  }

  handleServiceType(event) {
    console.log("Carrier Name", event.target.value);
    if (event.target.value === "USPS") {
      this.serviceTypeOptions = serviceTypeForUSPS;
      this.packagingTypeOptions = packagingTypesFprUSPS;
      this.selectedValuesof.serviceProvider = "USPS";
      //console.log('service provider is',this.selectedValuesof.serviceProvider);
      this.selectedValuesof.serviceType = "PRIORITY";
      //console.log('service provider is',this.selectedValuesof.serviceType);
      this.selectedValuesof.packagingType = "VARIABLE";
      this.selectedValuesof.recordId = this.recordId;
      // console.log('service provider is',this.selectedValuesof.packagingType);
    } else if (event.target.value === "UPS") {
      this.serviceTypeOptions = serviceTypeForUPS;
      this.packagingTypeOptions = packagingTypesForUPS;
      this.selectedValuesof.serviceProvider = "UPS";
      this.selectedValuesof.serviceType = "All";
      this.selectedValuesof.packagingType = " ";
      this.selectedValuesof.recordId = this.recordId;
    } else if (event.target.value === "RoadRunner") {
      this.accessorialOptions = [
        { value: "RSD", label: "Residential Delivery" },
        { value: "RSP", label: "Residential Pickup" }
      ];
      this.serviceTypeOptions = serviceTypeForRoadRunner;
      this.packagingTypeOptions = packagingTypesForRoadRunner;
      this.selectedValuesof.serviceProvider = "RoadRunner";
      this.selectedValuesof.serviceType = "85 Freight Class";
      this.selectedValuesof.packagingType = "Pallet";
      this.selectedValuesof.recordId = this.recordId;
    } else if (event.target.value === "XPO") {
      this.serviceTypeOptions = serviceTypeForXPO;
      this.packagingTypeOptions = packagingTypesForXPO;
      this.selectedValuesof.serviceProvider = "XPO";
      this.selectedValuesof.serviceType = "85 Freight Class";
      this.selectedValuesof.packagingType = "Pallet";
      this.selectedValuesof.recordId = this.recordId;
    } else if (event.target.value === "FedEx") {
      this.serviceTypeOptions = serviceTypeForFedEx;
      this.packagingTypeOptions = packagingTypesForFedEx;
      this.selectedValuesof.serviceProvider = "FedEx";
      this.selectedValuesof.serviceType = "All";
      this.selectedValuesof.packagingType = "All";
      this.selectedValuesof.recordId = this.recordId;
    }
  }

  calculateRate() {
    this.error = "";

    //  if(!this.productFields.weight) {
    //      this.productFields.weight = 0.500;
    //  }
    console.log("hi");
    console.log(JSON.stringify(this.selectedValuesof));
    const isInputsCorrect = [
      ...this.template.querySelectorAll("lightning-input")
    ].reduce((validSoFar, inputField) => {
      inputField.reportValidity();
      return validSoFar && inputField.checkValidity();
    }, true);
    if (!isInputsCorrect) {
      return false;
    }
    console.log("hi1", isInputsCorrect);
    this.isLoading = true;
    console.log("hi3");
    console.log("this selected value", this.selectedValuesof);
    fetchShippingRates({ ratingReqWrap: this.selectedValuesof })
      .then((result) => {
        try {
          console.log("result is", result);
          console.log("selected values =>" + this.selectedValuesof);
          this.rateList = [];
          this.rateList = result;
          console.log("1111111111", this.rateList);
          // let rateList = [...result];
          // console.log(rateList);
          let index = 0;
          for (index = 0; index < result.length; index++) {
            const Charge = this.rateList[index].totalCharge.split(" ");
            const pickUpFee = this.rateList[index].alerts;
            this.rateList[index].index = index;
            //Convenience Fee is Hard Coded (5.00 USD) For All Services.
            this.rateList[index].conveniencePickupFee = "5.00" + " USD";
            this.rateList[index].totalCharge =
              parseFloat(Charge[0] + pickUpFee) + " USD";
            console.log(this.rateList[index].totalCharge);
            console.log(parseFloat(Charge[0] + pickUpFee));
          }
          console.log(JSON.stringify(this.rateList));

          this.displayRates = true;
          this.isLoading = false;
        } catch (error) {
          console.log("error" + error);
        }
      })
      .catch((error) => {
        this.error = error;
        this.isLoading = false;
      });
  }

  applyShippingRate(event) {
    this.error = "";
    this.spinner = true;
    this.isLoading = true;
    const shippingCost = event.detail.row.totalCharge;
    console.log("Hi Shipping", shippingCost);
    console.log("shippingCost : ", JSON.stringify(event.detail.row));
    let shippingEstimateConfigWrapper = JSON.parse(this.shippingEstimateConfig);
    let estimateFieldName = shippingEstimateConfigWrapper.estimateFieldToUpdate;
    if(!estimateFieldName || estimateFieldName === '' || estimateFieldName === undefined) {
      estimateFieldName = '';
    }
    
    updateRecordShippingCost({ recordId: this.recordId, estimateFieldName : estimateFieldName, totalCharge: shippingCost })
    .then((result) => {
      console.log("result is", JSON.stringify(result));
      console.log("result id is", result.Id);
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: result.Id,
          actionName: "view"
        }
      });
      this.isLoading = false;
    })
    .catch((error) => {
      this.error = error;
      this.isLoading = false;
    });
  }

  closeModal() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  get isFreight() {
    return (
      this.selectedValuesof.serviceProvider === "RoadRunner" ||
      this.selectedValuesof.serviceProvider === "XPO"
    );
  }
}