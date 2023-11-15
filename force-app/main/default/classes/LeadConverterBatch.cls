public class LeadConverterBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public String queryStr;
    public Set<Id> DUP_LeadIds;
    
    public LeadConverterBatch(String query) {
        this.queryStr = query;
        this.DUP_LeadIds = new Set<Id>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(queryStr);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> leads) { 
        List<Id> leadIds = new List<Id>();
        for(Lead ld : leads) {
            leadIds.add(ld.Id);
        }
        
        try {
            if(!DUP_LeadIds.contains(leadIds[0])) {
                Set<Id> Dup_LIds = findDuplicateLeads(leadIds);
                
                if(Dup_LIds.size() > 0) {
                    DUP_LeadIds.addAll(Dup_LIds);
                    Delete [SELECT Id FROM Lead WHERE Id IN : Dup_LIds];
                }
                LeadConverterUtility.handleLeadConversion(leadIds);
            }else {
                System.debug('DUPLICATE LEAD ALREADY DELETED!!!');
            }
        }catch(Exception e) {
            System.debug('LCF ::: ' + e.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        //
    }
    
    private static Set<Id> findDuplicateLeads(List<Id> LeadIds) {
        Set<Id> DupLeadIds = new Set<Id>();
        Integer index = 0;
        
        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicatesByIds.findDuplicatesByIds(LeadIds);
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                    for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                        SObject record = matchRecord.getRecord();
                        if(record.getSObjectType() == Schema.Lead.sObjectType) {
                            DupLeadIds.add((Id) matchRecord.getRecord().get('Id'));
                        }
                    }
                }
            }
            index++;
        }
        
        return DupLeadIds;
    }
}