@RestResource(urlMapping='/v2/citizenapp/user/register/*')
global with sharing class Open311_AppRegistrationAPI_v2 {

  @HttpPost
  global static void registerCommunityUser(String fname, String lname, String email, String password, String phone) {
    try {  
      System.debug('-----> Register Community User: Start');  
      RestContext.response.addHeader('Content-Type', 'application/json');
      // TODO: Check password validation.
       
      List<String> CommunityNickname = email.split('@', 2) ;
     
      User u = new User();
      u.FirstName= fname;
      u.LastName= lname;
      u.Username= email;
      u.Email = email;
      u.MobilePhone = phone;
      u.CommunityNickname= CommunityNickname[0] ;
    
      List<Account> portalId=[Select Id from Account where IsCustomerPortal = true];
      
      String accountId = portalId[0].Id;
      System.debug('----> User: ' + u);
      System.debug('----> accountId: ' + accountId);  
      System.debug('----> password: ' + password);  
      // lastName is a required field on user, but if it isn't specified, we'll default it to the username
      String userId = Site.createPortalUser(u, accountId, password);     
      System.debug('----> userId: ' + userId);  
      if (userId != null) { 
        if (password != null && password.length() > 7) {
            System.debug('---> Successful.');
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf('{"result": "Success", "user_id": "' + userId + '"}');
        }           
      }
    } catch (Exception e){
      System.debug('-----> Unable to complete insert: ' + e);
      System.debug(e.getStackTraceString());
      String errMsg = e.getMessage();
        
      if (errMsg.containsIgnoreCase('nickname')) {
        errMsg = 'The email address entered is already registered. Please register with an unique email address or reset your password.'; 
      }  
        
      RestContext.response.statusCode = 400;
      RestContext.response.responseBody = Blob.valueOf('{"error": "' + errMsg + '"}');
    }  
  }   
}