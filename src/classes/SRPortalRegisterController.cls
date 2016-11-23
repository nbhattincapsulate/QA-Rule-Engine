/**
 * An apex class that creates a portal user
 */
public with sharing class SRPortalRegisterController {

    public String NameFirst { get; set; } 
    public String NameLast { get; set; }  
	public String Email {get; set;}
	public String Password {get; set {Password = value == null ? value : value.trim(); } }
    public String RetypePassword { get; set { RetypePassword = value == null ? value : value.trim(); } }
    public boolean rend{get; set;}
    public String userId {get; set;}
    public String errorMessage {get;set;}
   
    // PORTAL_ACCOUNT_ID is the account on which the contact will be created on and then enabled as a portal user.
    // you need to add the account owner into the role hierarchy before this will work - please see Customer Portal Setup help for more information.       
    //private static Id PORTAL_ACCOUNT_ID = '001r0000001ngOo';
    
    public SRPortalRegisterController () {
        rend =true;
        errorMessage = '';
    }
  
    private boolean isValidPassword() {
        return Password == RetypePassword; 
    }
    
    public void updateUserProfile(){
    	if(userId != null)
    	{
    		User u = new User(Id=userId);
	    	u.FirstName = NameFirst;
	    	u.LastName = NameLast;
	    	u.Email = Email;
	    	update(u);
    	}
    }
	
    public PageReference registerUser() {
      try{
        // it's okay if password is null - we'll send the user a random password in that case
        if (!isValidPassword()) {
            rend = true;
            
            ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(error_msg);
            errorMessage = Label.site.passwords_dont_match;
            return null;
        }
        
        LIST<String> CommunityNickname = Email.split('@', 2) ;
        
        User u = new User();
        u.FirstName= NameFirst;
        u.LastName= NameLast;
        u.Username= Email ;
        u.Email = Email ;
        u.CommunityNickname= CommunityNickname[0] ;
        
        LIST<Account> portalId=[Select Id from Account where IsCustomerPortal = true];
        
        String accountId =  portalId[0].Id;
        
        // lastName is a required field on user, but if it isn't specified, we'll default it to the username
        userId = Site.createPortalUser(u, accountId ,Password);     
        
        if (userId != null) { 
            if (Password != null && Password.length() > 7) {
                return Site.login(Email, Password, '/Home');
            }           
        }
            
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        if(pageMessages != null && pageMessages.size()>0){
          if (String.isNotBlank(pageMessages[0].getSummary())) {
            errorMessage = pageMessages[0].getSummary();    
            // If the error message contains the word nickname then replace it with email. This makes it more aparent to the user what is wrong.  
            if (errorMessage.containsIgnoreCase('nickname')) {
              errorMessage = errorMessage.replace('nickname', 'email');  
            }
          } else {
            errorMessage = 'Error Processing. Please contact administrator.';
          }
        } else {
        	errorMessage = 'Error Processing. Please contact administrator.';
        }
        return null;
      }catch(Exception e){
          errorMessage = 'Error Processing. Please contact administrator.';  
          system.debug('-----> Unable to complete insert: ' + e);
          return null;
      }  
    }
}