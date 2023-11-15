public with sharing class DeviceRequestMainInfoCtrl {
    @AuraEnabled
    public static Map<Id, String> getContentKey(Id deviceId) {
        try {
            NLSQValidator.validateEmptyId(deviceId);

            return ManagedContentService.getDeviceIdToContentKey(new Set<Id>{ deviceId });
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}