public with sharing class AcceptanceForBuildRequestCtrl {
    @AuraEnabled
    public static Device_Request__c acceptRequest(Id requestId) {
        try {
            NLSQValidator.validateEmptyId(requestId);
            Device_Request__c request = new Device_Request__c(
                Id = requestId,
                Maker__c = UserInfo.getUserId(),
                Stage__c = Label.lblBuildingDevice
            );
            NLSQDMLServiceWS.updateRecord(request);

            return request;
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}