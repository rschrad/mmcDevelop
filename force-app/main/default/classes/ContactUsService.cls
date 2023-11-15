public inherited sharing class ContactUsService {
    public static void createCase(ContactRequestWrapper contactRequest, Boolean isGuest) {
        contactRequest.cs.ContactId = isGuest ? getContactIdForGuest(contactRequest.cont) : contactRequest.cs.contactId;
        NLSQDMLServiceWS.insertRecord(contactRequest.cs);
    }

    private static Id getContactIdForGuest(Contact con) {
        List<Contact> contacts = ContactSelector.getContactByEmail(con.Email);
        if (contacts.size() > 0) {
            updateExisting(contacts.get(0), con);
            return contacts.get(0).Id;
        } else {
            return createContact(con);
        }
    }

    private static void updateExisting(Contact con, Contact uiCon) {
        if (con.FirstName != uiCon.FirstName || con.LastName != uiCon.LastName) {
            con.FirstName = uiCon.FirstName;
            con.LastName = uiCon.LastName;
            NLSQDMLServiceWS.updateRecord(con);
        }
    }

    private static Id createContact(Contact con) {
        NLSQDMLServiceWS.insertRecord(con);
        return con.Id;
    }
}