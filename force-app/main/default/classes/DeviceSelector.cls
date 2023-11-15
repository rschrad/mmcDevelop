public inherited sharing class DeviceSelector {
    public static Product2 getDeviceInfo(Id recordId) {
        return [
            SELECT
                Name,
                IsActive,
                User_Value_Statement__c,
                Designer__r.Name,
                Designer__r.FullPhotoUrl,
                Last_Updated_Date__c,
                Projects_Skills__c,
                Rating_Average__c,
                DisplayUrl,
                Reviews_Count__c,
                Likes_Count__c,
                Downloads_Count__c,
                Shares_Count__c,
                Views_Count__c
            FROM Product2
            WHERE Id = :recordId AND (IsActive = TRUE OR Designer__c = :UserInfo.getUserId())
            WITH SECURITY_ENFORCED
        ];
    }

    public static Product2 getDeviceField(Id recordId, String field) {
        NLSQQueryBuilder builder = new NLSQQueryBuilder('Product2');
        builder.fieldNames.add(field);
        builder.setSecurityEnforced(true);
        builder.fieldFilters.add(new QueryFilter('Id', '=', recordId));

        return (Product2) Database.query(builder.buildQuery()).get(0);
    }

    public static List<Product2> getActiveDevicesByDefaultCategory() {
        List<Product2> devices = new List<Product2>();
        List<ProductCategoryProduct> productCategoryProducts = new List<ProductCategoryProduct>(
            [
                SELECT Product.Name
                FROM ProductCategoryProduct
                WHERE ProductCategory.Name = :NLSQConstants.SETTING.Category_Name__c AND Product.IsActive = TRUE
                WITH SECURITY_ENFORCED
                LIMIT :NLSQConstants.DEFAULT_SOQL_LIMIT
            ]
        );
        for (ProductCategoryProduct item : productCategoryProducts) {
            devices.add(item.Product);
        }
        return devices;
    }

    public static Integer getDevicesCount(Id userId, String filterField) {
        if (String.isBlank(userId)) {
            throw new IllegalArgumentException('Property userId can not be null.');
        }
        NLSQQueryBuilder builder = new NLSQQueryBuilder('Product2');
        builder.setSecurityEnforced(true);
        builder.fieldFilters.add(new QueryFilter(filterField, '=', userId));
        return Database.countQuery(builder.buildCountQuery());
    }

    public static Map<Id, Product2> getDevicesAsMap(Id userId, String filterField, QueryParameters queryParams) {
        if (String.isBlank(userId)) {
            throw new IllegalArgumentException('Property userId can not be null.');
        }
        NLSQQueryBuilder builder = new NLSQQueryBuilder('Product2');
        builder.fieldNames.addAll(NLSQConstants.PRODUCT_FIELDS);
        builder.setSecurityEnforced(true);
        builder.setRecordsLimit(queryParams.lim);
        builder.setRecordsOffset(queryParams.offset);
        builder.setOrderBy('CreatedDate  DESC');
        builder.fieldFilters.add(new QueryFilter(filterField, '=', userId));

        return new Map<Id, Product2>((List<Product2>) Database.query(builder.buildQuery()));
    }
}