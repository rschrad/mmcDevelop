public class ContactRequestWrapper {
    @AuraEnabled
    public Contact cont { get; set; }

    @AuraEnabled
    public Case cs { get; set; }

    public ContactRequestWrapper() {
        this.cont = new Contact();
        this.cs = new Case();
    }
}