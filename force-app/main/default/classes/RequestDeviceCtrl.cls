public with sharing class RequestDeviceCtrl {
    @AuraEnabled(Cacheable=true)
    public static List<PicklistItem> getDevicesPicklist() {
        try {
            return DeviceService.getDevicesPicklist();
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

    @AuraEnabled
    public static Id createRecord(Device_Request__c deviceRequest, String uiResponse) {
        try {
            ReCaptchaService.verifyResponse(uiResponse);
            deviceRequest.Device_Requestor__c = ContactSelector.getContactId(UserInfo.getUserId());
            deviceRequest.RecordTypeId = DeviceUtils.getDeviceRequestRecordType();
            NLSQDMLService.insertRecord(deviceRequest);

            return deviceRequest.Id;
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}