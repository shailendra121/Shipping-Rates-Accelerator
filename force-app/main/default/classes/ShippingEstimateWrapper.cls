public class ShippingEstimateWrapper {
    public String recordId {get; set;}
    public Map<String, String> shipTo { get; set; }
    public ChildRelationship childRelationship { get; set; }
    public String priceBookFieldName {get; set;}
    public String estimateFieldToUpdate {get; set;}
    public ProductFields productFields { get; set; }

    public class ChildRelationship {
        public String name { get; set; }
        public String parentFieldId { get; set; }
        public Map<String, String> fields { get; set; }
    }
    
    public class ProductFields {
        public String prodName { get; set; }
        public Map<String, String> fields { get; set; }
    }
}