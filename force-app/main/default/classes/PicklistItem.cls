public class PicklistItem {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;

    public PicklistItem(String label, String value) {
        this.label = label;
        this.value = value;
    }
}