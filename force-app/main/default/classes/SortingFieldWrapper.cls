public class SortingFieldWrapper {
    @AuraEnabled
    public String fieldLabel;
    @AuraEnabled
    public String fieldApiName;
    @AuraEnabled
    public Boolean isSortAsc;
    @AuraEnabled
    public Boolean isSelected;

    public SortingFieldWrapper(String fieldLabel, String fieldApiName) {
        this.fieldLabel = fieldLabel;
        this.fieldApiName = fieldApiName;
        this.isSortAsc = false;
        this.isSelected = false;
    }
}