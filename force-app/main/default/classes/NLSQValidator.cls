public inherited sharing virtual class NLSQValidator {
    private static final String EMAIL_REGEX_PATTERN = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';

    /**
     * @param email - email to validation
     * @return true if email is valid
     * @return false if email is invalid
     * */
    public static Boolean validateEmail(String email) {
        if (email == null) {
            return false;
        }

        return Pattern.matches(EMAIL_REGEX_PATTERN, email);
    }

    /**
     * @param username - username to validation
     * @return true if username is free and you can use it to create new user
     * @return false if username is occupied and you cannot use it
     * */
    public static Boolean validateUserName(String username) {
        List<User> users = NLSQRegistrationUtils.getUserByUsername(username);
        return users.isEmpty();
    }

    public static void validateEmptyId(Id recordId) {
        if (String.isBlank(recordId)) {
            throw new IllegalArgumentException('Property recordId can not be null.');
        }
    }
}