public class QueryFilter {
    private static final String FIELD_FILTER = ' {0} {1} {2} ';
    private final String fieldName;
    private final String filterOperator;
    private final Object fieldValue;

    public QueryFilter(String fieldName, String filterOperator, Object fieldValue) {
        this.fieldName = fieldName;
        this.filterOperator = filterOperator;
        this.fieldValue = fieldValue instanceof String ? '\'' + fieldValue + '\'' : fieldValue;
    }

    public override String toString() {
        return String.format(
            FIELD_FILTER,
            new List<Object>{
                String.escapeSingleQuotes(fieldName),
                String.escapeSingleQuotes(filterOperator),
                fieldValue
            }
        );
    }
}