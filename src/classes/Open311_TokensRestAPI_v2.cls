@RestResource(urlMapping='/v2/tokens/*')
global with sharing class Open311_TokensRestAPI_v2{
     
     /*
        GET service_request_id from a token
        @Purpose :-
        Get the service_request_id from a temporary token. This is unnecessary if the 
        response from creating a service request does not contain a token.
        
       
        Formats XML /JSON
        HTTP Method - GET
        Requires API  - NO
        
        @Params:-
        jurisdiction_id :- This is only required if the endpoint serves multiple jurisdictions        
        token :- This is obtained from the POST Service Requests method
        
        Sample Call:     
        https://[API endpoint]/tokens/[tokens_code].[format]
         
    */
    @HttpGet
    global static void getServiceRequestId() {
         RestRequest req = RestContext.request; 
         RestResponse response = RestContext.response; 
         
         String format = req.requestURI.split('\\.').size()>1?req.requestURI.split('\\.')[1]:'';
         
         String responseStr;
         
         /*
          check to see whether token is passed
         */ 
         String token = req.params.get('token');
         if(token==null || token==''){
            response.statuscode =404; 
            responseStr= req.headers.get('Content-Type')==APIConstants.CONTENT_TYPE_JSON || format=='json'?
                   CustomException.sendJSONApiErrorResponse('Invalid token provided'):
                   CustomException.sendXMLApiErrorResponse('Invalid token provided');
            RestContext.response.responseBody =  Blob.valueOf(responseStr);   
            return;    
         }
         
         /*
          check to see whether jurisdiction_id is passed
         */
         String jId = req.params.get('jurisdiction_id');
         
         /*
           validate that the Juridiction Id is correct 
         */
         if(jId!=null && !APIValidations.isValidJuridiction(jId)){
            //invalid juridiction provided:-
            response.statuscode =404; 
            responseStr= req.headers.get('Content-Type')==APIConstants.CONTENT_TYPE_JSON || format=='json'?
                   CustomException.sendJSONApiErrorResponse('Invalid jurisdiction_id provided'):
                   CustomException.sendXMLApiErrorResponse('Invalid jurisdiction_id provided');
            RestContext.response.responseBody =  Blob.valueOf(responseStr);   
            return;   
         }  
         
         try{
              
              responseStr= req.headers.get('Content-Type')==APIConstants.CONTENT_TYPE_JSON || format=='json'?
                           Open311_TokenAPIResponse.sendJSONResponse(ServiceRequestsHelper.getRequestByToken(token)):
                           Open311_TokenAPIResponse.sendXMLResponse(ServiceRequestsHelper.getRequestByToken(token));
              
         }catch(CustomException e){
             response.statuscode =404; 
             responseStr= req.headers.get('Content-Type')==APIConstants.CONTENT_TYPE_JSON || format=='json'?
                   CustomException.sendJSONApiErrorResponse('Invalid token provided'):
                   CustomException.sendXMLApiErrorResponse('Invalid token provided');
         } 
         RestContext.response.responseBody =  Blob.valueOf(responseStr);
    }
}