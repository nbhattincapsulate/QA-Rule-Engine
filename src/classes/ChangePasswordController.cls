/**
 * An apex page controller that exposes the change password functionality
 */
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}
    public Boolean isResetSuccessful {get; set;}
    public String errorMsg {get; set;}      
    
    public PageReference changePassword() {
        PageReference ref = Site.changePassword(newPassword, verifyNewPassword, oldPassword);    
        
        if(ref == null){
        	isResetSuccessful = true;
        	ApexPages.Message[] pageMessages = ApexPages.getMessages();
        	if(pageMessages != null && pageMessages.size()>0){
        		errorMsg = pageMessages[0].getSummary();
        	}
        	else
        	{
        		errorMsg = 'Error Processing. Please contact administrator.';
        	}
        }
        
        return ref;
    }     
    
   	public ChangePasswordController() {
   		isResetSuccessful = false;
   		errorMsg = '';
   	}
}