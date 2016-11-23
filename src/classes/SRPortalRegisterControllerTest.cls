/**
 * Class containing tests for SRPortalRegisterController
 */
@IsTest public with sharing class SRPortalRegisterControllerTest {
    @IsTest(SeeAllData=true) static void testRegistration() {
        SRPortalRegisterController controller = new SRPortalRegisterController();
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
    }
    
    
}