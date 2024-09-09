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
      this.productGrossWeight = (Decimal)product.get(prodFieldMapping.get('ProductWeight'));
      this.productLength = (Decimal)product.get(prodFieldMapping.get('ProductLength'));
      this.productWidth = (Decimal)product.get(prodFieldMapping.get('ProductWidth'));
      this.productHeight = (Decimal)product.get(prodFieldMapping.get('ProductHeight'));
    }
  }
}