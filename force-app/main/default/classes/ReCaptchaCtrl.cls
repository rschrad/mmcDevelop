public with sharing class ReCaptchaCtrl {
    @AuraEnabled(Cacheable=true)
    public static String getSiteKey() {
        try {
            return ReCaptchaService.getSiteKey();
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}