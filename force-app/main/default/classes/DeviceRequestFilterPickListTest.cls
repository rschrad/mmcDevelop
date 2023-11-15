@IsTest
public class DeviceRequestFilterPickListTest {
    @isTest
    static void testAllValues() {
        Test.startTest();
        VisualEditor.DynamicPickListRows rows = new DeviceRequestFilterPickList().getValues();
        Test.stopTest();

        System.assertNotEquals(null, rows, 'Should return DynamicPickListRows.');
        System.assertEquals(5, rows.size(), 'DynamicPickListRows size should be equals 5.');

        Set<String> fieldsApiNames = new Set<String>();
        for (VisualEditor.DataRow row : rows.getDataRows()) {
            fieldsApiNames.add((String) row.getValue());
        }

        String msg = 'DynamicPickListRows should contain ';
        System.assert(fieldsApiNames.contains('Request_Date__c'), msg + 'Request_Date__c field.');
        System.assert(fieldsApiNames.contains('Device__r.Name'), msg + 'Device__r.Name field.');
        System.assert(fieldsApiNames.contains('City__c'), msg + 'City__c field.');
        System.assert(fieldsApiNames.contains('State__c'), msg + 'State__cfield.');
        System.assert(fieldsApiNames.contains('Country__c'), msg + 'Country__c field.');
    }

    @isTest
    static void testDefaultValue() {
        Test.startTest();
        VisualEditor.DataRow row = new DeviceRequestFilterPickList().getDefaultValue();
        Test.stopTest();
        System.assertNotEquals(null, row, 'Should return DataRow.');
        System.assertEquals('Request_Date__c', row.getValue(), 'Wrong default field api name for picklist returned.');
    }
}