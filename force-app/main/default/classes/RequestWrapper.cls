public class RequestWrapper {
    @AuraEnabled
    public Device_Request__c request;

    @AuraEnabled
    public String mediaUrl;

    public RequestWrapper(Device_Request__c request, String mediaUrl) {
        this.request = request;
        this.mediaUrl = mediaUrl;
    }
}