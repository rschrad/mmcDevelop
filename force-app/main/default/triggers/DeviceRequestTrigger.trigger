trigger DeviceRequestTrigger on Device_Request__c(
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete,
    after undelete
) {
    TriggerDispatcher.run(new DeviceRequestTriggerHandler(), Trigger.operationType);
}