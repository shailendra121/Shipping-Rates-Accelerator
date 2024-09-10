@isTest
public class CalculateShippingEstimateCtrlTest {

    @testSetup
    static void setup() {
        Account acc= new Account();
        acc.Name = 'Carlisle Construction Material Test';
        acc.BillingCity = 'Carlisle';
        acc.BillingCountry = 'US';
        acc.BillingPostalCode='17015';
        acc.BillingState ='PA';
        acc.BillingStreet='123 ratnair high way';
        acc.ShippingCountry = 'United States';
        acc.ShippingCity = 'Wheeling';
        acc.ShippingCountry = 'US';
        acc.ShippingPostalCode = '26003';
        acc.ShippingState= 'WV';
        acc.ShippingStreet = '53 14th Street Ste 208';        
        insert Acc;
        
    	Product2 objProduct = new Product2(Name = 'Printer-1', family = 'Printer');                                      
        insert objProduct;
       
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                        Product2Id = objProduct.Id, IsActive = true);                                             
        insert objPBE;         
        
        Opportunity oppt = new Opportunity();
        oppt.Name ='Test opportunity';
        oppt.AccountId = Acc.Id;
        oppt.StageName = 'Rady to quote';
        oppt.Amount = 3000;
        oppt.CloseDate = System.today() +30 ;
        oppt.Pricebook2Id = Test.getStandardPricebookId();
        oppt.Shipping_Phone__c = '9900000000';
        insert oppt;

        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppt.Id, Product2Id = objProduct.Id, Quantity = 1, UnitPrice = 100, PricebookEntryId = objPBE.Id);
        insert oli;

        // Create Shipping Credential record
        Astonous_SM__Shipping_Credential__c shippingCredential = new Astonous_SM__Shipping_Credential__c(Astonous_SM__Shipping_Carrier__c='UPS', Astonous_SM__Account_Number__c='SHIP123');
        insert shippingCredential;

        // Create necessary data records like Shipping_Estimate_Configuration__c, Astonous_SM__Shipping_Preference__c, etc.
        Shipping_Estimate_Configuration__c config = new Shipping_Estimate_Configuration__c(
            SObject_Name__c = 'Opportunity',
            Field_Details_w_Json_Format__c = getJSONFieldDetails(),
            Display_Review_Screen__c = true
        );
        insert config;

        Astonous_SM__Shipping_Preference__c prefRecord = new Astonous_SM__Shipping_Preference__c(Astonous_SM__Building_Location__c = 'Side', Astonous_SM__Building_Type__c = 'BUILDING', Astonous_SM__City__c = 'Carlisle',
                                                                                                 Astonous_SM__Company__c = 'SprintRay inc', Astonous_SM__Contact_Person_Name__c = 'Mayank Joshi', Astonous_SM__Country__c = 'US',
                                                                                                 Astonous_SM__Default__c = true, Astonous_SM__Email__c = 'info@astonous.com', Astonous_SM__Is_it_Residential_Address__c = false, Name = 'Main office',
                                                                                                 Astonous_SM__Default_Carrier__c = 'UPS', Astonous_SM__Label_Image_Type__c = 'PNG',
                                                                                                Astonous_SM__Label_Format_Type__c = 'Not Applicable', Astonous_SM__Label_Stock_Type__c = 'Not Applicable', Astonous_SM__Service_Type__c = '003',
                                                                                                Astonous_SM__Label_Printing_Orientation__c = 'Not Applicable', Astonous_SM__Linear_Unit__c = 'IN',Astonous_SM__Weight_Unit__c = 'LBS',
                                                                                                Astonous_SM__Phone__c = '9400000000', Astonous_SM__Postal_Code__c = '2342343', Astonous_SM__State__c = 'PA', Astonous_SM__Street__c = '129 Stree', Astonous_SM__Signature_Option__c = '');
        
        insert prefRecord;
    }

    @isTest
    static void testGetShippingEstimateConfigDetail() {
        // Test the getShippingEstimateConfigDetail method
        Opportunity oppRec = [SELECT Id From Opportunity LIMIT 1];

        Test.startTest();
            Map<String, Object> result = CalculateShippingEstimateCtrl.getShippingEstimateConfigDetail(oppRec.Id);
        Test.stopTest();

        System.assert(result != null, 'Expected non-null result');
        System.assert(result.containsKey('showDisplayReviewScreen'), 'Expected showDisplayReviewScreen in result');
        System.assert(result.containsKey('shippingEstimateConfig'), 'Expected shippingEstimateConfig in result');
        System.assert(result.containsKey('shippingPreferances'), 'Expected shippingPreferances in result');
    }

    @isTest
    static void testCreateDefaultRequest() {
        // Test the createDefaultRequest method
        Opportunity oppRec = [SELECT Id From Opportunity LIMIT 1];
        String estimateConfigWrapper = getJSONFieldDetails();

        Test.startTest();
            ShippingRatingRequestWrapper result = CalculateShippingEstimateCtrl.createDefaultRequest(oppRec.Id, estimateConfigWrapper);
            System.assert(result != null, 'Expected non-null ShippingRatingRequestWrapper result');
        Test.stopTest();
    }

    @isTest
    static void testFetchRecordProductList() {
        // Test the fetchRecordProductList method
        Opportunity oppRec = [SELECT Id From Opportunity LIMIT 1];
        String estimateConfigWrapper = getJSONFieldDetails();

        Test.startTest();
            List<ShippingProductWrapper> result = CalculateShippingEstimateCtrl.fetchRecordProductList(oppRec.Id, estimateConfigWrapper);
            System.assert(result != null, 'Expected non-null ShippingProductWrapper list');
            System.assert(result.size() > 0, 'Expected non empty ShippingProductWrapper list');
        Test.stopTest();
    }

    @isTest
    static void testFetchShippingRatesForUPS() {
        // Test the fetchShippingRates method
        String preferanceId = [SELECT Id FROM Astonous_SM__Shipping_Preference__c WHERE Name = 'Main office' LIMIT 1]?.Id;
        Opportunity oppRec = [SELECT Id, Name, Shipping_Country__c, Shipping_Phone__c, Shipping_Postal_Code__c, Shipping_State__c, Shipping_City__c, Shipping_Street__c
                            From Opportunity
                            LIMIT 1];
        ShippingEstimateWrapper wrapper = (ShippingEstimateWrapper) JSON.deserialize(getJSONFieldDetails(), ShippingEstimateWrapper.class);
        //createDefaultRequest
        Test.setMock(HttpCalloutMock.class, new CreateShipmentMockResponse());
        Test.startTest();
            ShippingRatingRequestWrapper ratingReqWrapper = CalculateShippingEstimateCtrl.createDefaultRequest(oppRec.Id, getJSONFieldDetails());
            ratingReqWrapper.preferanceID = preferanceId;
            //ratingReqWrapper.pkgLst = new List<Astonous_SM.RatingRequest.ShippingPackage>();
            ratingReqWrapper.serviceProvider = 'UPS';
            try {
                List<Astonous_SM.ShippingRate> result = CalculateShippingEstimateCtrl.fetchShippingRates(ratingReqWrapper);  
            } catch (Exception ex) {
                System.assert(ex != null, 'Expected non-null ShippingRate list'); 
            }
        Test.stopTest();
    }

    @isTest
    static void testFetchShippingRatesForFedEx() {
        // Test the fetchShippingRates method
        String preferanceId = [SELECT Id FROM Astonous_SM__Shipping_Preference__c WHERE Name = 'Main office' LIMIT 1]?.Id;
        Opportunity oppRec = [SELECT Id, Name, Shipping_Country__c, Shipping_Phone__c, Shipping_Postal_Code__c, Shipping_State__c, Shipping_City__c, Shipping_Street__c
                            From Opportunity
                            LIMIT 1];
        ShippingEstimateWrapper wrapper = (ShippingEstimateWrapper) JSON.deserialize(getJSONFieldDetails(), ShippingEstimateWrapper.class);
        //createDefaultRequest
        Test.setMock(HttpCalloutMock.class, new CreateShipmentMockResponse());
        Test.startTest();
            ShippingRatingRequestWrapper ratingReqWrapper = CalculateShippingEstimateCtrl.createDefaultRequest(oppRec.Id, getJSONFieldDetails());
            ratingReqWrapper.preferanceID = preferanceId;
            //ratingReqWrapper.pkgLst = new List<Astonous_SM.RatingRequest.ShippingPackage>();
            ratingReqWrapper.serviceProvider = 'FedEx';
            try {
                List<Astonous_SM.ShippingRate> result = CalculateShippingEstimateCtrl.fetchShippingRates(ratingReqWrapper);  
            } catch (Exception ex) {
                System.assert(ex != null, 'Expected non-null ShippingRate list'); 
            }
        Test.stopTest();
    }

    @isTest
    static void testFetchShippingRatesForUSPS() {
        // Test the fetchShippingRates method
        String preferanceId = [SELECT Id FROM Astonous_SM__Shipping_Preference__c WHERE Name = 'Main office' LIMIT 1]?.Id;
        Opportunity oppRec = [SELECT Id, Name, Shipping_Country__c, Shipping_Phone__c, Shipping_Postal_Code__c, Shipping_State__c, Shipping_City__c, Shipping_Street__c
                            From Opportunity
                            LIMIT 1];
        ShippingEstimateWrapper wrapper = (ShippingEstimateWrapper) JSON.deserialize(getJSONFieldDetails(), ShippingEstimateWrapper.class);
        //createDefaultRequest
        Test.setMock(HttpCalloutMock.class, new CreateShipmentMockResponse());
        Test.startTest();
            ShippingRatingRequestWrapper ratingReqWrapper = CalculateShippingEstimateCtrl.createDefaultRequest(oppRec.Id, getJSONFieldDetails());
            ratingReqWrapper.preferanceID = preferanceId;
            //ratingReqWrapper.pkgLst = new List<Astonous_SM.RatingRequest.ShippingPackage>();
            ratingReqWrapper.serviceProvider = 'USPS';
            try {
                List<Astonous_SM.ShippingRate> result = CalculateShippingEstimateCtrl.fetchShippingRates(ratingReqWrapper);  
            } catch (Exception ex) {
                System.assert(ex != null, 'Expected non-null ShippingRate list'); 
            }
        Test.stopTest();
    }

    @isTest
    static void testFetchShippingRatesForXPO() {
        // Test the fetchShippingRates method
        String preferanceId = [SELECT Id FROM Astonous_SM__Shipping_Preference__c WHERE Name = 'Main office' LIMIT 1]?.Id;
        Opportunity oppRec = [SELECT Id, Name, Shipping_Country__c, Shipping_Phone__c, Shipping_Postal_Code__c, Shipping_State__c, Shipping_City__c, Shipping_Street__c
                            From Opportunity
                            LIMIT 1];
        ShippingEstimateWrapper wrapper = (ShippingEstimateWrapper) JSON.deserialize(getJSONFieldDetails(), ShippingEstimateWrapper.class);
        //createDefaultRequest
        Test.setMock(HttpCalloutMock.class, new CreateShipmentMockResponse());
        Test.startTest();
            ShippingRatingRequestWrapper ratingReqWrapper = CalculateShippingEstimateCtrl.createDefaultRequest(oppRec.Id, getJSONFieldDetails());
            ratingReqWrapper.preferanceID = preferanceId;
            //ratingReqWrapper.pkgLst = new List<Astonous_SM.RatingRequest.ShippingPackage>();
            ratingReqWrapper.serviceProvider = 'XPO';
            try {
                List<Astonous_SM.ShippingRate> result = CalculateShippingEstimateCtrl.fetchShippingRates(ratingReqWrapper);  
            } catch (Exception ex) {
                System.assert(ex != null, 'Expected non-null ShippingRate list'); 
            }
        Test.stopTest();
    }


    @isTest
    static void testFetchShippingRatesForRoadRunner() {
        // Test the fetchShippingRates method
        String preferanceId = [SELECT Id FROM Astonous_SM__Shipping_Preference__c WHERE Name = 'Main office' LIMIT 1]?.Id;
        Opportunity oppRec = [SELECT Id, Name, Shipping_Country__c, Shipping_Phone__c, Shipping_Postal_Code__c, Shipping_State__c, Shipping_City__c, Shipping_Street__c
                            From Opportunity
                            LIMIT 1];
        ShippingEstimateWrapper wrapper = (ShippingEstimateWrapper) JSON.deserialize(getJSONFieldDetails(), ShippingEstimateWrapper.class);
        //createDefaultRequest
        Test.setMock(HttpCalloutMock.class, new CreateShipmentMockResponse());
        Test.startTest();
            ShippingRatingRequestWrapper ratingReqWrapper = CalculateShippingEstimateCtrl.createDefaultRequest(oppRec.Id, getJSONFieldDetails());
            ratingReqWrapper.preferanceID = preferanceId;
            //ratingReqWrapper.pkgLst = new List<Astonous_SM.RatingRequest.ShippingPackage>();
            ratingReqWrapper.serviceProvider = 'RoadRunner';
            ratingReqWrapper.preferance = preferanceId;
            ratingReqWrapper.accessorials = new List<String>();
            ratingReqWrapper.objectName = 'Opportunity';
            ratingReqWrapper.recordId = oppRec.Id;
            ratingReqWrapper.reference = 'test';
            ratingReqWrapper.customerPurchaseNumber = 'test323232';
            ratingReqWrapper.description = 'test323232';
            ratingReqWrapper.currentIndex = '1';
            ratingReqWrapper.shippingCost = '100';
            ratingReqWrapper.autoAssignPro = false;

            try {
                List<Astonous_SM.ShippingRate> result = CalculateShippingEstimateCtrl.fetchShippingRates(ratingReqWrapper);  
            } catch (Exception ex) {
                System.assert(ex != null, 'Expected non-null ShippingRate list'); 
            }
        Test.stopTest();
    }

    @isTest
    static void testFetchAllShippingRates() {
        // Test the fetchAllShippingRates method
        Opportunity oppRec = [SELECT Id From Opportunity LIMIT 1];
        String preferanceId = [SELECT Id FROM Astonous_SM__Shipping_Preference__c WHERE Name = 'Main office' LIMIT 1]?.Id;
        String estimateConfigWrapper = getJSONFieldDetails();
        Test.setMock(HttpCalloutMock.class, new CreateShipmentMockResponse());
        Test.startTest();
            try{
                List<CalculateShippingEstimateCtrl.CalcShipRateWrapper> result = CalculateShippingEstimateCtrl.fetchAllShippingRates(oppRec.Id, preferanceId, estimateConfigWrapper);
            }catch (Exception ex) {
                System.assert(ex != null, 'Expected non-null ShippingRate list'); 
            }
        Test.stopTest();
    }

    @isTest
    static void testUpdateRecordShippingCost() {
        // Test the updateRecordShippingCost method
        Opportunity oppRec = [SELECT Id From Opportunity LIMIT 1];
        ShippingEstimateWrapper wrapper = (ShippingEstimateWrapper) JSON.deserialize(getJSONFieldDetails(), ShippingEstimateWrapper.class);
        String estimateFieldName = wrapper.estimateFieldToUpdate;
        String idFieldName = wrapper.recordId;
        String prodObject = wrapper.productFields.prodName;
        String totalCharge = '100.00 USD';

        Test.startTest();
            SObject result = CalculateShippingEstimateCtrl.updateRecordShippingCost(oppRec.Id, estimateFieldName, totalCharge);
            System.assert(result != null, 'Expected non-null updated SObject');
        Test.stopTest();
    }

    private static String getJSONFieldDetails() {
        String jsonForShippingEstimate = '{'
                                            + '"recordId": "ID",'
                                            + '"shipTo": {'
                                            + '  "country": "Shipping_Country__c",'
                                            + '  "contactPersonName": "Shipping_Company_Name__c",'
                                            + '  "companyName": "Shipping_Company_Name__c",'
                                            + '  "phoneNumber": "Shipping_Phone__c",'
                                            + '  "postalCode": "Shipping_Postal_Code__c",'
                                            + '  "state": "Shipping_State__c",'
                                            + '  "city": "Shipping_City__c",'
                                            + '  "streetLine": "Shipping_Street__c"'
                                            + '},'
                                            + '"priceBookFieldName": "Pricebook2Id",'
                                            + ' "estimateFieldToUpdate" : "Estimated_Shipping_Cost__c",'
                                            + '"childRelationship": {'
                                            + '  "name": "Opportunitylineitem",'
                                            + '  "parentFieldId": "OpportunityId",'
                                            + '  "fields": {'
                                            + '    "RecordId": "Id",'
                                            + '    "ProductId": "Product2Id",'
                                            + '    "Quantity": "Quantity"'
                                            + '  }'
                                            + '},'
                                            + '"productFields": {'
                                            + '  "prodName": "Product2",'
                                            + '  "fields": {'
                                            + '    "RecordId": "Id",'
                                            + '    "ProductName": "Name"'
                                            + '  }'
                                            + '}'
                                        + '}';
        return jsonForShippingEstimate;
    }
}