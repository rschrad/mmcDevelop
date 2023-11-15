@SuppressWarnings('PMD.ApexCrudViolation, PMD.EmptyStatementBlock')
public inherited sharing class DeviceRequestTriggerHandler implements ITriggerHandler {
    public void beforeInsert(List<SObject> newItems) {
        /*no logic on before insert*/
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        this.updateStageModifiedDate(newItems, oldItems);
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
        /*no logic on before delete*/
    }

    public void afterInsert(Map<Id, SObject> newItems) {
        /*no logic on after insert*/
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        /*no logic on after update*/
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        /*no logic on after delete*/
    }

    public void afterUndelete(Map<Id, SObject> newItems) {
        /*no logic on after undelete*/
    }

    private void updateStageModifiedDate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        for (Id requestId : newItems.keySet()) {
            if (newItems.get(requestId).get('Stage__c') != oldItems.get(requestId).get('Stage__c')) {
                newItems.get(requestId).put('Stage_modified_date__c', System.today());
            }
        }
    }
}