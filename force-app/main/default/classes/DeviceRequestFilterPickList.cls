public class DeviceRequestFilterPickList extends VisualEditor.DynamicPickList {
    public override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(Label.postedLabel, 'Request_Date__c');
        return defaultValue;
    }
    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();
        for (String key : NLSQConstants.DEVICE_REQUEST_LIST_SORTING_FIELDS.keySet()) {
            myValues.addRow(new VisualEditor.DataRow(key, NLSQConstants.DEVICE_REQUEST_LIST_SORTING_FIELDS.get(key)));
        }
        return myValues;
    }
}