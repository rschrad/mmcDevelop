public class NLSQsObjectManager {
    private final DescribeSObjectResult currentSObjectResult;
    private Map<String, SObjectField> fieldsMap;
    private Map<String, FieldSet> fieldSetsMap;

    public NLSQsObjectManager(SObjectType currentObject) {
        this.currentSObjectResult = currentObject.getDescribe();
        if (Test.isRunningTest() && NLSQTestUtils.testError) {
            fieldsMap = new Map<String, SObjectField>();
            fieldSetsMap = new Map<String, FieldSet>();
        }
    }

    public static Map<Id, SObject> mapIdFieldToSobject(List<SObject> sObjects, String field) {
        Map<Id, SObject> fieldToSObject = new Map<Id, SObject>();

        for (SObject sObj : sObjects) {
            fieldToSObject.put((Id) sObj.get(field), sObj);
        }

        return fieldToSObject;
    }

    public static Map<Id, List<SObject>> mapIdFieldToListSobject(List<SObject> sObjects, String field) {
        Map<Id, List<SObject>> fieldToSObjects = new Map<Id, List<SObject>>();

        for (SObject sObj : sObjects) {
            Id identifier = (Id) sObj.get(field);

            if (!fieldToSObjects.containsKey(identifier)) {
                fieldToSObjects.put(identifier, new List<SObject>());
            }

            fieldToSObjects.get(identifier).add(sObj);
        }

        return fieldToSObjects;
    }

    public List<PicklistItem> getPickListValues(String fieldName) {
        if (fieldsMap == null) {
            fieldsMap = currentSObjectResult.fields.getMap();
        }

        Schema.DescribeFieldResult fieldResult = fieldsMap.get(fieldName).getDescribe();

        List<PicklistItem> picklistItems = new List<PicklistItem>();

        for (Schema.PicklistEntry countryField : fieldResult.getPicklistValues()) {
            picklistItems.add(new PicklistItem(countryField.getLabel(), countryField.getValue()));
        }

        return picklistItems;
    }
}