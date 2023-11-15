@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class NLSQQueryBuilder {
    private static final String MAIN_QUERY = 'SELECT {0} FROM {1} {2} {3}';
    private static final String COUNT_QUERY = 'SELECT COUNT() FROM {0} {1} {2}';
    private static final String WHERE_ATTRIBUTE = ' WHERE ';
    private static final String SECURITY_ENFORCED_ATTRIBUTE = ' WITH SECURITY_ENFORCED ';
    private static final String ORDER_ATTRIBUTE = ' ORDER BY ';
    private static final String LIMIT_ATTRIBUTE = ' LIMIT ';
    private static final String OFFSET_ATTRIBUTE = ' OFFSET ';

    private final String objectName;

    private String filtersMapping;

    private Boolean securityEnforced = false;
    private String orderBy;
    private Integer recordsLimit;
    private Integer recordsOffset;

    public List<String> fieldNames = new List<String>();
    public List<QueryFilter> fieldFilters = new List<QueryFilter>();

    public NLSQQueryBuilder(String objectName) {
        this.objectName = String.escapeSingleQuotes(objectName);
    }

    public void setSecurityEnforced(Boolean securityEnforced) {
        this.securityEnforced = securityEnforced;
    }

    public void setRecordsLimit(Integer recordsLimit) {
        this.recordsLimit = recordsLimit;
    }

    public void setRecordsOffset(Integer recordsOffset) {
        this.recordsOffset = recordsOffset;
    }

    public void setOrderBy(String orderBy) {
        this.orderBy = String.escapeSingleQuotes(orderBy);
    }

    public void setFiltersMapping(String filtersMapping) {
        this.filtersMapping = String.escapeSingleQuotes(filtersMapping);
    }

    public String buildQuery() {
        List<Object> queryAttributes = new List<Object>();
        queryAttributes.add(String.join(fieldNames, ', '));
        queryAttributes.add(objectName);
        queryAttributes.add(getQueryFilters());
        queryAttributes.add(getAdditionalQueryAttributes());

        String resultQuery = String.format(MAIN_QUERY, queryAttributes);
        System.debug(resultQuery);
        return resultQuery;
    }

    public String buildCountQuery() {
        List<Object> queryAttributes = new List<Object>();
        queryAttributes.add(objectName);
        queryAttributes.add(getQueryFilters());
        queryAttributes.add(securityEnforced ? SECURITY_ENFORCED_ATTRIBUTE : '');

        String resultQuery = String.format(COUNT_QUERY, queryAttributes);
        System.debug(resultQuery);
        return resultQuery;
    }

    private String getQueryFilters() {
        String filtersQuery = '';

        if (fieldFilters.size() > 0) {
            if (filtersMapping == null) {
                setDefaultFiltersMapping();
            }
            filtersQuery = WHERE_ATTRIBUTE + String.format(filtersMapping, fieldFilters);
        }
        return filtersQuery;
    }

    private void setDefaultFiltersMapping() {
        String filtersMapping = ' {0} ';
        for (Integer i = 1; i < fieldFilters.size(); i++) {
            filtersMapping += ' AND {' + i + '}';
        }
        this.filtersMapping = filtersMapping;
    }

    private String getAdditionalQueryAttributes() {
        String queryAttributes = '';

        if (securityEnforced) {
            queryAttributes += SECURITY_ENFORCED_ATTRIBUTE;
        }

        if (orderBy != null) {
            queryAttributes += ORDER_ATTRIBUTE + orderBy;
        }

        if (recordsLimit != null) {
            queryAttributes += LIMIT_ATTRIBUTE + recordsLimit;
        }

        if (recordsOffset != null) {
            queryAttributes += OFFSET_ATTRIBUTE + recordsOffset;
        }

        return queryAttributes;
    }
}