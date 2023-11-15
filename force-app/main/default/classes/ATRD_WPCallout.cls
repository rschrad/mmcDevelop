public class ATRD_WPCallout implements Queueable, Database.AllowsCallouts {
    
    //Constant Map variable of Stage and their respective code
    private static final Map<String, Integer> stageCodeMap = new Map<String, Integer>{
        'Maker Wanted' => 1,
        'Discuss Details' => 2,
        'Build Device' => 3, 
        'Prep for Delivery' => 4,
        'Reimburse Part Costs' => 5,
        'Delivered' => 6,
        'Cancelled' => 7
    };
        
    private List<AssistiveTechRequestController.WP_Request> requests;
    private Wordpress_Config__mdt wpConfig;
    private String accessToken;
    
    public ATRD_WPCallout(List<AssistiveTechRequestController.WP_Request> requests) {
        this.requests = requests;
        this.wpConfig = Wordpress_Config__mdt.getInstance('WP_Config');
        this.accessToken = this.wpConfig.Access_Token__c;
        
        Boolean authRequired = (this.wpConfig.Last_Token_Request__c == NULL || 
                                this.wpConfig.Last_Token_Request__c.addMinutes(30) < System.now());
        
        if(authRequired && !Test.isRunningTest()) {
            this.accessToken = WP_AuthenticationRequest();
        }
    }
    
    public void execute(QueueableContext context) {
        List<AssistiveTechRequestController.WP_Request> nextRequests = new List<AssistiveTechRequestController.WP_Request>();
        List<Assistive_Technology_RequestDelivery__c> ATRDs = new List<Assistive_Technology_RequestDelivery__c>();
        Integer recordCount = 0;

        for(AssistiveTechRequestController.WP_Request request : requests) {
            if(recordCount <= 99) {
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(wpConfig.Endpoint__c + '/wp-json/AssistiveTechnologyRequest/v2');
                req.setHeader('Authorization', 'Bearer ' + this.accessToken);
                req.setMethod('POST');
				
                JSONGenerator jsonGen = JSON.createGenerator(true);
                jsonGen.writeStartObject();
                jsonGen.writeNumberField('id', Integer.valueOf(request.id));
                jsonGen.writeNumberField('request_status', stageCodeMap.get(request.stage));
                jsonGen.writeStringField('email', request.email);
                jsonGen.writeEndObject();
                
                req.setBody(jsonGen.getAsString());
                HttpResponse res = h.send(req); 
                String response = res.getBody();
                
                ATRDs.add(new Assistive_Technology_RequestDelivery__c( 
                    Id = request.recordId,
                    WP_Request_Logs__c = response
                ));
                
                recordCount++;
            }else {
                nextRequests.add(request);
            }
        }
        
        if(!ATRDs.isEmpty()) update ATRDs;
        if(!nextRequests.isEmpty()) System.enqueueJob(new ATRD_WPCallout(requests));
    }
    
    public String WP_AuthenticationRequest() {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String endpointURL = String.format('{0}/wp-json/jwt-auth/v1/token?username={1}&password={2}', new List<String> 
                                           {
                                               this.wpConfig.Endpoint__c,
                                               this.wpConfig.Username__c,
                                               this.wpConfig.Password__c
                                           });
        req.setEndpoint(endpointURL);
        req.setMethod('POST');
        HttpResponse res = h.send(req);
        String response = res.getBody();
        Map<String, String> responseMap = (Map<String, String>)JSON.deserializeStrict(response, Map<String, String>.class); 
        
        if(responseMap.containsKey('token')) {
            // Custom Metadata "Wordpress_Config__mdt" field-value Mapping 
            Map<String, Object> mdt_fieldWithValuesMap = new Map<String, Object> 
            {
                'Access_Token__c' => responseMap.get('token'),
                'Last_Token_Request__c' => System.now()
            };
                    
            // Update "Wordpress_Config__mdt" Custom Metadata
            CreateUpdateMetadataUtils.createUpdateMetadata('Wordpress_Config__mdt.WP_Config', 'WP Config', mdt_fieldWithValuesMap);
            
            return responseMap.get('token');
        }else {
            return '';
        }
    }
    
}