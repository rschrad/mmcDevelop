public with sharing class SubmitDeviceCtrl {
    @AuraEnabled
    public static Map<String, List<PicklistItem>> getFormFields() {
        try {
            NLSQsObjectManager manager = new NLSQsObjectManager(Product2.getSObjectType());
            Map<String, List<PicklistItem>> fieldsMap = new Map<String, List<PicklistItem>>();
            for (String field : NLSQConstants.SUMBIT_FORM_FIELDS) {
                fieldsMap.put(field, manager.getPickListValues(field));
            }
            return fieldsMap;
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

    @AuraEnabled
    public static Id submit(Product2 product, List<ContentVersion> contentVersions, String captchaResponse) {
        try {
            ReCaptchaService.verifyResponse(captchaResponse);
            return DeviceService.submitDevice(product, contentVersions);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}