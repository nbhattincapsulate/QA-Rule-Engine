@RestResource(urlMapping='/v2/services/*')
global with sharing class Open311_ServicesRestAPI_v2{
    
    /*   
        GET Service List / Get Service Definations
        @Purpose :-
        provide a list of acceptable 311 service request types and their associated service codes. 
        These request types can be unique to the city/jurisdiction.
        
        or 
        When service code is passes:-Define attributes associated with a service code. These attributes can be unique to the city/jurisdiction.
      
        Formats XML /JSON
        HTTP Method - GET
        Requires API  - NO
        
        @Params:-
        jurisdiction_id :- This is only required if the endpoint serves multiple jurisdictions        
        service_code :- The service_code is specified in the main URL path rather than an added query string parameter.
        
        Sample Call:-
        https://[API endpoint]/services.[format]
        https://[API endpoint]/services/[service_code].[format]
        
         1. GET /services - Returns a collection of sObjects 
             
           
         2. GET /services/servicecode - Returns a service   
    */ 
    @HttpGet
    
    global static void getServices() {
         RestRequest req = RestContext.request; 
         
         if(RestContext.response==null) RestContext.response= new RestResponse();
         
         RestResponse response = RestContext.response; 
         
         String format = req.requestURI.split('\\.').size()>1?req.requestURI.split('\\.')[1]:'';
         
         String responseStr;
         
          /*
          API KEY SUPPORT             
         */
        String apiKey = req.params.get('api_key');
        APIValidations.APIKeyResponse apiKeyRes = new APIValidations.APIKeyResponse();
    	
        if (String.isNotBlank(apiKey)) {
            apiKeyRes = Open311APIHelper.checkAPIKey(apiKey, req, response, format);
            if (apiKeyRes == null) {
              apiKeyRes = new APIValidations.APIKeyResponse();
              apiKeyRes.isPrivate = false;
            }
        }
         /*
          check to see whether jurisdiction_id is passed
         */
         String jId = req.params.get('jurisdiction_id');
         
         /*
           validate that the Juridictoion Id is correct 
         */
         if(jId!=null && !APIValidations.isValidJuridiction(jId)){
            //invalid juridiction provided:-
            response.statuscode =404; 
             responseStr =  req.headers.get('Content-Type')==APIConstants.CONTENT_TYPE_JSON || format=='json'?
                    CustomException.sendJSONApiErrorResponse('Invalid jurisdiction_id provided'):
                    CustomException.sendXMLApiErrorResponse('Invalid jurisdiction_id provided'); 
            RestContext.response.responseBody =  Blob.valueOf(responseStr);  
            Open311APIHelper.logRequest(req,'Error','Invalid jurisdiction_id provided :'+jId);      
            return;
         }  
         
         try{ 
             // see if a service code was  part of the URI
             String serviceCode= req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
             serviceCode = serviceCode.split('\\.').size()>1?serviceCode.split('\\.')[0]:serviceCode; 
             
              
             if (serviceCode!= '' && !serviceCode.startsWith('services')) {
                  //we have the service code here  : this is always done only if metadat =true
                   responseStr=  req.headers.get('Content-Type')==APIConstants.CONTENT_TYPE_JSON || format=='json' ?                   
                                 Open311_ServicesAPIResponse.sendJSONResponse(ServicesHelper.getService(serviceCode),ServicesHelper.getServiceMetadata2(serviceCode)): 
                                 Open311_ServicesAPIResponse.sendXMLResponse(ServicesHelper.getService(serviceCode),ServicesHelper.getServiceMetadata2(serviceCode)); 
             } else {
                  responseStr=req.headers.get('Content-Type')==APIConstants.CONTENT_TYPE_JSON || format=='json'?                 
                              Open311_ServicesAPIResponse.sendJSONResponse(ServicesHelper.listAllServices(jId),apiKeyRes.isPrivate):
                              Open311_ServicesAPIResponse.sendXMLResponse(ServicesHelper.listAllServices(jId),apiKeyRes.isPrivate);                     
             } 
              Open311APIHelper.logRequest(req,'Success','Services successfully returned as response '); 
              
         }catch(CustomException e){             
                String message = e.getMessage();
                if(APIConstants.NOT_FOUND==e.getMessage()){
                    response.statuscode =404;          
                    message  ='Invalid service_code provided';      
                    responseStr= req.headers.get('Content-Type')==APIConstants.CONTENT_TYPE_JSON || format=='json'?
                                 CustomException.sendJSONApiErrorResponse(message):
                                 CustomException.sendXMLApiErrorResponse(message);              
                }    
                 Open311APIHelper.logRequest(req,'Error',message);            
         } 
        
         RestContext.response.responseBody =   Blob.valueOf(responseStr);   

    }
    
}