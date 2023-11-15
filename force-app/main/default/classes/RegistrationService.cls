public class RegistrationService {
    private static final List<String> USER_PERMISSION_SETS = new List<String>{
        NLSQConstants.SETTING.Blog_Permission_Set__c,
        NLSQConstants.SETTING.Events_Permission_Set__c
    };

    public static void validateUser(Contact c) {
        if (!NLSQValidator.validateEmail(c.Email)) {
            throw new RegistrationException(Label.msgValidEmail);
        }
        if (!NLSQValidator.validateUserName(c.Email)) {
            throw new RegistrationException(Label.msgEmailExist);
        }
    }

    public static User registerNewUser(Contact c) {
        SiteUserManager uManager = new SiteUserManager(c);
        User u = uManager.registerSiteUser();
        SiteUserManager.assignPermissions(USER_PERMISSION_SETS, u.Id);

        Account a = NLSQRegistrationUtils.getUserAccount(u.Id).Account;
        BuyerMemberManager bManager = new BuyerMemberManager(a);
        bManager.createBuyerAccount();
        bManager.createBuyerGroupMember();

        return u;
    }

    public static User registerNewUser(Auth.UserData data) {
        Contact c = new Contact(
            Email = data.email,
            FirstName = data.firstName,
            LastName = data.lastName,
            Portal_Roles__c = null
        );
        return registerNewUser(c);
    }

    public static void updateUser(Id userId, Auth.UserData data) {
        User u = new User(Id = userId);
        u.Email = data.email;
        u.LastName = data.lastName;
        u.FirstName = data.firstName;

        NLSQDMLServiceWS.updateRecord(u);
    }

    class RegistrationException extends Exception {
    }
}