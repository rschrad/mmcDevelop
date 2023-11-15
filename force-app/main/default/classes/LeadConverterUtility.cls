public class LeadConverterUtility {
    
    final static Integer DUPS_INPUT_LIMIT = 1; // DO NOT CHANGE THIS LIMIT
    
    @InvocableMethod(label='Convert Leads')
    public static void convertLeads(List<Id> LeadIds) {
        String query = 'SELECT Id FROM Lead WHERE Id IN (\'' + String.join(LeadIds, '\',\'') + '\')';
        if(!Test.isRunningTest()) Database.executeBatch(new LeadConverterBatch(query), DUPS_INPUT_LIMIT);
    }
    
    public static void handleLeadConversion(List<Id> LeadIds) {
        Map<Id, Id> leadToContactIdMap = findDuplicateContacts(LeadIds);
        Map<Id, Id> dupLeadContactIdMap = new Map<Id, Id>();
        Set<Id> newLeadIds = new Set<Id>();
        
        for(Id leadId : leadToContactIdMap.keySet()) {
            Id contactId = leadToContactIdMap.get(leadId);
            if(contactId == null) {
                newLeadIds.add(leadId);
            }else {
                dupLeadContactIdMap.put(leadId, contactId);
            }
        }
        
        System.debug('NEW LEAD IDs ::: ' + newLeadIds.size());
        System.debug('DUP LEAD IDs ::: ' + dupLeadContactIdMap.size());
        
        if(newLeadIds.size() > 0) {
            newLeadConversion(new List<Id>(newLeadIds));
        }
        
        if(dupLeadContactIdMap.size() > 0) {
            duplicateLeadConversion(dupLeadContactIdMap);
        }
    }
    
    private static Map<Id, Id> findDuplicateContacts(List<Id> LeadIds) {
        Map<Id, Id> leadToContactIdMap = new Map<Id, Id>();
        Integer index = 0;
        
        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicatesByIds.findDuplicatesByIds(LeadIds);
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
            leadToContactIdMap.put(LeadIds[index], NULL);
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                    for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                        SObject record = matchRecord.getRecord();
                        if(record.getSObjectType() == Schema.Contact.sObjectType) {
                            leadToContactIdMap.put(LeadIds[index], record.Id);
                        }
                    }
                }
            }
            index++;
        }
        
        return leadToContactIdMap;
    }
    
    public static void duplicateLeadConversion(Map<Id, Id> leadToContactIdMap) {
        LeadStatus ConvLeadStatus 	= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
        Map<Id, Contact> contactMap = getContacts(new Set<Id>(leadToContactIdMap.values()));
        Map<Id, Lead> LeadMap 		= getLeads(leadToContactIdMap.keyset());
        List<Database.LeadConvert> Dup_MassLeadconvert = new List<Database.LeadConvert>();
        
        for(Id leadId : leadToContactIdMap.keySet()) {
            Contact cont = contactMap.get(leadToContactIdMap.get(leadId));
            Database.LeadConvert Leadconvert = new Database.LeadConvert();
            Leadconvert.setLeadId(leadId);
            Leadconvert.setAccountId((Id) cont.get('AccountId'));
            Leadconvert.setContactId((Id) cont.get('Id'));
            Leadconvert.setConvertedStatus(ConvLeadStatus.MasterLabel);
            Leadconvert.setDoNotCreateOpportunity(true);
            Dup_MassLeadconvert.add(Leadconvert);
        }
        
        if (!Dup_MassLeadconvert.isEmpty()) {
            try {
                List<Contact> updateContacts = new List<Contact>();
                List<Database.LeadConvertResult> lcrs = Database.convertLead(Dup_MassLeadconvert, false);
                Lead_Conversion_Setting__mdt leadConvSetting = [SELECT Lead_To_Contact_Mapping__c FROM Lead_Conversion_Setting__mdt LIMIT 1];
                Map<String, String> fieldMapping = (Map<String, String>) JSON.deserializeStrict(leadConvSetting.Lead_To_Contact_Mapping__c, Map<String, String>.class);
                
                for(Database.LeadConvertResult lcr : lcrs) {
                    if(lcr.isSuccess()) {
                        Boolean modifiedContact = false;
                        Lead ld = leadMap.get(lcr.getLeadId());
                        Contact con = contactMap.get(lcr.getContactId());                       
                        
                        for(String fieldName : fieldMapping.keySet()) {
                            if((ld.get(fieldName) != NULL && con.get(fieldMapping.get(fieldName)) == NULL) 
                               || ld.get(fieldName) == true && con.get(fieldMapping.get(fieldName)) == false 
                               || fieldMapping.get(fieldName) == 'Lead_Email_Address__c' 
                               || fieldMapping.get(fieldName) == 'Lead_Phone_Number__c') 
                            {
                                con.put(fieldMapping.get(fieldName), ld.get(fieldName));
                            }
                        }
                        
                        updateContacts.add(con);
                        System.debug('Dup_LDC_Passed :::: ' + lcr.getLeadId());
                    }else {
                        System.debug('Dup_LDC_Failed :::: ' + lcr.getErrors()[0].getMessage());
                    }
                }
                
                if(updateContacts.size() > 0) {
                	Database.update(updateContacts, false);
                }
            }catch(UnexpectedException e) {
                System.debug(e.getMessage());
            }
        }
    }
    
    public static void newLeadConversion(List<Id> LeadIds) {
        
        LeadStatus ConvLeadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
        List<Database.LeadConvert> New_MassLeadconvert = new List<Database.LeadConvert>();
        
        for(Id leadId : LeadIds) {
            Database.LeadConvert Leadconvert = new Database.LeadConvert();
            Leadconvert.setLeadId(leadId);                
            Leadconvert.setConvertedStatus(ConvLeadStatus.MasterLabel);
            Leadconvert.setDoNotCreateOpportunity(true);
            New_MassLeadconvert.add(Leadconvert);
        }
        
        if (!New_MassLeadconvert.isEmpty()) {
            try {
                List<Database.LeadConvertResult> lcrs = Database.convertLead(New_MassLeadconvert);
                
                for(Database.LeadConvertResult lcr : lcrs) {
                    if(lcr.isSuccess()) {
                        System.debug('LDC_Passed :::: ' + lcr.getLeadId());
                    }else {
                        System.debug('LDC_Failed :::: ' + lcr.getErrors()[0].getMessage());
                    }
                }
            }catch(UnexpectedException e) {
                System.debug(e.getMessage());
            }
        }
    }
    
    public static Map<Id, Contact> getContacts(Set<Id> contactIds) {
        return new Map<Id, Contact>([SELECT Id, AccountId, FirstName, LastName, Lead_Email_Address__c,Lead_Phone_Number__c,Consent_Date__c,Consent_Method__c,
                                     Facebook_Profile__c,Git_Hub__c,Instagram_Profile__c,Interested_in_Assistive_Tech_Details__c,
                                     Interested_in_Assistive_Technology__c,Interested_in_Community_Service_Detail__c,Interested_in_community_service__c,
                                     Interested_in_Employment_Details__c,Interested_in_Employment__c,LinkedIn_Profile__c,npe01__Preferred_Email__c,
                                     npe01__PreferredPhone__c,Region__c,Role_Is_Chapter_Lead__c,Role_Is_Disability_Professional__c,Role_Is_Maker__c,
                                     Role_Is_Other__c,Role_Is_Person_who_needs_AT__c,Role_Is_Teacher__c,Skill_3d_Printing__c,Skill__c,Skill_Design__c,
                                     Skill_Electronics__c,Skill_Engineering__c,Skill_Laser_Cutting__c,Skill_Mechanics__c,Skill_Software__c,Skill_Soldering__c,
                                     Skill_Welding__c,Skill_Wood_Working__c,Thingiverse__c,Twitter_Profile__c 
                                     FROM Contact 
                                     WHERE Id IN : contactIds]);
    }
    
    public static Map<Id, Lead> getLeads(Set<Id> leadIds) {
        return new Map<Id, Lead>([SELECT Id, FirstName, LastName, Email, Phone,Email_Consent_Date__c,Email_Consent_Method__c,Facebook_Profile__c, 
                                  Git_Hub__c,Instagram_Profile__c,Interested_in_Assistive_Tech_Details__c,Interested_in_Assistive_Technology__c, 
                                  Interested_in_Community_Service_Detail__c,Interested_in_community_service__c,Interested_in_Employment_Details__c,
                                  Interested_in_Employment__c,LinkedIn_Profile__c,npe01__Preferred_Email__c,npe01__Preferred_Phone__c,Region__c,
                                  Role_Is_Chapter_Lead__c,Role_Is_Disability_Professional__c,Role_IsMaker__c,Role_Is_Other__c,Role_Is_Person_who_needs_AT__c,
                                  Role_Is_Teacher__c,Skill_3d_Printing__c,Skill_CAD__c,Skill_Design__c,Skill_Electronics__c,Skill_Engineering__c,
                                  Skill_Laser_Cutting__c,Skill_Mechanics__c,Skill_Software__c,Skill_Soldering__c,Skill_Welding__c,Skill_Wood_Working__c,
                                  Thingiverse__c,Twitter_Profile__c 
                                  FROM Lead 
                                  WHERE Id IN : leadIds]);
    }
    
}