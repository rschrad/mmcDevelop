global class NLSQGoogleSSOAuthHandler implements Auth.RegistrationHandler {
    global User createUser(Id portalId, Auth.UserData data) {
        List<User> users = NLSQRegistrationUtils.getUserByUsername(data.email);

        if (users.isEmpty()) {
            return RegistrationService.registerNewUser(data);
        } else {
            return users.get(0);
        }
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        RegistrationService.updateUser(userId, data);
    }
}