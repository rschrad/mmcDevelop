public inherited sharing class UserSelector {
    public static List<User> getUsers(Set<Id> userIds) {
        return [
            SELECT Name, Country, City, State
            FROM User
            WHERE Id IN :userIds
            WITH SECURITY_ENFORCED
        ];
    }
}