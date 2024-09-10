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
    Map<String, String> prodFieldMapping
  ) {
    this.unitPrice = unitPrice;
    this.quantity = quantity;
    if(!prodFieldMapping.isEmpty()) {
      this.productId = (ID)product.get(prodFieldMapping.get('RecordId'));
      this.productName = (String)product.get(prodFieldMapping.get('ProductName'));
      if(prodFieldMapping.containsKey('ProductWeight')) {
        this.productGrossWeight = (Decimal)product.get(prodFieldMapping.get('ProductWeight'));
      }else {
        this.productGrossWeight = 1;
      }
      if(prodFieldMapping.containsKey('ProductLength')) {
        this.productLength = (Decimal)product.get(prodFieldMapping.get('ProductLength'));
      }else {
        this.productLength = 1;
      }
      if(prodFieldMapping.containsKey('ProductWidth')) {
        this.productWidth = (Decimal)product.get(prodFieldMapping.get('ProductWidth'));
      }else {
        this.productWidth = 1;
      }
      if(prodFieldMapping.containsKey('ProductHeight')) {
        this.productHeight = (Decimal)product.get(prodFieldMapping.get('ProductHeight'));
      }else {
        this.productHeight = 1;
      }
    }
  }
}