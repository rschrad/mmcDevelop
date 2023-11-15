global without sharing class SelfRegisterCtrl {
    @AuraEnabled
    public static void registerUser(Contact currentContact, String captchaResponse) {
        try {
            ReCaptchaService.verifyResponse(captchaResponse);
            RegistrationService.validateUser(currentContact);
            RegistrationService.registerNewUser(currentContact);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<PicklistItem> getPortalRoles() {
        NLSQsObjectManager manager = new NLSQsObjectManager(Contact.getSObjectType());
        try {
            return manager.getPickListValues('Portal_Roles__c');
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}