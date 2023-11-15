/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* AssistiveTechRequestService - Service to handle Inbound Request from Wordpress
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
* @author         DG - Float into the Clouds
* @modifiedBy     DG - Float into the Clouds
* @maintainedBy   DG - Float into the Clouds
* @version        1.1
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @changes
* Version			Developer			Date			Description
* 1.0				DG					2021-11-02		Handling Inbound Request - Operations Supported Create, Update
* 1.1				DG					2022-04-13		Commenting out Duplicate Check
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@RestResource(urlMapping='/AssistiveTechnologyRequestDelivery/*')
global class AssistiveTechRequestService {
    
    @HttpPost
    global static AssistiveTechRequestResponse handleUpsertRequest() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            String Operation = req.params.get('opt');
            
            if(String.isBlank(Operation)) throw new AssistiveTechRequestException(UNKOWN_OPERATION);
            else Operation = Operation.capitalize();
            
            Map<String, String> requestMap = (Map<String, String>) JSON.deserializeStrict(req.requestBody.toString(), Map<String, String>.class);
            
            if(requestMap.isEmpty()) {
                throw new AssistiveTechRequestException(INVALID_REQUEST);
            }
            
            validateRequest(requestMap, operation);
            processRequest(requestMap, operation);
            
            res.statusCode = 200;
            String successMessage = (Operation == CREATE_OPT) ? RECORD_CREATED : RECORD_UPDATED;
            return new AssistiveTechRequestResponse(successMessage, true);
        } catch (Exception e) {
            
            res.statusCode = 500;
            
            if(e.getTypeName() == 'TypeException') return new AssistiveTechRequestResponse(INVALID_DATA_TYPE, false);
            else return new AssistiveTechRequestResponse(e.getMessage(), false);
        }
    }
    
    /**
    * Validate the API Request
    * @param requestMap The API JSON Request in a Map
    */
    public static void validateRequest(Map<String, String> requestMap, String operation) {
        
        if(requestMap.isEmpty()) throw new AssistiveTechRequestException(INVALID_REQUEST);
        
        List<String> missingFields = new List<String>();
        
        for(WP_SF_Request_Attribute__mdt AttributeDef : WP_SF_Request_Attribute__mdt.getAll().values()) {
            
            String inputKey = AttributeDef.DeveloperName;
            String inputVal = requestMap.get(inputKey);
            Boolean validOpt = (AttributeDef.Operation__c == UPSERT_OPT || AttributeDef.Operation__c == operation);

            if(validOpt) {
                if(AttributeDef.Is_Required__c && String.isBlank(inputVal)) {
                    missingFields.add(inputKey);
                }else {
                    String dataType = AttributeDef.Data_Type__c;
                    
                    switch on dataType {
                        when 'DATE' {
                            Date.valueOf(inputVal);
                        }
                        when 'BOOLEAN' {
                            Boolean.valueOf(inputVal);
                        }
                        when 'INTEGER' {
                            Integer.valueOf(inputVal);                        
                        }
                    }
                }
            }
        }
        
        if(!missingFields.isEmpty()) throw new AssistiveTechRequestException(String.format(FIELDS_REQUIRED, 
                                                                                           new String[] { String.join(missingFields, ', ') }));
    }
    
    /**
    * Process the API Request
    * @param requestMap The API JSON Request in a Map
    */
    public static void processRequest(Map<String, Object> requestMap, String operation) {
        
        if(operation == CREATE_OPT) {
            
            //if(ATRDelivery != NULL) throw new AssistiveTechRequestException(DUPLICATE_RECORD_FOUND); //BEL-149
            
            Assistive_Technology_Project__c ATProject = getAssistiveTechProject(String.valueOf(requestMap.get('Project_Name')));
        	Contact contactRec = getTechnologyUser(requestMap);
            
            Assistive_Technology_RequestDelivery__c ATRDelivery = new Assistive_Technology_RequestDelivery__c(
                Request_Date__c = Date.valueOf(String.valueOf(requestMap.get('Request_Date'))),
                Name = String.valueOf(requestMap.get('Project_Name')), 
                MMC_Portal_Entry_ID__c = String.valueOf(requestMap.get('MMC_Portal_Entry_ID')),
                Stage__c = String.valueOf(requestMap.get('Stage')), 
                Technology_User__c = contactRec.Id, 
                Assistive_Technology_Project__c = (ATProject != NULL) ? ATProject.Id : NULL
            );
            
            insert ATRDelivery;
            
        }else if(operation == UPDATE_OPT) {
            
            Assistive_Technology_RequestDelivery__c ATRDelivery = getExistingATRDelivery(String.valueOf(requestMap.get('MMC_Portal_Entry_ID')));
            
            if(ATRDelivery == NULL) throw new AssistiveTechRequestException(NO_RECORD_FOUND);
            
            ATRDelivery.Stage__c = String.valueOf(requestMap.get('Stage'));
            update ATRDelivery;
        }
    }
    
    /**
    * Try to look for existing Assistive_Technology_RequestDelivery__c
    * @param MMCPortalId - The JSON Request Parameter: MMC_Portal_Entry_ID
    * @return Assistive_Technology_RequestDelivery__c
    */
    public static Assistive_Technology_RequestDelivery__c getExistingATRDelivery(String MMCPortalId) {
        
        if(String.isBlank(MMCPortalId)) return null;
        
        List<Assistive_Technology_RequestDelivery__c> ATRDs = [SELECT Id 
                                                               FROM Assistive_Technology_RequestDelivery__c 
                                                               WHERE MMC_Portal_Entry_ID__c =: MMCPortalId 
                                                               LIMIT 1];
        
        if(ATRDs.isEmpty()) {
            return null;
        }else {
            return ATRDs[0];
        }
    }
    
    /**
    * Try to look for existing Contact or create new one
    * @param requestMap - Incmoing JSON Request Map
    * @return Contact
    */
    public static Contact getTechnologyUser(Map<String, Object> requestMap) {
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email =: String.valueOf(requestMap.get('Email')) LIMIT 1];
        
        if(contacts.isEmpty()) {
        	Account acct = new Account(
                Name = String.valueOf(requestMap.get('Full_Name')) + ' - Household', 
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId(), 
                BillingStreet = String.valueOf(requestMap.get('MailingStreetAddress')), 
                BillingCity = String.valueOf(requestMap.get('MailingCity')), 
                BillingState = String.valueOf(requestMap.get('MailingState')), 
                BillingCountry = String.valueOf(requestMap.get('MailingCountry'))
            );
            
            insert acct;
            
           	Contact cont = new Contact( 
                LastName = String.valueOf(requestMap.get('Full_Name')), 
                Email = String.valueOf(requestMap.get('Email')),
                MailingStreet = String.valueOf(requestMap.get('MailingStreetAddress')), 
                MailingCity = String.valueOf(requestMap.get('MailingCity')), 
                MailingState = String.valueOf(requestMap.get('MailingState')), 
                MailingCountry = String.valueOf(requestMap.get('MailingCountry')), 
                Role_Is_Person_who_needs_AT__c = true, 
                AccountId = acct.Id                      
           	);
            
            insert cont;
            return cont;
        }else {
            return contacts[0];
        }
    }
    
    /**
    * Try to look for existing Assistive_Technology_Project__c record
    * @param projectName - The JSON Request Parameter: Project_Name
    * @return Assistive_Technology_Project__c
    */
    public static Assistive_Technology_Project__c getAssistiveTechProject(String projectName) {
        List<Assistive_Technology_Project__c> ATProjects = [SELECT Id 
                                                            FROM Assistive_Technology_Project__c 
                                                            WHERE Name =: projectName 
                                                            LIMIT 1];

        if(ATProjects.isEmpty()) { 
            return null;
        }else {
            return ATProjects[0];
        }
    }
    
    /**
    * Inner class that represents a response for the Request
    */
    global class AssistiveTechRequestResponse {
        public String message;
        public Boolean success;
        
        public AssistiveTechRequestResponse(String message, Boolean success) {
            this.message = message;
            this.success = success;
        }
    }
    
    /**
    * Inner class that represents a Exception
    */
    class AssistiveTechRequestException extends Exception {}
    
    /**
    * Class Definitions
    */
    public static final String CREATE_OPT 	= 'Create';
    public static final String UPDATE_OPT 	= 'Update';
    public static final String UPSERT_OPT 	= 'Upsert';
    public static String RECORD_UPDATED		= 'Record updated successfully';
    public static String RECORD_CREATED 	= 'Record created successfully';
    public static String NO_RECORD_FOUND 	= 'No record found';
    public static String DUPLICATE_RECORD_FOUND = 'Duplicate record found';
    public static String UNKOWN_OPERATION 	= 'Unknown operation';
    public static String PROJECT_NOT_FOUND 	= 'Assistive Technology Project not found';
    public static String GENERIC_ERROR 		= 'Something went wrong';
    public static String INVALID_REQUEST 	= 'Invalid request';
    public static String FIELDS_REQUIRED 	= 'Required Fields: {0}';
    public static String INVALID_DATA_TYPE 	= 'Invalid input';
    public static String INVALID_PARAMETER 	= 'Invalid parameter';
    
}