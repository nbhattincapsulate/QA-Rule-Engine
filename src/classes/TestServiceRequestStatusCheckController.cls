/**
 * Class containing tests for ServiceRequestStatusCheckController
 */
@IsTest public with sharing class TestServiceRequestStatusCheckController {
    public static ServiceRequestStatusCheckController controller = new ServiceRequestStatusCheckController(); 
  
    
   // if requestId is null 
   @IsTest(SeeAllData=true) static void testaction1() {       
        
        controller.requestId = null;
        controller.action(); 
       
   } 
   
    //if email is null
   @IsTest(SeeAllData=true) static void testaction2() {  
        controller.requestId = '14-00001087'; 
        controller.email  = '';       
        controller.action(); 
        
   } 
  
   
   // if requestId && email is not equal to null
   @IsTest(SeeAllData=true) static void testaction3() {        
        controller.requestId = '14-00001087';
        controller.email = 'a@koncero.com';
        controller.action();  
       
   }
   
   
   
   // if requestId is invalid && email is not equal to null
   @IsTest(SeeAllData=true) static void testaction4() {        
        controller.requestId = '0001087';
        controller.email = 'a@koncero.com';     
        controller.action();  
       
   }
   
   // if caserecord is null
   @IsTest(SeeAllData=true) static void testaction5() {     
    
        controller.caserecord = null;       
        controller.action();  
       
   }
   
   @IsTest(SeeAllData=true) static void testaction6() {    
        controller.requestId = '14-00001087';        
        controller.action();  
       
   }
    
 
}