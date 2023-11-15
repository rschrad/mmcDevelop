public class QueryParameters {
    @AuraEnabled
    public Integer lim { get; set; }
    @AuraEnabled
    public Integer offset { get; set; }
    @AuraEnabled
    public String orderBy { get; set; }

    // prettier-ignore
    public QueryParameters() {} //NOPMD
    public QueryParameters(Integer lim, Integer offset, String orderBy) {
        this.lim = lim;
        this.offset = offset;
        this.orderBy = orderBy;
    }
}