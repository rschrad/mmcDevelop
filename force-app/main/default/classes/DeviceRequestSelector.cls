public inherited sharing class DeviceRequestSelector {
    private final static Id RECORD_TYPE_ID;

    static {
        RECORD_TYPE_ID = DeviceUtils.getDeviceRequestRecordType();
    }

    public static List<Device_Request__c> getUserRequests(Id userId, QueryParameters queryParams) {
        NLSQValidator.validateEmptyId(userId);
        NLSQQueryBuilder builder = new NLSQQueryBuilder('Device_Request__c');
        builder.fieldNames.addAll(NLSQConstants.REQUEST_FIELDS);
        builder.setSecurityEnforced(true);
        builder.setRecordsLimit(queryParams.lim);
        builder.setRecordsOffset(queryParams.offset);
        builder.setOrderBy('CreatedDate  DESC');
        builder.setFiltersMapping('{2} AND ({0} OR {1})');
        builder.fieldFilters.add(new QueryFilter('Maker__c', '=', userId));
        builder.fieldFilters.add(new QueryFilter('OwnerId', '=', userId));
        builder.fieldFilters.add(new QueryFilter('RecordTypeId', '=', RECORD_TYPE_ID));

        return Database.query(builder.buildQuery());
    }

    public static Integer getUserRequestsCount(Id userId) {
        NLSQValidator.validateEmptyId(userId);
        NLSQQueryBuilder builder = new NLSQQueryBuilder('Device_Request__c');
        builder.setSecurityEnforced(true);
        builder.setFiltersMapping('{2} AND ({0} OR {1})');
        builder.fieldFilters.add(new QueryFilter('Maker__c', '=', userId));
        builder.fieldFilters.add(new QueryFilter('OwnerId', '=', userId));
        builder.fieldFilters.add(new QueryFilter('RecordTypeId', '=', RECORD_TYPE_ID));

        return Database.countQuery(builder.buildCountQuery());
    }

    public static Integer getDisplayedDeviceRequestsCount(Map<String, String> filteringFieldToValue) {
        NLSQQueryBuilder builder = new NLSQQueryBuilder('Device_Request__c');
        builder.setSecurityEnforced(true);
        builder.fieldFilters.add(new QueryFilter('Is_Active__c', '=', true));
        builder.fieldFilters.add(new QueryFilter('RecordTypeId', '=', RECORD_TYPE_ID));
        builder.fieldFilters.add(new QueryFilter('Stage__c', '=', Label.lblMakerWanted));
        builder.fieldFilters.addAll(getQueryFilters(filteringFieldToValue));

        return Database.countQuery(builder.buildCountQuery());
    }

    public static List<Device_Request__c> getDisplayedDeviceRequests(
        QueryParameters queryParams,
        Map<String, String> filteringFieldToValue
    ) {
        NLSQQueryBuilder builder = new NLSQQueryBuilder('Device_Request__c');
        builder.fieldNames.addAll(NLSQConstants.DEVICE_REQUEST_FIELDS_FOR_LIST);
        builder.setSecurityEnforced(true);
        builder.setRecordsLimit(queryParams.lim);
        builder.setRecordsOffset(queryParams.offset);
        builder.setOrderBy(queryParams.orderBy);
        builder.fieldFilters.add(new QueryFilter('RecordTypeId', '=', RECORD_TYPE_ID));
        builder.fieldFilters.add(new QueryFilter('Is_Active__c', '=', true));
        builder.fieldFilters.add(new QueryFilter('Stage__c', '=', Label.lblMakerWanted));
        builder.fieldFilters.addAll(getQueryFilters(filteringFieldToValue));

        return Database.query(builder.buildQuery());
    }

    private static List<QueryFilter> getQueryFilters(Map<String, String> filteringFieldToValue) {
        List<QueryFilter> queryFilters = new List<QueryFilter>();

        for (String fieldName : filteringFieldToValue.keySet()) {
            String value = filteringFieldToValue.get(fieldName);

            if (value != null) {
                value = value.stripHtmlTags();

                if (fieldName == 'Device__c') {
                    queryFilters.add(new QueryFilter('Device__r.Name', 'LIKE', '%' + value + '%'));
                } else {
                    queryFilters.add(new QueryFilter(fieldName, '=', String.escapeSingleQuotes(value)));
                }
            }
        }

        return queryFilters;
    }
}