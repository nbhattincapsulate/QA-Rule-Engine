public with sharing class ServiceRequestStatusCheckController{
     
     public string Id{get;set;}
     public string requestId{get;set;}
     public string email{get;set;}
     public string email_address{get;set;}
     public Service_Request_History__c caserecord{get{system.debug('caserecord--->'+caserecord); return caserecord;}set;}
     public Boolean render{get;set;}
     public Boolean rend{get;set;}
     public Boolean home_rend{get;set;}
    // public OUC_Activity_History__c oucacthistory{get{system.debug('oucacthistory--->'+oucacthistory); return oucacthistory;}set;}
     
     public LIST<ServiceRequestType__c> servicename {get;set;}
     
     /**  
       *  constructor          
     */   
     public ServiceRequestStatusCheckController(){
        render=false; 
        rend=true; 
        home_rend =true;   
    }
    
     /**
       *       
       * To invoke getRequest and return the particular case 
       * 
       */
     public PageReference action(){
               
         
         if(requestId == null || requestId == ''){
             render=false;
             rend=true;
            
             
             ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'A service request number is required to lookup status. Please enter a valid service request number.');
             ApexPages.addMessage(error_msg);
             
             system.debug('requestId ---->');
             
             return null;
             
         }
                     
         /*if(email == null || email == ''){
             render=false;
             rend=true;
               
             
             ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'A valid email address is required to lookup status. Please enter a valid email address.');
             ApexPages.addMessage(error_msg);
             
             system.debug('requestId ---->');
             
             return null;             
           
             
         }*/
           
           
         if(requestId != null){ 
             render=true;
             rend=false;
             home_rend =false;   
             
             try{  
                 caserecord=getRequest(requestId);
                 string SrID= caserecord.SRType__c;
                 
                 servicename = [Select Service_Name__c from ServiceRequestType__c where Id=:SrID];
                 system.debug('caserecord.OUC_Activities__r --->'+caserecord.OUC_Activity_Histories__r);                 
                
               
              }catch(Exception e){
                  render=false;
                  rend=true;
                  home_rend =true; 
                  
                  ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'The service request cannot be found. Please check your entry for misspelled words.');
                  ApexPages.addMessage(error_msg);
                  system.debug('caserecord ---->');
                  
                  return null;
              
              }            
           
            system.debug('caserecordmthd ------->'+caserecord);         
           
            system.debug('caserecord in mthd ------->'+caserecord);
         }
          
         return null;
     }
     
     public static Service_Request_History__c getRequest(String requestId){
           
           List<Service_Request_History__c> cases =[Select Address__c,CaseNumber__c,CreatedDate__c,Id, 
           SRType__c,Status__c,Subject__c, (Select Completion_Date__c, Due_Date__c, External_Comments__c, 
           Id, Status__c, Task_Short_Name__c From OUC_Activity_Histories__r) 
           from Service_Request_History__c 
           WHERE CaseNumber__c=:requestId OR Id=:requestId];             
          
           system.debug('Service_Request_History__c --->'+cases ); 
                              
           if(cases.size()==0){
                //invalid requestId code provided data could not be found
                 throw new CustomException(APIConstants.NOT_FOUND); 
           }
           return cases[0];
           
    }
     
}