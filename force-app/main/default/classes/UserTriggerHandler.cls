@SuppressWarnings('PMD.ApexCrudViolation, PMD.EmptyStatementBlock')
public inherited sharing class UserTriggerHandler implements ITriggerHandler {
    public void beforeInsert(List<SObject> newItems) {
        /*no logic on before insert*/
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        /*no logic on before update*/
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
        /*no logic on before delete*/
    }

    public void afterInsert(Map<Id, SObject> newItems) {
        /*no logic on after insert*/
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        this.syncUserWithContact(newItems, oldItems);
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        /*no logic on after delete*/
    }

    public void afterUndelete(Map<Id, SObject> newItems) {
        /*no logic on after undelee*/
    }

    private void syncUserWithContact(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        List<Contact> contactsToUpdate = getContactsToSync(newItems, oldItems);
        update contactsToUpdate;
    }

    private List<Contact> getContactsToSync(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Contact> contactsToReturn = new Map<Id, Contact>();

        for (Id userId : newItems.keySet()) {
            for (String fieldApiName : NLSQConstants.SYNC_USER_TO_CONTACT_FIELDS.keySet()) {
                if (
                    newItems.get(userId).get(fieldApiName) != oldItems.get(userId).get(fieldApiName) &&
                    newItems.get(userId).get('ContactId') != null
                ) {
                    Id contactId = (Id) newItems.get(userId).get('ContactId');
                    if (contactsToReturn.containsKey(contactId)) {
                        contactsToReturn.get(contactId)
                            .put(
                                NLSQConstants.SYNC_USER_TO_CONTACT_FIELDS.get(fieldApiName),
                                newItems.get(userId).get(fieldApiName)
                            );
                    } else {
                        Contact con = new Contact(Id = contactId);
                        con.put(
                            NLSQConstants.SYNC_USER_TO_CONTACT_FIELDS.get(fieldApiName),
                            newItems.get(userId).get(fieldApiName)
                        );
                        contactsToReturn.put(con.Id, con);
                    }
                }
            }
        }

        return contactsToReturn.values();
    }
}