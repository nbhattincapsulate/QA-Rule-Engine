/**
 * Class containing tests for SiteRegisterController
 */
@IsTest public with sharing class SiteRegisterControllerTest {
    /*@IsTest(SeeAllData=true) static void testRegistration() {
        SiteRegisterController controller = new SiteRegisterController();
        //controller.username = 'test@force.com';
        controller.email = 'test@force.com';
        //controller.communityNickname = 'test';
        // registerUser will always return null when the page isn't accessed as a guest user
        //System.assert(controller.registerUser() == null);    
        controller.userId ='005r0000000HiTv';
        controller.password = 'abcd123';        
        controller.RetypePassword = 'abcd123';
        account a=new account (Name='Ouc portal');
        insert a;         
        controller.registerUser();
        
        controller.userId ='005r0000000HiTv';
        controller.password = 'abcd123';        
        controller.RetypePassword = 'abcd123';                 
        controller.registerUser();      
        
        controller.userId ='005r0000000HiTv';
        controller.password = 'abcd123';        
        controller.RetypePassword = 'abcd1234';                  
        controller.registerUser();      
        //System.assert(controller.registerUser() == null);  
    }*/
    
   /*@IsTest(SeeAllData=true) static void testRegistration1() {
        SiteRegisterController controller = new SiteRegisterController();
        //controller.username = 'test@force.com';
        controller.email = 'test@force.com';
       // controller.communityNickname = 'test';
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        controller.userId ='005r0000000HiTv';
        controller.password = 'abcd1234';
        controller.RetypePassword = 'abcd123';
        System.assert(controller.registerUser() == null); 
        
        controller.userId =null;
        controller.password = 'abcd123';     

        System.assert(controller.registerUser() == null);  
    }*/ 
    
    /**
 * Test class.
 */


    // Test method for verifying the positive test case
    static testMethod void testRegistration() {
        SiteRegisterController controller = new SiteRegisterController();
        //controller.username = 'test@force.com';
        controller.email = 'test@force.com';
        //controller.communityNickname = 'test';
        // registerUser always returns null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);
        controller.password = 'abcd1234';
        controller.RetypePassword = 'abcd123';       
        System.assert(controller.registerUser() == null);
        
        //controller.username = 'test@force.com';
        controller.email = 'test@force.com';
        //controller.communityNickname = 'test';
        // registerUser will always return null when the page isn't accessed as a guest user
        //System.assert(controller.registerUser() == null);
        Set<String> customerUserTypes = new Set<String> {'Customer Community Login User', 'Standard User', 'OUC SuperUser'};
            
        //User thisUser = [ select Id from User where isactive=true and UserRole.name='User' limit 1];
 		User thisUser = [ select Id from User where isactive=true and Id=:UserInfo.getUserId() limit 1];
        System.runAs (thisUser) {
            //UserRole ur = [Select Id From UserRole where Name='OUC Portal' limit 1];
            Profile p =new Profile();
            p = [select Id,name from Profile where Name='Customer Community Login User' limit 1];
            System.debug('----> Profile: ' + p);
            Account acc = new Account (Name = 'Ouc portal');  
            insert acc;   
            acc = [Select Id From Account Where Name = 'Ouc portal'];
            Contact con = new Contact (LastName = 'portalTestUser',AccountID =acc.Id);
            insert con;
            con = [Select Id From Contact Where LastName = 'portalTestUser' AND AccountID = :acc.Id];
            User newUser = new User(
                //UserRoleId = ur.id,
                profileId = p.id,
                username = 'newUser@yahoo.com',
                email = 'pb@ff.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = con.id
            );
            //insert newUser; 
            
            //controller.userId =newUser.Id;
            controller.password = 'abcd123';        
            controller.RetypePassword = 'abcd123';
                   
            //System.assert(controller.registerUser() == null);
         }      
        /*Profile p =new Profile();
        p = [select Id,name from Profile where Name='Customer Community Login User' limit 1];
        account a=new account (Name='Ouc portal');
        insert a;  
        Contact con = new Contact (LastName = 'portalTestUser',AccountID =a.Id);
        insert con;
        User newUser = new User(
                    //UserRoleId = ur.id,
                    profileId = p.id,
                    username = 'newUser@yahoo.com',
                    email = 'pb@ff.com',
                    emailencodingkey = 'UTF-8',
                    localesidkey = 'en_US',
                    languagelocalekey = 'en_US',
                    timezonesidkey = 'America/Los_Angeles',
                    alias='nuser',
                    lastname='lastname',
                    contactId = con.id
        );
        insert newUser;*/      
       
    }
  
}