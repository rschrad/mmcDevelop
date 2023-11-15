public class JunkLeadHandler {
    
    @InvocableMethod(label='Delete Junk Leads' description='Delete all the junk Leads based on the criteria specified within the Process Builder' category='Lead')
    public static void deleteJunkLeads(List<ID> ids) {
        try {
            Database.DeleteResult[] results = Database.delete(ids, false);
        }catch(Exception e) {
            System.debug('Delete Junk Leads Failed ::: ' + e.getMessage());
        }
    }
    
}