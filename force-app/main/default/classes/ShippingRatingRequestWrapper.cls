public class ShippingRatingRequestWrapper {
    @AuraEnabled
    public String preferance { get; set; }
    @AuraEnabled
    public String serviceProvider { get; set; }
    @AuraEnabled
    public String serviceType { get; set; }
    @AuraEnabled
    public String packagingType { get; set; }
    @AuraEnabled
    public Date shippingDate { get; set; }
    @AuraEnabled
    public String machinable { get; set; }
    @AuraEnabled
    public List<String> accessorials { get; set; }
    @AuraEnabled
    public String objectName { get; set; }
    @AuraEnabled
    public List<Astonous_SM.RatingRequest.ShippingPackage> pkgLst { get; set; }
    @AuraEnabled
    public String preferanceID { get; set; }
    @AuraEnabled
    public String recordId { get; set; }
    @AuraEnabled
    public String reference { get; set; }
    @AuraEnabled
    public String customerPurchaseNumber { get; set; }
    @AuraEnabled
    public String description { get; set; }
    @AuraEnabled
    public String serviceID { get; set; }
    @AuraEnabled
    public String currentIndex { get; set; }
    @AuraEnabled
    public String shippingCost { get; set; }
    @AuraEnabled
    public Boolean autoAssignPro { get; set; }

    @AuraEnabled
    public Astonous_SM.Address recipientAddress { get; set; }
  }