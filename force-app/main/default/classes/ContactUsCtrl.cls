public with sharing class ContactUsCtrl {
    @AuraEnabled
    public static void sendMessage(ContactRequestWrapper contactRequest, String uiResponse, Boolean isGuest) {
        try {
            ReCaptchaService.verifyResponse(uiResponse);
            ContactUsService.createCase(contactRequest, isGuest);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}