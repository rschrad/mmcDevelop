public inherited sharing class DeviceReviewSelector {
    public static Integer getReviewsCount(Id recordId, String filterField) {
        NLSQValidator.validateEmptyId(recordId);
        NLSQQueryBuilder builder = new NLSQQueryBuilder('Device_Review__c');
        builder.setSecurityEnforced(true);
        builder.fieldFilters.add(new QueryFilter(filterField, '=', recordId));
        builder.fieldFilters.add(new QueryFilter('Device__r.Designer__c', '=', UserInfo.getUserId()));
        builder.fieldFilters.add(new QueryFilter('Device__r.IsActive', '=', true));
        builder.setFiltersMapping('{0} AND ({1} OR {2})');
        return Database.countQuery(builder.buildCountQuery());
    }

    public static List<Device_Review__c> getReviews(Id recordId, String filterField, QueryParameters queryParams) {
        NLSQValidator.validateEmptyId(recordId);
        NLSQQueryBuilder builder = new NLSQQueryBuilder('Device_Review__c');
        builder.fieldNames.addAll(NLSQConstants.REVIEWS_FIELDS);
        builder.setSecurityEnforced(true);
        builder.setRecordsLimit(queryParams.lim);
        builder.setRecordsOffset(queryParams.offset);
        builder.setOrderBy('CreatedDate  DESC');
        builder.fieldFilters.add(new QueryFilter(filterField, '=', recordId));
        builder.fieldFilters.add(new QueryFilter('Device__r.Designer__c', '=', UserInfo.getUserId()));
        builder.fieldFilters.add(new QueryFilter('Device__r.IsActive', '=', true));
        builder.setFiltersMapping('{0} AND ({1} OR {2})');

        return Database.query(builder.buildQuery());
    }
}