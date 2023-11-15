@SuppressWarnings('PMD.ApexCrudViolation')
public with sharing class NLSQDMLService {
    public static void insertRecord(SObject record) {
        insertRecords(record.getSObjectType(), new List<SObject>{ record });
    }

    public static void insertRecords(SObjectType objectType, List<SObject> records) {
        Schema.DescribeSObjectResult sObjectDescribe = objectType.getDescribe();
        if (!sObjectDescribe.isCreateable()) {
            String objName = '(' + sObjectDescribe.getName() + ')';
            throw new SecurityException('No access to create this records ' + objName);
        }

        insert records;
    }
}