export const ACCESSORIALS_OPTIONS = [
    { value: "RSD", label: "Residential Delivery" },
    { value: "RSP", label: "Residential Pickup" },
    { value: "DLG", label: "Liftgate Service" },
    { value: "DID", label: "Inside Delivery" }
  ];
  
  export const columns = [
    { label: "Service Type", fieldName: "serviceType" },
    { label: "TotalWeight", fieldName: "totalWeight" },
    {
      label: "Expected Delivery Date",
      fieldName: "expectedDeliveryDate",
      type: "date"
    },
    { label: "Convenience & Pickup Fee", fieldName: "conveniencePickupFee" },
    { label: "TotalCharge", fieldName: "totalCharge" },
    {
      type: "button",
      typeAttributes: {
        label: "Apply Shipping Rate",
        name: "applyShippingRate",
        title: "Apply Shipping Rate",
        disabled: false,
        value: "index",
        iconPosition: "left"
      }
    }
  ];
  export const serviceProvider = [
    { label: "FedEx", value: "FedEx" },
    { label: "UPS", value: "UPS" },
    { label: "USPS", value: "USPS" },
    { label: "Road Runner", value: "RoadRunner" },
    { label: "XPO", value: "XPO" }
  ];
  
  export const serviceTypeForFedEx = [
    { label: "Get All Rates", value: "All" },
    { label: "FEDEX_GROUND", value: "FEDEX_GROUND" },
    { label: "GROUND_HOME_DELIVERY", value: "GROUND_HOME_DELIVERY" },
    { label: "EXPRESS_SAVER", value: "EXPRESS_SAVER" },
    { label: "PRIORITY_OVERNIGHT", value: "PRIORITY_OVERNIGHT" },
    { label: "FIRST_OVERNIGHT", value: "FIRST_OVERNIGHT" },
    { label: "STANDARD_OVERNIGHT", value: "STANDARD_OVERNIGHT" },
    { label: "2_DAY", value: "2_DAY" },
    { label: "2_DAY_AM", value: "2_DAY_AM" },
    { label: "FEDEX_1_DAY_FREIGHT", value: "FEDEX_1_DAY_FREIGHT" },
    { label: "FEDEX_FIRST_FREIGHT", value: "FEDEX_FIRST_FREIGHT" },
    { label: "FEDEX_2_DAY_FREIGHT", value: "FEDEX_2_DAY_FREIGHT" },
    { label: "FEDEX_3_DAY_FREIGHT", value: "FEDEX_3_DAY_FREIGHT" }
  ];
  
  export const serviceTypeForXPO = [
    { label: "85 Freight Class", value: "85 Freight Class" },
    { label: "Get All Rates", value: "All" }
  ];
  
  export const serviceTypeForUPS = [
    { label: "Get All Rates", value: "All" },
    { label: "Next Day Air", value: "01" },
    { label: "2nd Day Air", value: "02" },
    { label: "Ground", value: "03" },
    { label: "Worldwide Express", value: "07" },
    { label: "Worldwide Expedited", value: "08" },
    { label: "Standard", value: "11" },
    { label: "3 Day Select", value: "12" },
    { label: "Next Day Air Saver", value: "13" },
    { label: "UPS Next Day Air Early", value: "14" },
    { label: "Worldwide Express Plus", value: "54" },
    { label: "2nd Day Air A.M.", value: "59" },
    { label: "Saver", value: "65" },
    { label: "UPS Worldwide Express Freight Midday", value: "71" },
    { label: "UPS Worldwide Express Freight", value: "96" }
  ];
  
  export const serviceTypeForUSPS = [
    { label: "PRIORITY", value: "PRIORITY" },
    { label: "PRIORITY EXPRESS", value: "PRIORITY EXPRESS" },
    { label: "PRIORITY MAIL CUBIC", value: "PRIORITY MAIL CUBIC" },
    { label: "PARCEL SELECT GROUND", value: "PARCEL SELECT GROUND" },
    { label: "LIBRARY", value: "LIBRARY" },
    { label: "MEDIA", value: "MEDIA" },
    { label: "BPM", value: "BPM" },
    { label: "FIRST CLASS: LETTER", value: "FIRST CLASS: LETTER" },
    { label: "FIRST CLASS: FLAT", value: "FIRST CLASS: FLAT" },
    {
      label: "FIRST CLASS: PACKAGE SERVICE RETAIL",
      value: "FIRST CLASS: PACKAGE SERVICE RETAIL"
    },
    { label: "FIRST CLASS: POSTCARD", value: "FIRST CLASS: POSTCARD" },
    {
      label: "FIRST CLASS: PACKAGE SERVICE",
      value: "FIRST CLASS: PACKAGE SERVICE"
    }
  ];
  export const machinable = [
    { label: "Yes", value: "true" },
    { label: "No", value: "false" }
  ];
  
  export const packagingTypesForFedEx = [
    { label: "Get All Rates", value: "All" },
    { label: "FEDEX_BOX", value: "FEDEX_BOX" },
    { label: "FEDEX_ENVELOPE", value: "FEDEX_ENVELOPE" },
    { label: "FEDEX_PAK", value: "FEDEX_PAK" },
    { label: "FEDEX_TUBE", value: "FEDEX_TUBE" },
    { label: "FEDEX_10KG_BOX", value: "FEDEX_25KG_BOX" },
    { label: "FEDEX_EXTRA_LARGE_BOX", value: "FEDEX_EXTRA_LARGE_BOX" },
    { label: "FEDEX_LARGE_BOX", value: "FEDEX_LARGE_BOX" },
    { label: "FEDEX_MEDIUM_BOX", value: "FEDEX_MEDIUM_BOX" },
    { label: "FEDEX_SMALL_BOX", value: "FEDEX_SMALL_BOX" }
  ];
  
  export const packagingTypesForUPS = [
    { label: "Customer Supplied Package", value: "02" },
    { label: "Express Box", value: "21" },
    { label: "25KG Box", value: "24" },
    { label: "10KG Box", value: "25" },
    { label: "UPS Express Box - Small", value: "2a" },
    { label: "UPS Express Box - Medium", value: "2b" },
    { label: "UPS Express Box - Large", value: "2c" },
    { label: "UPS Letter", value: "01" },
    { label: "UPS Tube", value: "03" },
    { label: "Pallet", value: "30" },
    { label: "Flats", value: "56" },
    { label: "Parcels", value: "57" },
    { label: "BPM", value: "58" },
    { label: "First Class", value: "59" },
    { label: "Priority", value: "60" },
    { label: "Machineables", value: "61" },
    { label: "Irregulars", value: "62" },
    { label: "Parcel Post", value: "63" },
    { label: "BPM Parcel", value: "64" },
    { label: "Media Mail", value: "65" },
    { label: "BPM Flat", value: "66" },
    { label: "Standard Flat", value: "67" }
  ];
  
  export const packagingTypesFprUSPS = [
    { label: "VARIABLE", value: "VARIABLE" },
    { label: "CUBIC PARCELS", value: "CUBIC PARCELS" },
    { label: "CUBIC SOFT PACK", value: "CUBIC SOFT PACK" },
    { label: "FLAT RATE ENVELOPE", value: "FLAT RATE ENVELOPE" },
    {
      label: "GIFT CARD FLAT RATE ENVELOPE",
      value: "GIFT CARD FLAT RATE ENVELOPE"
    },
    { label: "LEGAL FLAT RATE ENVELOPE", value: "LEGAL FLAT RATE ENVELOPE" },
    { label: "LG FLAT RATE BOX", value: "LG FLAT RATE BOX" },
    { label: "MD FLAT RATE BOX", value: "MD FLAT RATE BOX" },
    { label: "PADDED FLAT RATE ENVELOPE", value: "PADDED FLAT RATE ENVELOPE" },
    { label: "REGIONALRATEBOXA", value: "REGIONALRATEBOXA" },
    { label: "REGIONALRATEBOXB", value: "REGIONALRATEBOXB" },
    { label: "SM FLAT RATE BOX", value: "SM FLAT RATE BOX" },
    { label: "SM FLAT RATE ENVELOPE", value: "SM FLAT RATE ENVELOPE" },
    { label: "WINDOW FLAT RATE ENVELOPE", value: "WINDOW FLAT RATE ENVELOPE" }
  ];
  export const packagingTypesForRoadRunner = [
    { label: "Pallet", value: "Pallet" }
  ];
  export const packagingTypesForXPO = [{ label: "Pallet", value: "Pallet" }];
  export const serviceTypeForRoadRunner = [
    { label: "50 Freight Class", value: "50 Freight Class" },
    { label: "55 Freight Class", value: "55 Freight Class" },
    { label: "60 Freight Class", value: "60 Freight Class" },
    { label: "65 Freight Class", value: "65 Freight Class" },
    { label: "77.5 Freight Class", value: "77.5 Freight Class" },
    { label: "85 Freight Class", value: "85 Freight Class" },
    { label: "92.5 Freight Class", value: "92.5 Freight Class" },
    { label: "100 Freight Class", value: "100 Freight Class" },
    { label: "110 Freight Class", value: "110 Freight Class" },
    { label: "125 Freight Class", value: "125 Freight Class" },
    { label: "150 Freight Class", value: "150 Freight Class" },
    { label: "175 Freight Class", value: "175 Freight Class" },
    { label: "200 Freight Class", value: "200 Freight Class" },
    { label: "250 Freight Class", value: "250 Freight Class" },
    { label: "300 Freight Class", value: "300 Freight Class" },
    { label: "400 Freight Class", value: "400 Freight Class" },
    { label: "500 Freight Class", value: "500 Freight Class" }
  ];
  
  export const signatureOptions = [
    { label: "NO SIGNATURE", value: "NO_SIGNATURE_REQUIRED" },
    { label: "Signature Required", value: "DC-SR" },
    { label: "Adult Signature Required", value: "DC-ASR" }
  ];