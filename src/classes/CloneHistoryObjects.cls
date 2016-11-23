public class CloneHistoryObjects{
    // ER removed with sharing 2014-09-28
    //holds contact information

    /*
    * To insert Case Object details into Service Request History Object
    *
    *
    */
    @future (callout=true) 
     public static void cloneServiceRequestHistory(List<Id> caseIdList){
        Map<ID,Case> idCaseMap =new map<ID,Case> ([Select ANC__c,Address__c,AddressID__c,AliasName__c,CaseNumber,ClosedDate,CreatedDate,LastModifiedDate, Description,Device__c,Service_Request_Number__c,
               GeoLocation__Latitude__s,GeoLocation__Longitude__s,IntersectionId__c,IsClosed,Language__c,Jurisdiction__c,Expected_Resolution_Date__c,RoadwaySegId__c,SnowRoute__c, SnowZone__c,Case_Source__c,Origin,CreatedBy__c,
               Last_Update_Date__c,Media_URL__c,Priority,Reason,SRType_Jurisdiction__c,Servicing_Agency__c,External_Id__c,External_System_Name__c,LastModifiedBy__c,Zipcode__c,Contact.MailingState,Contact.MailingCountry,
               POlDistrict__c,Cluster__c,Status,Subject,Type,PSA__c,Quadrant__c,SMD__c,Ward__c,XCOORD__c,YCOORD__c,SRType__r.Service_Name__c,SRType__c,SLA__c,AccountId ,Contact.MailingStreet,Contact.MailingCity,
               Account.Name,SRType__r.Name,SRType__r.SLAType__c,Contact.Email,Contact.MobilePhone,Contact.Name,Contact.Fax,Contact.Phone,Contact.FirstName,Contact.LastName,ContactId,CaseOwner__c,JurisdictionDepartment__c,
               (Select Id, Name, Due_Date__c, Status__c,  CreatedDate, LastModifiedDate, Case__c,Activity_Date__c, Completion_Date__c, Citizen_Email_On_Complete__c, Final_Task_Code__c, External_Comments__c, Outcome__c, 
               CreatedBy__c,LastModifiedBy__c,Responsible_Party__c,Description__c,Display_Sort_Order__c,Activity_Type__c, Allowable_Outcomes__c,Final_Task_Short_Name__c,Public__c,Final_Outcome__c,ActivityOwner__c From OUC_Activities__r),
               (Select Name, FlexNote_Question__c, Case__c,CreatedDate, LastModifiedDate, Answer_Date_Time__c, Order__c, Answer__c, Questions__c, IsSecure__c, CodeDescription__c,FlexNoteQuestionCode__c, Created_By__c, Last_Modified_By__c From FlexNotes__r)
               From Case where id IN: caseIdList]);
        cloneServiceRequestHistory(idCaseMap);          
     } 
    
     // Duplicate of above - @Future version used in standard triggers
     // This non future version used in batch classes to update history since batches can't trigger @future
     public static void startCloneServiceRequestHistory(List<Id> caseIdList){
        Map<ID,Case> idCaseMap =new map<ID,Case> ([Select ANC__c,Address__c,AddressID__c,AliasName__c,CaseNumber,ClosedDate,CreatedDate,LastModifiedDate, Description,Device__c,Service_Request_Number__c,
               GeoLocation__Latitude__s,GeoLocation__Longitude__s,IntersectionId__c,IsClosed,Language__c,Jurisdiction__c,Expected_Resolution_Date__c,RoadwaySegId__c,SnowRoute__c, SnowZone__c,Case_Source__c,Origin,CreatedBy__c,
               Last_Update_Date__c,Media_URL__c,Priority,Reason,SRType_Jurisdiction__c,Servicing_Agency__c,External_Id__c,External_System_Name__c,LastModifiedBy__c,Zipcode__c,Contact.MailingState,Contact.MailingCountry,
               POlDistrict__c,Cluster__c,Status,Subject,Type,PSA__c,Quadrant__c,SMD__c,Ward__c,XCOORD__c,YCOORD__c,SRType__r.Service_Name__c,SRType__c,SLA__c,AccountId ,Contact.MailingStreet,Contact.MailingCity,
               Account.Name,SRType__r.Name,SRType__r.SLAType__c,Contact.Email,Contact.MobilePhone,Contact.Name,Contact.Fax,Contact.Phone,Contact.FirstName,Contact.LastName,ContactId,CaseOwner__c,JurisdictionDepartment__c,
               (Select Id, Name, Due_Date__c, Status__c,  CreatedDate, LastModifiedDate, Case__c,Activity_Date__c, Completion_Date__c, Citizen_Email_On_Complete__c, Final_Task_Code__c, External_Comments__c, Outcome__c, 
               CreatedBy__c,LastModifiedBy__c,Responsible_Party__c,Description__c,Display_Sort_Order__c,Activity_Type__c, Allowable_Outcomes__c,Final_Task_Short_Name__c,Public__c,Final_Outcome__c,ActivityOwner__c From OUC_Activities__r),
               (Select Name, FlexNote_Question__c, Case__c,CreatedDate, LastModifiedDate, Answer_Date_Time__c, Order__c, Answer__c, Questions__c, IsSecure__c, CodeDescription__c,FlexNoteQuestionCode__c, Created_By__c, Last_Modified_By__c From FlexNotes__r)
               From Case where id IN: caseIdList]);
        cloneServiceRequestHistory(idCaseMap);          
     } 
    
     
     private static void cloneServiceRequestHistory(Map<ID,Case> caseMap){
         savePoint sP=database.setSavePoint();
         try{
            list<Service_Request_History__c>sRHistoryList=new list<Service_Request_History__c>();
            map<String,list<FlexNote__c>>sRHistoryFlexNoteListMap=new map<String,list<FlexNote__c>>();
            map<String,list<OUC_Activity__c>>sRHistoryActivityHistoryListMap=new map<String,list<OUC_Activity__c>>();
            for(Id cId:caseMap.KeySet()){
                
                if(caseMap.get(cId)!=null){
                    // getting mapped servicerequest history 
                    Service_Request_History__c sRH=doServiceRequestHistoryMapping(caseMap.get(cId));
                    sRHistoryList.add(sRH);
                    // creating map servicerequest history and flexnotes list
                    //sRHistoryFlexNoteListMap.put(sRH,caseMap.get(cId).FlexNotes__r);
                    // creating map servicerequest history and ouc activity list
                    //sRHistoryActivityHistoryListMap.put(sRH.Id,caseMap.get(cId).OUC_Activities__r);
                }
            }
            // service request history list if empty dont upsert or nothing will do 
            if (!sRHistoryList.isEmpty()){
                upsert sRHistoryList Service_Request_Id__c;
                
                for(Service_Request_History__c srh : sRHistoryList) {
                    if (caseMap.get(srh.Service_Request_Id__c) != null) {
                 		// Create the map for Servicerequest history by Id and flexnotes list
                    	sRHistoryFlexNoteListMap.put(srh.Id,caseMap.get(srh.Service_Request_Id__c).FlexNotes__r);
                    	// Create the map Servicerequest history by Id and ouc activity list
                    	sRHistoryActivityHistoryListMap.put(srh.Id, caseMap.get(srh.Service_Request_Id__c).OUC_Activities__r);
                    }
                }
                 
                system.debug('servicerequestHistory-->'+sRHistoryList);
                system.debug('servicerequestflexnotehistory---'+sRHistoryFlexNoteListMap);
                system.debug('servicerequesthistoryactivity-->'+sRHistoryActivityHistoryListMap);
                /*get the flex note details*/         
                cloneFlexNoteHistory(sRHistoryFlexNoteListMap,sRHistoryList);
                /*end of flex note details*/
                 
                /*get the ouc activity details*/          
                cloneOucActivitiesHistory(sRHistoryActivityHistoryListMap,sRHistoryList);      
                /*end of flex note details*/ 
            } 
         }
         catch(Exception e){
            system.debug('Exception --->'+ e);
            database.rollback(sP);
         } 
     
     }
    
    
    // mapping of service request history  
    private static Service_Request_History__c doServiceRequestHistoryMapping(case cse){
        //instantiate service request history object.
        Service_Request_History__c srhistory= new Service_Request_History__c();
        try{
            //maping Case object to Service Request history object 
              //srhistory.Name=  cse.CaseNumber;
              srhistory.Name=  cse.Service_Request_Number__c;
              //srhistory.Name=  cse.Service_Request_Id__c;
              srhistory.Service_Request_Id__c = cse.Id ;
              srhistory.Description__c = cse.Description;
              srhistory.GeoLocation__Latitude__s = cse.GeoLocation__Latitude__s;
              srhistory.GeoLocation__Longitude__s = cse.GeoLocation__Longitude__s;
              srhistory.Language__c = cse.Language__c;
              srhistory.CaseNumber__c = cse.CaseNumber;
              srhistory.Media_URL__c   = cse.Media_URL__c;
              srhistory.Priority__c = cse.Priority;
              srhistory.Reason__c = cse.Reason;
              srhistory.Status__c = cse.Status;
              srhistory.Subject__c   = cse.Subject;
              srhistory.Type__c= cse.Type;
              srhistory.Owner__c = cse.CaseOwner__c;  
              srhistory.Device__c   = cse.Device__c;
              srhistory.DateTimeClosed__c = cse.ClosedDate;         
              srhistory.DateTimeOpened__c = cse.CreatedDate;        
              srhistory.LastUpdateDateTime__c = cse.Last_Update_Date__c; 
              srhistory.External_System_Name__c=cse.External_System_Name__c;
              srhistory.External_Id__c=cse.External_Id__c;
              srhistory.Expected_Resolution_Date__c=cse.Expected_Resolution_Date__c;
              srhistory.SLA__c=cse.SLA__c;
              srhistory.Origin__c = cse.Origin;
              srhistory.Case_Source__c = cse.Case_Source__c;
              srhistory.IsClosedOnCreate__c   = cse.IsClosed;   // seperate field isClosed needed 
              srhistory.IsClosed__c= cse.IsClosed;
              srhistory.CreatedBy__c = cse.CreatedBy__c;
              srhistory.LastModifiedBy__c = cse.LastModifiedBy__c;
              srhistory.Zipcode__c=cse.Zipcode__c;
              srhistory.SnowRoute__c = cse.SnowRoute__c;
              srhistory.SnowZone__c = cse.SnowZone__c;
              
              // JURISDICATION
              srhistory.Jurisdiction_Code__c = cse.Jurisdiction__c;
              srhistory.SRType_Jurisdiction__c = cse.SRType_Jurisdiction__c;
              srhistory.Jurisdiction_Description__c=cse.JurisdictionDepartment__c;
              
              // SERVICE REQUEST TYPE
              srhistory.SRType__c = cse.SRType__r.Service_Name__c;
              srhistory.Servicing_Agency__c = cse.Servicing_Agency__c;
              srhistory.Service_Type_Code__c=cse.SRType__r.Name;
              srhistory.SLA_Type__c=cse.SRType__r.SLAType__c;
              
              /*Add MAR fields*/
              srhistory.PSA__c= cse.PSA__c;
              srhistory.Quadrant__c = cse.Quadrant__c;
              srhistory.SMD__c= cse.SMD__c;
              srhistory.Ward__c= cse.Ward__c;
              srhistory.XCOORD__c = cse.XCOORD__c;
              srhistory.YCOORD__c= cse.YCOORD__c;
              srhistory.AddressID__c = cse.AddressID__c;
              srhistory.ANC__c = cse.ANC__c;
              srhistory.Address__c   = cse.Address__c;
              srhistory.AliasName__c = cse.AliasName__c;
              srhistory.IntersectionId__c = cse.IntersectionId__c;
              srhistory.Neighbor_Hood_Cluster__c=cse.Cluster__c;
              srhistory.District__c=cse.POlDistrict__c;
              srhistory.RoadwaySegId__c = cse.RoadwaySegId__c;
              
              // CONTACT FIELDS MAPPING
              srhistory.Contact__c = cse.Contact.Name;
              srhistory.Contact_Email__c = cse.Contact.Email;
              srhistory.ContactFax__c = cse.Contact.Fax ;
              srhistory.ContactMobile__c = cse.Contact.MobilePhone;
              srhistory.ContactPhone__c = cse.Contact.Phone;
              srhistory.ContactFirstName__c=cse.Contact.FirstName;
              srhistory.ContactLastName__c=cse.Contact.LastName;
              srhistory.Contact_Address__c=cse.Contact.MailingStreet+','+cse.Contact.MailingCity+','+cse.Contact.MailingState+','+cse.Contact.MailingCountry;
              
              // account details
              srhistory.Account__c= cse.Account.Name;
              srhistory.AccountId__c=cse.AccountId;
              
              // these below fields needed
              //srhistory.CreatedById = cse.CreatedById;
              // data type changes required for below field
              //srhistory.ClosedDate__c = string.valueOf(cse.ClosedDate);         // from string to date datatype
              //srhistory.CreatedDate__c = string.valueOf(cse.CreatedDate);     // from string to date datatype
              //srhistory.Last_Update_Date__c = string.valueOf(cse.Last_Update_Date__c); // from string to date datatype
              
        }
        catch(exception e){
            system.debug('unable to complete mapping process due=='+e);
        }
        return srhistory;
    }
    
         
    /**
    * To insert Flex note Object details into Flex Note History Object
    *
    *
    */ 
    
    private static void cloneFlexNoteHistory(map<String,list<FlexNote__c>>sRHFlexNoteListMap,list<Service_Request_History__c>sRH){
        try{
            // holds flexnotes list which needs to upserted
            list<Flex_Note_History__c>toUpsertFlexNoteHistory=new list<Flex_Note_History__c>();
            For(Service_Request_History__c sRHId:sRH){
                //system.debug('sRHFlexNoteListMap--'+sRHFlexNoteListMap.get(sRHId));
                if(sRHFlexNoteListMap.get(sRHId.Id) != null) {
                    for(FlexNote__c fn :sRHFlexNoteListMap.get(sRHId.Id)) {
                        Flex_Note_History__c fnhistory = new Flex_Note_History__c();
                            fnhistory.Name=  fn.Name;
                            fnhistory.Flex_Note_Id__c     = fn.Id;                       
                            fnhistory.Answer_Date_Time__c = fn.Answer_Date_Time__c;
                            fnhistory.Case__c             = fn.Case__c;      
                            fnhistory.CodeDescription__c  = fn.CodeDescription__c;                        
                            fnhistory.Order__c            = fn.Order__c; 
                            fnhistory.Questions__c        = fn.Questions__c;
                            fnhistory.Service_Request_History__c = sRHId.Id;
                            fnhistory.Answer__c = fn.Answer__c;
                            fnhistory.FlexNote_Question__c= fn.FlexNoteQuestionCode__c;
                            fnhistory.Created_By__c         = fn.Created_By__c;
                            fnhistory.Created_Date__c       = fn.CreatedDate;
                            fnhistory.Last_Modified_By__c   = fn.Last_Modified_By__c;
                            fnhistory.Modified_Date__c      = fn.LastModifiedDate;
                        	fnhistory.IsSecure__c = fn.IsSecure__c;
                        toUpsertFlexNoteHistory.add(fnhistory);
                    }
                }
            }
            
            if(!toUpsertFlexNoteHistory.isEmpty()){
                upsert toUpsertFlexNoteHistory Flex_Note_Id__c;
            }
        }
        catch(exception e){
            system.debug('unable to complete flexnote history process due--'+e);
        }
    }
        
     /**
    * To insert OUC Activities Object details into OUC Activities History Object
    *
    *
    */    
     private static void cloneOucActivitiesHistory(map<String,list<OUC_Activity__c>>sRHistoryActivityHistoryListMap,list<Service_Request_History__c>sRH){
         try{
             System.debug('----> sRHistoryActivityHistoryListMap: ' + sRHistoryActivityHistoryListMap);
             System.debug('----> sRHistoryActivityHistoryListMap Size: ' + sRHistoryActivityHistoryListMap.size());
             System.debug('----> sRH: ' + sRH);
             System.debug('----> sRH Size: ' + sRH.size());
             
            // holds list of OUC Activity list which needs to upserted
            List<OUC_Activity_History__c> oucActhistoryList = new List<OUC_Activity_History__c> ();
             
            For(Service_Request_History__c sRHId:sRH){
                if(sRHistoryActivityHistoryListMap.get(sRHId.Id)!=null){
                    for(OUC_Activity__c oa :sRHistoryActivityHistoryListMap.get(sRHId.Id)){
                        OUC_Activity_History__c oucActhistory= new OUC_Activity_History__c();
                         //oucActhistory.Name =oa.Final_Task_Code__c;
                         oucActhistory.Name =oa.Name;
                         oucActhistory.Activity_Id__c =string.valueOf(oa.Id);
                         oucActhistory.Service_Request_History__c = sRHId.Id;
                         oucActhistory.Case__c = oa.Case__c;
                         oucActhistory.Citizen_Email_On_Complete__c = string.valueOf(oa.Citizen_Email_On_Complete__c);
                         oucActhistory.Completion_Date__c = oa.Completion_Date__c;
                         oucActhistory.Display_Sort_Order__c = oa.Display_Sort_Order__c;
                         oucActhistory.Due_Date__c = oa.Due_Date__c;
                         oucActhistory.Public__c = oa.Public__c;
                         oucActhistory.Responsible_Party__c = oa.Responsible_Party__c;
                         oucActhistory.Status__c = oa.Status__c;
                         oucActhistory.OutCome__c = oa.Final_Outcome__c ;  
                         oucActhistory.Task_Code__c = oa.Final_Task_Code__c;     
                         oucActhistory.Task_Short_Name__c = oa.Final_Task_Short_Name__c;  
                         oucActhistory.ActivityOwnerName__c = oa.ActivityOwner__c ;  
                         oucActhistory.Last_Modified_By__c = oa.LastModifiedBy__c;
                         oucActhistory.Created_By__c = oa.CreatedBy__c ;
                         oucActhistory.Created_Date__c = oa.CreatedDate;
                         oucActhistory.Modified_Date__c = oa.LastModifiedDate;    
                         
                         
                         // comments fields
                         oucActhistory.External_Comments__c = oa.External_Comments__c;
                         oucActhistory.Description__c = oa.Description__c ;   // oucactivity description
                         
                         // below not used
                         // oucActhistory.Text__c = oa.Text__c;
                         // oucActhistory.User__c= oa.User__c;
                         // oucActhistory.Email__c = oa.Email__c;
                         //oucActhistory.Subject__c = oa.Subject__c;
                         //oucActhistory.Priority__c = oa.Priority__c;
                         //oucActhistory.Name = oa.Name ;   
                         //oucActhistory.Phone__c = oa.Phone__c;
                        
                         oucActhistoryList.add(oucActhistory); 
                    }
                } else {
                    System.debug('----> sRHId: ' + sRHId);
                    System.debug('----> sRHistoryActivityHistoryListMap.get(sRHId): ' + sRHistoryActivityHistoryListMap.get(sRHId.Id));
                }
            }
            System.debug('----> oucActhistoryList: ' + oucActhistoryList);
			System.debug('----> oucActhistoryList Count: ' + oucActhistoryList.size());
            if(!oucActhistoryList.isEmpty()){
                upsert oucActhistoryList Activity_Id__c;
            }
             
         }catch(Exception e){
            system.debug('Exception occcured in ouc activity proceess due to-->'+e);
         }
     }
 
}