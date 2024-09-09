/*
* Controller class for calculateShippingEstimate, shippingPreferenceForEstimate and calculateShippingRates lightning web components
*/
public with sharing class CalculateShippingEstimateCtrl {
    private static final String FedEx = 'FedEx';
    private static final String UPS = 'UPS';
    private static final String USPS = 'USPS';
    private static final String ROADRUNNER = 'RoadRunner';
    private static final String XPO = 'XPO';
    private static final String OPPORTUNITY_STR = 'Opportunity';
    private static final String SHIPPING = 'Shipping';
  
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getShippingEstimateConfigDetail(ID recordId) {
      Map<String, Object> resMap = new Map<String, Object>();
      String objectName = String.valueOf(recordId.getSobjectType());
      Shipping_Estimate_Configuration__c config = [SELECT Id, Field_Details_w_Json_Format__c , Display_Review_Screen__c
                                                      FROM Shipping_Estimate_Configuration__c 
                                                      WHERE SObject_Name__c = :objectName limit 1];
      if(config != NULL && config.Field_Details_w_Json_Format__c != NULL) {
        resMap.put('showDisplayReviewScreen', config.Display_Review_Screen__c);
        ShippingEstimateWrapper wrapper = (ShippingEstimateWrapper)JSON.deserialize(config.Field_Details_w_Json_Format__c, ShippingEstimateWrapper.class);
        resMap.put('shippingEstimateConfig', JSON.serialize(wrapper));

        List<Astonous_SM__Shipping_Preference__c> shippingPreferances = [SELECT id, Name, Astonous_SM__City__c, Astonous_SM__Default__c
                                                                            FROM Astonous_SM__Shipping_Preference__c
                                                                          ];
        resMap.put('shippingPreferances', shippingPreferances);
      }else {
        throw new CustomException('Shipping Estimate Configuration is not configured for the related object.');
      }
      return resMap;
    }


    
    //Methods are calling from ShippingPreferenceEstimate LWC
    @AuraEnabled(cacheable=true)
    public static ShippingRatingRequestWrapper createDefaultRequest(ID recordId, String estimateConfigWrapper) {
      System.debug(recordId);
      ShippingRatingRequestWrapper ratingRef = new ShippingRatingRequestWrapper();
      ShippingEstimateWrapper wrapper = (ShippingEstimateWrapper) JSON.deserialize(estimateConfigWrapper, ShippingEstimateWrapper.class); //fetchShipmentEstimateConfig(objectName);
      if(wrapper != NULL) {
        SObject sobjectRecord = getRecordDetail(recordId, wrapper);
        if(sobjectRecord != null) {
          ratingRef.recipientAddress = getRecipientAddressForSobject(sobjectRecord, wrapper.shipTo);
          validateAddress('Recipient Address ', ratingRef.recipientAddress);
        }
      }
      return ratingRef;
    }

    @AuraEnabled(cacheable=true)
    public static List<ShippingProductWrapper> fetchRecordProductList(id recordId, String estimateConfigWrapper) {
      List<ShippingProductWrapper> productWrapperList = new List<ShippingProductWrapper>();
      Map<Id, Decimal> productIdAndQuantityMap = new Map<Id, Decimal>();
      String objectName = String.valueOf(recordId.getSobjectType());
      ShippingEstimateWrapper wrapper = (ShippingEstimateWrapper) JSON.deserialize(estimateConfigWrapper, ShippingEstimateWrapper.class); //fetchShipmentEstimateConfig(objectName);
      if(wrapper != NULL) {
        List<SObject> lstRecords = getChildProductRecords(recordId, wrapper);
        if(lstRecords.size() > 0) {
          Map<String, String> mapRelFields = wrapper.childRelationship.fields;
          for(SObject sRecord : lstRecords) {
            productIdAndQuantityMap.put((String)sRecord.get(mapRelFields.get('ProductId')), (Decimal)sRecord.get(mapRelFields.get('Quantity')));
          }
        }
        
        String parentRecQueryStr = 'SELECT Id, ' + wrapper.priceBookFieldName
                                    + ' FROM ' + objectName
                                    + ' WHERE Id  = \''+ recordId + '\''
                                    + ' WITH SECURITY_ENFORCED ';
        List<SObject> lstParentRecords = Database.query(parentRecQueryStr);
        Id priceBookId;
        if(lstParentRecords.size() > 0) {
          priceBookId = (Id)lstParentRecords.get(0).get(wrapper.priceBookFieldName);
        }
        Map<id, Product2> productMap = new Map<Id, Product2>([SELECT Id, Name, Product_Gross_Weight__c, Product_Length__c, Product_Width__c, Product_Height__c
                                                                FROM Product2
                                                                WHERE Id IN :productIdAndQuantityMap.keySet() AND Name != :SHIPPING
                                                                WITH SECURITY_ENFORCED
                                                              ]);

        for (PricebookEntry pricebookEntry : [SELECT Pricebook2Id, Product2Id, UnitPrice
                                                FROM PricebookEntry
                                                WHERE Product2Id IN :productMap.keySet()
                                                AND Pricebook2Id = :priceBookId
                                                WITH SECURITY_ENFORCED]) {
          Product2 productRecord = productMap.get(pricebookEntry.Product2Id);
          productWrapperList.add(
            new ShippingProductWrapper(productRecord,
                                        pricebookEntry.UnitPrice,
                                        productIdAndQuantityMap.get(productRecord.Id),
                                        productRecord.Id,
                                        productRecord.Name
                                      )
          );
        }
      }
      return productWrapperList;
    }

    //String preferanceID, String isMachinable, String shippingCarrier, String serviceType, String packagingType, String recordId, Date shipDate, List<Astonous_SM.RatingRequest.ShippingPackage> pkgLst, List<String> accessorials,String objectName
    @AuraEnabled
    public static List<Astonous_SM.ShippingRate> fetchShippingRates(ShippingRatingRequestWrapper ratingReqWrap) {
      string prefId = ratingReqWrap.preferanceID;
      Astonous_SM.RatingRequest rr = new Astonous_SM.RatingRequest();
      System.debug('ratingReqWrap.serviceType' + ratingReqWrap.serviceType);
      rr.serviceType = ratingReqWrap.serviceType;
      System.debug('rr.serviceType' + rr.serviceType);
      rr.shippingCarrier = ratingReqWrap.serviceProvider;
      System.debug('serviceProvider' + rr.shippingCarrier);
      //rr.GoodsDescription = 'Astonous';
      rr.packagingType = ratingReqWrap.packagingType;

      if (UPS.equalsIgnoreCase(ratingReqWrap.serviceProvider)) {
        rr.weightUnit = 'LBS';
        rr.linearUnit = 'IN';
        rr.dropoffType = '03';
        rr.packageBillType = '03';
        rr.labelType = 'PNG';
      } else if (USPS.equalsIgnoreCase(ratingReqWrap.serviceProvider)) {
        rr.weightUnit = 'LB';
        rr.linearUnit = 'IN';
        rr.dropoffType = 'REGULAR_PICKUP';
        rr.machinable = ratingReqWrap.machinable;
        rr.labelType = 'PDF';
      } else if (ROADRUNNER.equalsIgnoreCase(ratingReqWrap.serviceProvider)) {
        // ROAD Runner
        rr.weightUnit = 'LB';
        rr.linearUnit = 'IN';
        rr.labelType = 'PDF';
      } else if (XPO.equalsIgnoreCase(ratingReqWrap.serviceProvider)) {
        //XPO
        rr.weightUnit = 'LBS';
        rr.linearUnit = 'IN';
        rr.labelType = 'PDF';
      } else if (FedEx.equalsIgnoreCase(ratingReqWrap.serviceProvider)) {
        //FedEx
        rr.weightUnit = 'LB';
        rr.linearUnit = 'IN';
        rr.packagingType = 'YOUR_PACKAGING';
        rr.dropoffType = 'REGULAR_PICKUP';
        rr.signatureOption = 'SERVICE_DEFAULT';
      }

      rr.recipientInfomration = ratingReqWrap.recipientAddress;
      System.debug('recipientInformation' + rr.recipientInfomration);
      validateAddress('Recipient Address ', rr.recipientInfomration);
      rr.currencyUnit = 'USD';
      rr.senderInfomration = getPreferanceRecord(ratingReqWrap.preferanceID);
      validateAddress('Sender Address ', rr.senderInfomration);
      System.debug('rrSender' + rr.senderInfomration);
      rr.shipDate = ratingReqWrap.shippingDate;
      System.debug('ShipDate' + rr.shipDate);
      Decimal quantity = 0;

      for (Astonous_SM.RatingRequest.ShippingPackage pkg : ratingReqWrap.pkgLst) {
        pkg.weight = pkg.quantity * pkg.weight;
        System.debug('pkg.weight' + pkg.weight);
        quantity = quantity + Decimal.valueOf(pkg.quantity);

        System.debug(pkg.quantity);

        if (String.isNotBlank(pkg.insuredValue)) {
          pkg.insuredValue = String.valueOf(
            pkg.quantity * Decimal.valueOf(pkg.insuredValue)
          );
        }
      }
      rr.packageList = ratingReqWrap.pkgLst;
      system.debug('Quantity ' + quantity);

      System.debug('rr =>' + rr);
      List<Astonous_SM.ShippingRate> lstRates = Astonous_SM.ShippingController.fetchAllShippingRates(
        rr
      );

      if (USPS.equalsIgnoreCase(ratingReqWrap.serviceProvider)) {
        List<Astonous_SM.ShippingRate> uspsCombinedRates = new List<Astonous_SM.ShippingRate>();
        Astonous_SM.ShippingRate uspsRate = new Astonous_SM.ShippingRate();
        Decimal charge = 0;
        Decimal weight = 0;
        for (Astonous_SM.ShippingRate rate : lstRates) {
          weight += Decimal.valueOf(rate.totalWeight);
          charge += Decimal.valueOf(rate.totalCharge);
          uspsRate.serviceType = rate.serviceType;
        }
        uspsRate.totalWeight = String.valueOf(weight);
        uspsRate.totalCharge = String.valueOf(charge);
        uspsCombinedRates.add(uspsRate);
        lstRates = uspsCombinedRates;
      }

      system.debug('rates are' + lstRates);
      return lstRates;
    }

    @AuraEnabled
    public static List<CalcShipRateWrapper> fetchAllShippingRates(String recordId, String preferanceId, String estimateConfigWrapper){
      List<CalcShipRateWrapper> toReturnInstance = new List<CalcShipRateWrapper>();
      ShippingEstimateWrapper wrapper = (ShippingEstimateWrapper) JSON.deserialize(estimateConfigWrapper, ShippingEstimateWrapper.class);
      try {
        CalcShipRateWrapper upsData = new CalcShipRateWrapper();
        upsData.shippingCarrier = UPS;
        upsData.shippingRates = getShippingRatesByCarrier(recordId, preferanceId, UPS, wrapper);
        toReturnInstance.add(upsData);

        CalcShipRateWrapper fedExData = new CalcShipRateWrapper();
        fedExData.shippingCarrier = FedEx;
        fedExData.shippingRates = getShippingRatesByCarrier(recordId, preferanceId, FedEx, wrapper);
        toReturnInstance.add(fedExData);

        CalcShipRateWrapper uspsData = new CalcShipRateWrapper();
        uspsData.shippingCarrier = USPS;
        uspsData.shippingRates = getShippingRatesByCarrier(recordId, preferanceId, USPS, wrapper);
        toReturnInstance.add(uspsData);
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
      return toReturnInstance;
    }
    
    private static List<Astonous_SM.ShippingRate> getShippingRatesByCarrier(Id recordId, String preferanceId, String shippingCarrier, ShippingEstimateWrapper wrapper) {
      List<Astonous_SM.ShippingRate> lstRates;
      SObject sobjectRecord = getRecordDetail(recordId, wrapper);
      List<Astonous_SM.RatingRequest.ShippingPackage> pkgLst = new List<Astonous_SM.RatingRequest.ShippingPackage>();
      try {
        if(sobjectRecord != null) {
          Decimal totalWeight = 0;
          Astonous_SM.RatingRequest rr = new Astonous_SM.RatingRequest();
          rr.serviceType = 'All';
          rr.shippingCarrier = shippingCarrier;
          //rr.GoodsDescription = (String)sobjectRecord.get('name');
          rr.recipientInfomration =  getRecipientAddressForSobject(sobjectRecord, wrapper.shipTo);
          rr.recipientInfomration.isItResidentialAddress = false;
          rr.currencyUnit = 'USD';
          rr.shipDate = System.today();
    
          rr.senderInfomration = getPreferanceRecord(preferanceId);
          List<SObject> lstChildRecords = getChildProductRecords(recordId, wrapper);
          if(lstChildRecords.size() > 0) {
            for (SObject childRec : lstChildRecords) {
              Astonous_SM.RatingRequest.ShippingPackage pkg = new Astonous_SM.RatingRequest.ShippingPackage();
              Decimal prodQuantity = (Decimal)childRec.get('Quantity');
              pkg.quantity = Integer.valueOf(prodQuantity);
              pkg.weight = 1;
              totalWeight = totalWeight + pkg.weight;
              pkgLst.add(pkg);
            }
          }
          rr.packageList = pkgLst;
          rr.totalWeight = String.valueOf(totalWeight);
          if(shippingCarrier == UPS) {
            rr.weightUnit = 'LBS';
            rr.linearUnit = 'IN';
            rr.packagingType = '02';
            rr.dropoffType = '03';
            rr.packageBillType = '03';
    
            lstRates = Astonous_SM.ShippingController.fetchAllShippingRates(rr);
          }else if(shippingCarrier == FedEx) {
            rr.weightUnit = 'LB';
            rr.linearUnit = 'IN';
            rr.packagingType = 'YOUR_PACKAGING';
            rr.dropoffType = 'REGULAR_PICKUP';
            rr.signatureOption = 'SERVICE_DEFAULT';
    
            lstRates = Astonous_SM.ShippingController.fetchAllShippingRates(rr);
          }else if(shippingCarrier == USPS) {
            rr.weightUnit = 'LB';
            rr.linearUnit = 'IN';
            rr.dropoffType = 'REGULAR_PICKUP';
            rr.serviceType = 'PRIORITY';
            rr.packagingType = 'VARIABLE';
            rr.machinable = 'TRUE';
    
            lstRates = Astonous_SM.ShippingController.fetchAllShippingRates(rr);
            List<Astonous_SM.ShippingRate> uspsCombinedRates = new List<Astonous_SM.ShippingRate>();
            Astonous_SM.ShippingRate uspsRate = new Astonous_SM.ShippingRate();
            Decimal charge = 0;
            Decimal weight = 0;
            for (Astonous_SM.ShippingRate rate : lstRates) {
              weight += Decimal.valueOf(rate.totalWeight);
              charge += Decimal.valueOf(rate.totalCharge);
              uspsRate.serviceType = rate.serviceType;
            }
            uspsRate.totalWeight = String.valueOf(weight);
            uspsRate.totalCharge = String.valueOf(charge);
            uspsCombinedRates.add(uspsRate);
            lstRates = new List<Astonous_SM.ShippingRate>();
            lstRates.addAll(uspsCombinedRates);
          }
        }
        System.debug(':::lstRates:::' + lstRates);
      }catch (Exception e) {
        System.debug('The following exception has occurred: ' + e.getMessage());
      }
      return lstRates;
    }

    private static SObject getRecordDetail(ID recordId, ShippingEstimateWrapper wrapper) {
      String objectName = String.valueOf(recordId.getSobjectType());
      String sobjectQueryStr = '';
      Set<String> setFieldsToQuery = new Set<String>();
      List<SObject> lstRecords;
      if(wrapper.shipTo != null && !wrapper.shipTo.isEmpty()) {
        for(String fieldName : wrapper.shipTo.values()) {
          if(String.isNotBlank(fieldName) && !setFieldsToQuery.contains(fieldName)) {
            setFieldsToQuery.add(fieldName);
          }
          List<String> lstFieldNames = new List<String>();
          lstFieldNames.addAll(setFieldsToQuery);
          sobjectQueryStr = String.join(lstFieldNames, ',');
        }

        sobjectQueryStr = sobjectQueryStr.removeEnd(',');
        sobjectQueryStr = 'SELECT ' + sobjectQueryStr 
                          + ' FROM ' + objectName
                          + ' WHERE id = \'' + recordId + '\''
                          + ' WITH SECURITY_ENFORCED ';
        System.debug(':::sobjectQueryStr:::' + sobjectQueryStr);
        lstRecords = Database.query(sobjectQueryStr);
      }
      if(lstRecords != null && lstRecords.size() > 0) {
        return lstRecords.get(0);
      }
      return null;
    }

    private static List<SObject> getChildProductRecords(Id recordId, ShippingEstimateWrapper wrapper) {
      String sobjectQueryStr = '';
      Set<String> setFieldsToQuery = new Set<String>();
      String objectName = String.valueOf(recordId.getSobjectType());
      List<SObject> lstRecords;
      if(wrapper.childRelationship != null && wrapper.childRelationship.fields != null && !wrapper.childRelationship.fields.isEmpty()) {
        for(String fieldName : wrapper.childRelationship.fields.values()) {
          if(!setFieldsToQuery.contains(fieldName)) {
            setFieldsToQuery.add(fieldName);
          }
          List<String> lstFieldNames = new List<String>();
          lstFieldNames.addAll(setFieldsToQuery);
          sobjectQueryStr = String.join(lstFieldNames, ',');
        }

        sobjectQueryStr = sobjectQueryStr.removeEnd(',');
        sobjectQueryStr = 'SELECT ' + sobjectQueryStr 
                          + ' FROM ' + wrapper.childRelationship.name
                          + ' WHERE ' + wrapper.childRelationship.parentFieldId +' = \'' + recordId + '\''
                          + ' WITH SECURITY_ENFORCED ';
        lstRecords = Database.query(sobjectQueryStr);
      }
      return lstRecords;
    }

    @AuraEnabled
    public static SObject updateRecordShippingCost(String recordId, String estimateFieldName, String totalCharge) {
      SObject recToUpdate;
      try {
        if(String.isBlank(estimateFieldName)) {
          throw new CustomException('Estimate Shipping Cost field property is missing in Shipping Estimate Configuration.');
        }
        System.debug('totalCharge' + totalCharge);
        List<String> shippingCostWithCurrency = totalCharge.split(' ');
        System.debug('HEy shipping cost' + shippingCostWithCurrency);
        Decimal shippingCost = Decimal.valueOf(shippingCostWithCurrency[0]);
        System.debug('Hey Shipingcost' + shippingCost);

        // Put the Id's and associated name values in the map
        List<SObject> sObjectsToUpdate = new List<SObject>();
        Id idToUpdate = (ID)recordId;
        recToUpdate = idToUpdate.getSObjectType().newSObject(idToUpdate);
        // Set the Name field dynamically
        recToUpdate.put(estimateFieldName, shippingCost);
        //sObjectsToUpdate.add(recToUpdate);
        update recToUpdate;

      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
      System.debug('Record to update is:::' + recToUpdate);
      return recToUpdate;
    }
  
    private static Astonous_SM.Address getPreferanceRecord(String preferanceID) {
      List<Astonous_SM__Shipping_Preference__c> preferenceList = [
        SELECT
          ID,
          Name,
          Astonous_SM__Company__c,
          Astonous_SM__Contact_Person_Name__c,
          Astonous_SM__City__c,
          Astonous_SM__Country__c,
          Astonous_SM__Email__c,
          Astonous_SM__Is_it_Residential_Address__c,
          Astonous_SM__Phone__c,
          Astonous_SM__Postal_Code__c,
          Astonous_SM__State__c,
          Astonous_SM__Street__c
        FROM Astonous_SM__Shipping_Preference__c
        WHERE ID = :preferanceID
      ];
      Astonous_SM.RatingRequest rr = new Astonous_SM.RatingRequest();
      Astonous_SM.Address addressInstance = rr.recipientInfomration;
      addressInstance.city = preferenceList[0].Astonous_SM__City__c;
      addressInstance.contactPersonName = preferenceList[0].Astonous_SM__Contact_Person_Name__c;
      addressInstance.email = preferenceList[0].Astonous_SM__Email__c;
      addressInstance.companyName = preferenceList[0].Astonous_SM__Company__c;
      addressInstance.phoneNumber = preferenceList[0].Astonous_SM__Phone__c;
      addressInstance.streetLine = preferenceList[0].Astonous_SM__Street__c;
      addressInstance.state = preferenceList[0].Astonous_SM__State__c;
      addressInstance.country = preferenceList[0].Astonous_SM__Country__c;
      addressInstance.postalCode = preferenceList[0].Astonous_SM__Postal_Code__c;
      return addressInstance;
    }

    public static void validateAddress(String addressType, Astonous_SM.Address addressInstance) {
      if (String.isBlank(addressInstance.contactPersonName)) {
        throw new CustomException(addressType + ': Contact person name missing.');
      } else if (String.isBlank(addressInstance.city)) {
        throw new CustomException(addressType + ': City is missing.');
      } else if (String.isBlank(addressInstance.phoneNumber)) {
        throw new CustomException(addressType + ': Phone number is missing.');
      } else if (String.isBlank(addressInstance.state)) {
        throw new CustomException(addressType + ': State is missing.');
      } else if (String.isBlank(addressInstance.postalCode)) {
        throw new CustomException(addressType + ': Postal Code is missing.');
      } else if (String.isBlank(addressInstance.country)) {
        throw new CustomException(addressType + ': Country is missing.');
      } else if (String.isBlank(addressInstance.streetLine)) {
        throw new CustomException(addressType + ': Address Street is missing.');
      }
    }

    public static Astonous_SM.Address getRecipientAddressForSobject(SObject record, Map<String, String> sobjectFields) {
      System.debug('::::record:::' + record);
      Astonous_SM.RatingRequest rr = new Astonous_SM.RatingRequest();
      Astonous_SM.Address addressInstance = rr.recipientInfomration;
      Map<String, Object> addressMap = new Map<String, Object>();
      for(String fieldParam : sobjectFields.keySet()) {
        if(String.isNotBlank(sobjectFields.get(fieldParam)) && fieldParam != 'recordId' && fieldParam != 'ShippingCost') {
          addressMap.put(fieldParam, (String)record.get(sobjectFields.get(fieldParam)));
        }
      }
      addressMap.put('isItResidentialAddress', true);
      addressInstance = (Astonous_SM.Address)JSON.deserialize(JSON.serialize(addressMap), Astonous_SM.Address.class);
      return addressInstance;
    }

    public class CustomException extends Exception {
    }

    public class CalcShipRateWrapper {
      @AuraEnabled
      public List<Astonous_SM.ShippingRate> shippingRates { get; set; }
      @AuraEnabled
      public String shippingCarrier { get; set; }
    }
}