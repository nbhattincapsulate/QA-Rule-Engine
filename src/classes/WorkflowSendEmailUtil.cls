public with sharing class WorkflowSendEmailUtil {
     public void sendEmail(Map<Id,User> user,Map<String,Map<String,List<WorkflowRuleAction__c>>> userEmailInfo){
        
         List<String> templateIds= new List<String>();
         for(String userId : userEmailInfo.keySet()){
                
                Map<String,List<WorkflowRuleAction__c>> emailInfo = userEmailInfo.get(userId);
                for(String recordId : emailInfo.keySet()){                    
                    for(WorkflowRuleAction__c action  : emailInfo.get(recordId)){  
                       templateIds.add(action.email_template__c);                                        
                    }
                }                
        }
         
        Map<Id,EmailTemplate> templateData=new Map<Id,EmailTemplate>([Select Id,Body,Subject,TemplateType,HtmlValue FROM EmailTemplate WHERE Id IN:templateIds]);
        
        If(templateData == null || templateData.size() == 0) return;  
        
        Map<String,Set<Id>> objIds = new Map<String,Set<Id>>();
        
        for(String userId : userEmailInfo.keySet()){
                //string emailId = users.get(userId).Email;
                Map<String,List<WorkflowRuleAction__c>> emailInfo = userEmailInfo.get(userId);
                for(String recordId : emailInfo.keySet()){  
                     Id referenceId = Id.valueof(recordId);
                     String objectAPIName = referenceId.getSObjectType().getDescribe().getName().toLowerCase();
                     Set<Id> objinfo = objIds.get(objectAPIName)!=null ? objIds.get(objectAPIName): new Set<Id> ();
                     objinfo.add(referenceId);
                     objIds.put(objectAPIName,objinfo);
                }
        }
        
        Map<Id,SObject> records = new Map<Id,SObject>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 

        for(String objName : objIds.keySet()){
            Map<String, Schema.SObjectField> M = gd.get(objName).getDescribe().fields.getMap();
            List<String> fields=new List<String>();
            fields.addAll(M.keySet());
            Set<Id> ids = objIds.get(objName);  
            String query = 'Select '+String.join(fields,',')+' FROM '+objName+' WHERE Id IN:ids';
            List<SObject> rds= Database.query(query);
            
            for(SOBject o : rds)records.put(o.Id,o); 
            
        }
        
        //Get the email settings from custom setting
        List<WorkflowConfiguration__c> mcs = WorkflowConfiguration__c.getall().values();
        
        if(mcs.size()==0){
        	//then what to do the system is not configured :-(
        }
        
        //User currentUser = [SELECT Id,
         //                          Name,
         //                          FirstName,
         //                          LastName 
        //                    FROM   User 
        //                    WHERE  Id=:mcs[0].contextuser__c];
        User currentUser = null;
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(String userId : userEmailInfo.keySet()){
                
                if(user.get(userId)==null)continue;
                
                string emailId = user.get(userId).Email;
                Map<String,List<WorkflowRuleAction__c>> emailInfo = userEmailInfo.get(userId);
                for(String recordId : emailInfo.keySet()){ 
                    Id referenceId = Id.valueof(recordId);
                    
                    for(WorkflowRuleAction__c a  : emailInfo.get(recordId)){  
                          String templateId = a.email_template__c;
                          Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                          
                          singleEmail.setReplyTo(mcs[0].Email_Reply_To_Address__c);
                          singleEmail.setSenderDisplayName(mcs[0].Email_Display_Name__c);
                          
                          //since this contains text & not html
                          String emailBody= replaceMergeFields(templateData.get(templateId).Body,records.get(recordId),user.get(userId),currentUser );
                          String htmlBody = emailBody;
                          
                          if(templateData.get(templateId).HtmlValue!=null)
                             htmlBody =  replaceMergeFields(templateData.get(templateId).HtmlValue,records.get(recordId),user.get(userId),currentUser );
                          
                          singleEmail.setHTMLBody(htmlBody);
                          String subject = replaceMergeFields(templateData.get(templateId).Subject,records.get(recordId),user.get(userId),currentUser );
                          singleEmail.setSubject(subject);
                          List<String> emailAddress = new List<String>();
                          if(a.additional_emails__c!=null){
                            emailAddress.addAll(a.additional_emails__c.split(',')); 
                          }
                          
                         if(a.User_Owner_Id__c!=null)
                            emailAddress.add(emailId);
                            
                          
                          if(emailAddress.size()==0)continue;
                          
                          singleEmail.setToAddresses( emailAddress);
                          singleEmail.setPlainTextBody(emailBody);
                          singleEmail.setSaveAsActivity(false);
                          emailList.add(singleEmail);
                    }
                }                
        }
        if(emailList.size()>0){
        	 try{Messaging.SendEmailResult [] r = Messaging.sendEmail(emailList);}catch(Exception e){}
        }
    }
   
    
    private String replaceMergeFields(String text,SObject c,User u ,User currentUser){
        String thePattern = '\\{!((\\w+)\\.(\\w+))\\}';
        Pattern myPattern = Pattern.compile(thePattern);
        Matcher myMatcher = myPattern.matcher(text);
        
        while(myMatcher.find()){
           try{
               if(myMatcher.group(2)=='Receiving_User' || myMatcher.group(2)=='Owner')
                   text=text.replace('{!'+myMatcher.group(1)+'}',string.valueof(u.get(myMatcher.group(3))));
               else if(myMatcher.group(2)=='User')
                   text=text.replace('{!'+myMatcher.group(1)+'}','');//string.valueof(currentUser.get(myMatcher.group(3)))
               else 
                   text=text.replace('{!'+myMatcher.group(1)+'}',string.valueof(c.get(myMatcher.group(3))));
           }catch(Exception e){
                   text=text.replace('{!'+myMatcher.group(1)+'}','');
           }                           
        }
        return text;
    }
}