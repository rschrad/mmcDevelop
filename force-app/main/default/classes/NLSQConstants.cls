public with sharing class NLSQConstants {
    public static final Neil_Squire_Community_Setting__mdt SETTING = Neil_Squire_Community_Setting__mdt.getInstance(
        'General'
    );
    public static final String DEFAULT_DEVICE_IMG_URL = '/s/sfsites/c/img/b2b/default-product-image.svg';
    public static final Integer DEFAULT_SOQL_LIMIT = 20000;
    public static final Set<String> PRODUCT_UPDATE_COUNT_FIELDS = new Set<String>{
        'Downloads_Count__c',
        'Shares_Count__c',
        'Views_Count__c'
    };
    public static final Set<String> REVIEWS_FIELDS = new Set<String>{
        'Device__r.Name',
        'Owner.Name',
        'Rating__c',
        'Review_Body__c',
        'CreatedDate'
    };
    public static final Set<String> REQUEST_FIELDS = new Set<String>{
        'Maker__c',
        'Maker__r.Name',
        'Is_Active__c',
        'Device__c',
        'Device__r.Name',
        'Owner.Name',
        'OwnerId'
    };
    public static final Set<String> DEVICE_REQUEST_FIELDS_FOR_LIST = new Set<String>{
        'Request_Date__c',
        'Device__r.Name',
        'City__c',
        'State__c',
        'Country__c',
        'Request_Notes__c'
    };
    public static final Set<String> PRODUCT_FIELDS = new Set<String>{ 'Name', 'IsActive' };
    public static final Map<String, String> SYNC_USER_TO_CONTACT_FIELDS = new Map<String, String>{
        'FirstName' => 'FirstName',
        'LastName' => 'LastName',
        'Email' => 'Email',
        'Country' => 'MailingCountry',
        'Street' => 'MailingStreet',
        'City' => 'MailingCity',
        'State' => 'MailingState',
        'PostalCode' => 'MailingPostalCode',
        'CountryCode' => 'MailingCountryCode',
        'StateCode' => 'MailingStateCode',
        'Portal_Roles__c' => 'Portal_Roles__c'
    };
    public static final Set<String> SUMBIT_FORM_FIELDS = new Set<String>{
        'Projects_Skills__c',
        'Device_Category__c',
        'Disability_Type__c',
        'License__c'
    };
    public static final Map<String, String> DEVICE_REQUEST_LIST_SORTING_FIELDS = new Map<String, String>{
        Label.postedLabel => 'Request_Date__c',
        Label.requestedForLabel => 'Device__r.Name',
        Label.cityLabel => 'City__c',
        Label.provStateLabel => 'State__c',
        Label.countryLabel => 'Country__c'
    };
}