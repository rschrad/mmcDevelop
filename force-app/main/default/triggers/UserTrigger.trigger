trigger UserTrigger on User(after update) {
    TriggerDispatcher.run(new UserTriggerHandler(), Trigger.operationType);
}