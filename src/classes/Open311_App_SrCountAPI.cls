@RestResource(urlMapping='/citizenapp/user/srcount/*')
global with sharing class Open311_App_SrCountAPI{
/*The API is to query number of Open SR's and Total SR's with the UserID provided*/

@HttpGet
global static void countUserSR(){
try{
    System.debug('----->Start Receiving UserId for CountUserSR of Class Open311_App_SrCountAPI');
    RestContext.response.addHeader('Content-Type', 'application/json');
    String uId= RestContext.request.params.get('UserId');
    
    System.debug('User Id is ---->' + uId);
    Integer OpenCases = [SELECT COUNT() FROM Case Where ContactId != null AND Status='Open' AND ContactId IN (SELECT ContactId FROM User WHERE id= :uId)];
    Integer AllCases = [SELECT COUNT() FROM Case Where ContactId != null AND ContactId IN (SELECT ContactId FROM User WHERE id= :uId)];
     
    System.debug('----> Successful.'+  'Number of OpenCases ---->' + OpenCases + 'Number Total Cases---->' + AllCases);     
    RestContext.response.statusCode = 200;
    RestContext.response.responseBody = Blob.valueOf('{"result": "Success", "open": "' + OpenCases + '", "total": "' + AllCases + '"}');      
   }    
   catch (Exception e){
      System.debug('-----> Unable to find the user: ' + e);
      System.debug(e.getStackTraceString());
      String errMsg = e.getMessage();
      RestContext.response.statusCode = 400;
      RestContext.response.responseBody = Blob.valueOf('{"error": "' + errMsg + '"}');               
    }   
   }
}