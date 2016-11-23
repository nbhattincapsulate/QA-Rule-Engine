/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class SiteLoginController {    

    public String Email { get; set; }
    global String username{get; set;}
    global String password {get; set;} 
    global Boolean isLoginFailed {get; set;}  

    
        public PageReference login() {
	        String startUrl = System.currentPageReference().getParameters().get('startURL');
	        PageReference ref = Site.login(username, password, startUrl);
	        
	        if(ref == null){
	        	isLoginFailed = true;
	        }
	        
	        return ref;
	    }
     
 		public SiteLoginController () {
 			isLoginFailed = false;
 		}
}