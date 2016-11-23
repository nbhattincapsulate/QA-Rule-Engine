/**
 * An apex class that creates a portal user
 */
public with sharing class SiteRegisterController {

    public String PhoneExt { get; set; }

    public String Phone { get; set; }   

    public String Address_Zip { get; set; }

    public String Address_State { get; set; }

    public String Address_City { get; set; }

    public String Address_StreetAddress { get; set; }   

    public String NameLast { get; set; }

    public String NameFirst { get; set; }   

    public String RetypePassword { get; set { RetypePassword = value == null ? value : value.trim(); } }
    
    public String Email {get; set;}
    
    public String Password {get; set {password = value == null ? value : value.trim(); } }
    
    public boolean rend{get; set;}
    
    public String userId {get; set;}
   
    // PORTAL_ACCOUNT_ID is the account on which the contact will be created on and then enabled as a portal user.
    // you need to add the account owner into the role hierarchy before this will work - please see Customer Portal Setup help for more information.       
    //private static Id PORTAL_ACCOUNT_ID = '001r0000001ngOo';
    
    public SiteRegisterController () {
        rend =true;
        
        system.debug('Invoke Controller----->');
        Address_City='WASHINGTON';
        Address_State='WASHINGTON';        
       
    }
  
    private boolean isValidPassword() {
        return password == RetypePassword; 
    }
    
    public PageReference registerUser() {
        try{
        // it's okay if password is null - we'll send the user a random password in that case
        if (!isValidPassword()) {
            rend = true;
            
            ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(error_msg);
            return null;
        }
        
        
        LIST<String> CommunityNickname = Email.split('@', 2) ;
        
        User u = new User();
        u.Username= Email ;
        u.Email = Email ;
        u.CommunityNickname= CommunityNickname[0] ;
        u.LastName= NameLast ;
        u.FirstName= NameFirst ;
        u.Street = Address_StreetAddress ;
        u.City= Address_City ;
        //u.CountryCode= Address_Zip ;
        u.Phone= Phone ;
        u.Extension= PhoneExt ;
        u.State= Address_State ;
        //u.Alias= CommunityNickname[0] ;   
           
        LIST<Account> portalId=[Select Id from Account where IsCustomerPortal = true];
        system.debug('portalId----->'+ portalId);
        String accountId =  portalId[0].Id;
        system.debug('accountId ----->'+ accountId );
        
        system.debug('User----->'+ u );
        system.debug('invoking method----->'+ u + accountId +Password  );

        // lastName is a required field on user, but if it isn't specified, we'll default it to the username
        userId = Site.createPortalUser(u, accountId ,Password  );     
        system.debug('UserID----->'+ userId );
        
        if (userId != null) { 
            if (password != null && password.length() > 1) {
                return Site.login(Email, Password, null);
            }           
        }
        return null;
        
      }catch(Exception e){
          system.debug('unable to complete insert-->'+e);
          return null;
      }  
    }
  
}