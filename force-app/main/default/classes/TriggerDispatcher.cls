public class TriggerDispatcher {
    public static void run(ITriggerHandler handler, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                handler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
            }
            when BEFORE_DELETE {
                handler.beforeDelete(Trigger.oldMap);
            }
            when AFTER_INSERT {
                handler.afterInsert(Trigger.newMap);
            }
            when AFTER_UPDATE {
                handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
            }
            when AFTER_DELETE {
                handler.afterDelete(Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                handler.afterUndelete(Trigger.newMap);
            }
        }
    }
}