trigger DeviceLikeTrigger on Device_Like__c(before insert, before update, after insert, after delete, after undelete) {
    TriggerDispatcher.run(new DeviceLikeTriggerHandler(), Trigger.operationType);

}