@RestResource(urlMapping='/v2/discovery')
global class Open311_ServiceDiscoveryRestAPI_v2 {

    Static String endPoint ='http://api.mycity.gov/apexrest/services/v2';

    @HttpGet
    global static void doGet() {
         RestRequest req = RestContext.request; 
         
         if(RestContext.response==null) RestContext.response = new RestResponse();
         
         RestResponse response = RestContext.response!=null?RestContext.response : new RestResponse(); 
         
         String format = req.requestURI.split('\\.').size()>1?req.requestURI.split('\\.')[1]:'';
         
         String responseStr =  req.headers.get('Content-Type')==APIConstants.CONTENT_TYPE_JSON || format=='json' ?
         sendJSONResponse():
         sendXMLResponse();
         
         RestContext.response.responseBody =  Blob.valueOf(responseStr);
             
    }
    
    
    private static String sendJSONResponse(){
        
        List<Open311ServiceConfig__c> config =Open311ServiceConfig__c.getall().values();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
            gen.writeStringField('changeset',String.valueof(Datetime.now()));  
            gen.writeStringField('contact','You can email or call for assistance '+config[0].support_email__c+' '+config[0].support_phone__c+'');  
            gen.writeStringField('key_service','You can request a key here: '+endPoint+'/api_key/request');  
            gen.writeFieldName('endpoints'); 
                gen.writeStartArray();
                    for(Open311ServiceConfig__c c : config){
                        gen.writeStartObject();
                            gen.writeStringField('specification','http://wiki.open311.org/GeoReport_v2');  
                            gen.writeStringField('url',c.Open311ProductionURL__c);  
                            gen.writeStringField('changeset',endPoint); 
                            gen.writeStringField('type','production'); 
                            gen.writeFieldName('formats'); 
                                gen.writeStartArray();
                                    gen.writeString('text/xml');
                                    gen.writeString('application/json');    
                                gen.writeEndArray();
                        gen.writeEndObject();
                        
                        gen.writeStartObject();
                            gen.writeStringField('specification','http://wiki.open311.org/GeoReport_v2');  
                            gen.writeStringField('url',c.Open311TestURL__c);  
                            gen.writeStringField('changeset',endPoint); 
                            gen.writeStringField('type','test'); 
                            gen.writeFieldName('formats'); 
                                gen.writeStartArray();
                                    gen.writeString('text/xml');
                                    gen.writeString('application/json');    
                                gen.writeEndArray();
                        gen.writeEndObject();
                    
                    }

                gen.writeEndArray();
        gen.writeEndObject();
           
        
        
        return gen.getAsString();
    }
    
    private static String sendXMLResponse(){
        
        List<Open311ServiceConfig__c> config =Open311ServiceConfig__c.getall().values();
        
        Dom.Document doc = new Dom.Document();
        Dom.Xmlnode rootNode = doc.createRootElement('discovery', null, null); 
        rootNode.addChildElement('changeset', null, null).addTextNode('');
        rootNode.addChildElement('contact', null, null).addTextNode('You can email or call for assistance '+config[0].support_email__c+' '+config[0].support_phone__c);
        rootNode.addChildElement('key_service', null, null).addTextNode('You can request a key here: '+endPoint+'/api_key/request');
        
        Dom.Xmlnode endpoints = rootNode.addChildElement('enpoints', null, null);
        for(Open311ServiceConfig__c c : config){ 
            Dom.Xmlnode endpointP = endpoints.addChildElement('enpoint', null, null);
            endpointP.addChildElement('specification', null, null).addTextNode('http://wiki.open311.org/GeoReport_v2');
            endpointP.addChildElement('url', null, null).addTextNode(c.Open311ProductionURL__c);
            endpointP.addChildElement('changeset', null, null).addTextNode('');
            endpointP.addChildElement('type', null, null).addTextNode('production');
            
            Dom.Xmlnode formatsP =  endpointP.addChildElement('formats', null, null);
            formatsP.addChildElement('format', null, null).addTextNode('text/xml');
            formatsP.addChildElement('format', null, null).addTextNode('application/json');
            
            Dom.Xmlnode endpointT = endpoints.addChildElement('enpoint', null, null);
            endpointT.addChildElement('specification', null, null).addTextNode('http://wiki.open311.org/GeoReport_v2');
            endpointT.addChildElement('url', null, null).addTextNode(c.Open311TestURL__c);
            endpointT.addChildElement('changeset', null, null).addTextNode('');
            endpointT.addChildElement('type', null, null).addTextNode('test');
            
            Dom.Xmlnode formatsT =  endpointT.addChildElement('formats', null, null);
            formatsT.addChildElement('format', null, null).addTextNode('text/xml');
            formatsT.addChildElement('format', null, null).addTextNode('application/json');
            
        }
        return doc.toXMLString();
    }

}