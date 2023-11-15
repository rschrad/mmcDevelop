trigger DeviceReviewTrigger on Device_Review__c(after insert, after update, after delete, after undelete) {
    TriggerDispatcher.run(new DeviceReviewTriggerHandler(), Trigger.operationType);
}