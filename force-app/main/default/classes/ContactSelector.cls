@SuppressWarnings('PMD.ApexCrudViolation')
public without sharing class ContactSelector {

    public static List<Contact> getContactByEmail(String email) {
        if (String.isBlank(email)) {
            throw new IllegalArgumentException('Property email can not be null.');
        }
        return new List<Contact>(
        [
            SELECT CreatedDate, Id, LastName, FirstName, Email
            FROM Contact
            WHERE Email = :email
            ORDER BY CreatedDate DESC
            LIMIT 1
        ]
        );
    }

    public static Id getContactId(Id userId) {
        if (String.isBlank(userId)) {
            throw new IllegalArgumentException('Property userId can not be null.');
        }
        NLSQQueryBuilder builder = new NLSQQueryBuilder('User');

        builder.setSecurityEnforced(true);
        builder.setRecordsLimit(1);
        builder.fieldNames.add('ContactId');
        builder.fieldFilters.add(new QueryFilter('Id', '=', userId));
        User u = Database.query(builder.buildQuery());
        return u.ContactId;
    }
}