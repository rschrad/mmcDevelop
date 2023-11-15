public class DeviceFieldPickList extends VisualEditor.DynamicPickList {
    public override VisualEditor.DataRow getDefaultValue() {
        Schema.DescribeFieldResult dfr = Product2.Description.getDescribe();
        return new VisualEditor.DataRow(dfr.getLabel(), dfr.getName());
    }

    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows rows = new VisualEditor.DynamicPickListRows();
        Map<String, Schema.SObjectField> fieldsMap = Product2.getSObjectType().getDescribe().fields.getMap();
        for (String field : fieldsMap.keySet()) {
            Schema.DescribeFieldResult dfr = fieldsMap.get(field).getDescribe();
            rows.addRow(new VisualEditor.DataRow(dfr.getLabel(), dfr.getName()));
        }
        return rows;
    }
}