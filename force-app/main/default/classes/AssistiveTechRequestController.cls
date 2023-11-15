/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Controller to handle all the SObject "Assistive Technology Request/Delivery" actions.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
* @author         Float into the Clouds <www.floatintotheclouds.com>
* @modifiedBy     Float into the Clouds <www.floatintotheclouds.com>
* @maintainedBy   Float into the Clouds <www.floatintotheclouds.com>
* @version        1.0
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @changes
* Version			Developer			Date			Description
* 1.0				DG					2021-10-08		Make a callout to Wordpress, whenever 
"Status" field is updated on the record.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public without sharing class AssistiveTechRequestController {

    @InvocableMethod(callout=true label='Record Change Handler' description='Handle any record changes within this method.' category='Assistive_Technology_RequestDelivery__c')
    public static void handleRecordChange(List<WP_Request> requests) { 
        System.enqueueJob(new ATRD_WPCallout(requests));
    }

    public class WP_Request {
        @InvocableVariable(label='Record Id' description='Record Id of Technology User' required=true)
        public String recordId;
        
        @InvocableVariable(label='Techonology User Email' description='Email Address of Technology User' required=true)
        public String email;
        
        @InvocableVariable(label='MMC Portal Entry ID' description='MMC Portal Entry Id' required=true)
        public String id;
        
        @InvocableVariable(label='Stage' description='Stage Code' required=true)
        public String stage;
    }
    
}