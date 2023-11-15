@isTest
public class DeviceFieldPickListTest {
    @isTest
    static void testAllValues() {
        Test.startTest();
        VisualEditor.DynamicPickListRows rows = new DeviceFieldPickList().getValues();
        Test.stopTest();

        System.assertNotEquals(null, rows, 'Should return DynamicPickListRows.');
        System.assert(rows.size() > 0, 'DynamicPickListRows size should be greater than 0.');

        Set<String> fieldsApiNames = new Set<String>();
        for (VisualEditor.DataRow row : rows.getDataRows()) {
            fieldsApiNames.add((String) row.getValue());
        }

        String msg = 'DynamicPickListRows should contain ';
        System.assert(fieldsApiNames.contains('Description'), msg + 'Product2.Description field.');
        System.assert(fieldsApiNames.contains('Build_Instructions__c'), msg + 'Product2.Build_Instructions__c field.');
        System.assert(fieldsApiNames.contains('License__c'), msg + 'Product2.License__c field.');
    }

    @isTest
    static void testDefaultValue() {
        Test.startTest();
        VisualEditor.DataRow row = new DeviceFieldPickList().getDefaultValue();
        Test.stopTest();

        System.assertNotEquals(null, row, 'Should return DataRow.');
        System.assertEquals('Description', row.getValue(), 'Wrong default field api name for picklist returned.');
    }
}