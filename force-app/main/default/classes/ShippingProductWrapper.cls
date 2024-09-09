public with sharing class ShippingProductWrapper {
    @AuraEnabled
    public Decimal productGrossWeight;
    @AuraEnabled
    public Decimal productLength;
    @AuraEnabled
    public Decimal productWidth;
    @AuraEnabled
    public Decimal productHeight;
    @AuraEnabled
    public Decimal unitPrice;
    @AuraEnabled
    public Decimal quantity;
    @AuraEnabled
    public String productId;
    @AuraEnabled
    public String productName;

    public ShippingProductWrapper(
      Product2 product,
      Decimal unitPrice,
      Decimal quantity,
      String productId,
      String productName
    ) {
      this.productGrossWeight = product.Product_Gross_Weight__c;
      this.productLength = product.Product_Length__c;
      this.productWidth = product.Product_Width__c;
      this.productHeight = product.Product_Height__c;
      this.unitPrice = unitPrice;
      this.quantity = quantity;
      this.productId = productId;
      this.productName = productName;
    }
  }