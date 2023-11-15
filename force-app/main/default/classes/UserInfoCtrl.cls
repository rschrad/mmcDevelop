public with sharing class UserInfoCtrl {
    @AuraEnabled
    public static User getUser(Id userId) {
        try {
            NLSQValidator.validateEmptyId(userId);

            return UserSelector.getUsers(new Set<Id>{ userId }).get(0);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}