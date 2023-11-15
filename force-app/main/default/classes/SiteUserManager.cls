public class SiteUserManager {
    private static final Profile COMMUNITY_PROFILE = NLSQRegistrationUtils.getCommunityProfile();
    private static final Organization ORGANIZATION = NLSQRegistrationUtils.getOgrDefaults();

    private final Contact currentContact;

    public SiteUserManager(Contact currentContact) {
        List<Contact> contacts = ContactSelector.getContactByEmail(currentContact.Email);
        this.currentContact = currentContact;
        if (contacts.size() > 0) {
            this.currentContact.Id = contacts.get(0).Id;
        }
    }

    public User registerSiteUser() {
        currentContact.npe01__Preferred_Email__c = 'Personal';

        if (currentContact.Id == null) {
            NLSQDMLServiceWS.insertRecord(currentContact);
        } else {
            NLSQDMLServiceWS.updateRecord(currentContact);
        }

        return createUser();
    }

    @Future
    public static void assignPermissions(List<String> permissionSetsNames, Id userId) {
        List<PermissionSet> permissionSets = NLSQRegistrationUtils.getPermissionSetsByNames(permissionSetsNames);

        if (permissionSets.isEmpty()) {
            return;
        }

        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();

        for (PermissionSet ps : permissionSets) {
            assignments.add(new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id));
        }

        NLSQDMLServiceWS.insertRecords(assignments);
    }

    private User createUser() {
        String nickname = composeAlias();

        User newUser = new User(
            ContactId = currentContact.Id,
            Email = currentContact.Email,
            Username = currentContact.Email,
            Alias = nickname,
            CommunityNickname = nickname + getRandomNumber(),
            ProfileId = COMMUNITY_PROFILE.Id,
            FirstName = currentContact.FirstName,
            LastName = currentContact.LastName,
            LocaleSidKey = ORGANIZATION.DefaultLocaleSidKey,
            LanguageLocaleKey = ORGANIZATION.LanguageLocaleKey,
            TimeZoneSidKey = ORGANIZATION.TimeZoneSidKey,
            EmailEncodingKey = 'UTF-8',
            CountryCode = currentContact.MailingCountryCode,
            StateCode = currentContact.MailingStateCode,
            Portal_Roles__c = currentContact.Portal_Roles__c
        );

        NLSQDMLServiceWS.insertRecord(newUser);
        return newUser;
    }

    private String composeAlias() {
        String alias = currentContact.FirstName.left(3);
        alias += currentContact.LastName.left((3 - alias.length()) + 5);
        return alias;
    }

    private Integer getRandomNumber() {
        return Integer.valueOf(10 + (99 - 10) * Math.random());
    }
}