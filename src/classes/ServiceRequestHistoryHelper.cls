public with sharing class ServiceRequestHistoryHelper {
     /**
       * Queries for the specified request by service request id(case id) and returns the corresponding
       * response object.
       *
       * @param id  request's id
       * @return    A response version of the matching request.
       *            If no records are found, it will simply error message saying invalid/not found
       */
       public static Service_Request_History__c getRequest(String requestId){
            
            string query=buildGetQueryRoot();
            query+='WHERE Name=\'' +requestId +'\' ';

            List<Service_Request_History__c> cases = database.query(query);
                               
            if(cases.size()==0){
                 //invalid requestId code provided data could not be found
                  throw new CustomException(APIConstants.NOT_FOUND); 
            }
            return cases[0];
            
       }
       
       
        private static String buildGetQueryRoot(){
            string query = 'Select name, casenumber__c, IsClosed__c, status__c,description__c,Subject__c,Servicing_Agency__c,';
            query+='CreatedDate__c,LastModifiedDate,DateTimeOpened__c,LastUpdateDateTime__c,';
            query+='DateTimeClosed__c, Address__c,AddressID__c,geolocation__latitude__s,';
            query+='geolocation__longitude__s,media_url__c,Expected_Resolution_Date__c,ContactFirstName__c,Contactlastname__c,';
            query+='ContactPhone__c,Contact_Email__c,Priority__c,Origin__c,Device__c,SLA__c,External_Id__c,External_System_Name__c,Language__c,';
            query+='IntersectionId__c,Quadrant__c,Ward__c,District__c,PSA__c,ANC__c,SMD__c,Neighbor_Hood_Cluster__c,XCOORD__c,YCOORD__c,Zipcode__c,';
            query+='Jurisdiction_Code__c,IsClosedOnCreate__c,Reason__c,Service_Type_Code__c,';
            query+='Jurisdiction_Description__c,SRType__c,Deleted__c,';
            query+='(Select  name,questions__c,Order__c, Answer__c, ';
            query+=' CodeDescription__c, FlexNote_Question__c, IsSecure__c FROM Flex_Note_Histories__r ORDER BY Order__c, ID  ),';
            query+='(Select Id,Status__c,Task_Code__c,Task_Short_Name__c,Citizen_Email_On_Complete__c,';
            query+='Description__c,external_comments__c,outcome__c,Display_Sort_order__c,completion_date__c,';
            query+='Due_Date__c,Responsible_Party__c FROM OUC_Activity_Histories__r ORDER BY Display_Sort_Order__c )';
            query+='FROM Service_Request_History__c ';
            
            return query;
            
        }
       
        
     
       /**
       * Queries for list of Requests records and and returns the corresponding
       * response object (list of Requests).  If any non-null parameters are
       * provided, the list will be filtered by the specified field.
       *
       * @param jurisdiction_id    Id of jurisdiction
       * @return              Collection of Requests objects, as an list
       */
        public static List<Service_Request_History__c> listAllRequests(String filter,Boolean isPrivate){
           
            string query=buildGetQueryRoot();
            
            //adding filter
            if(filter==null){
                query +=' WHERE DateTimeOpened__c >= LAST_90_DAYS ';
            }
            else {
                query +=' WHERE '+filter;
            }
            // do not return deleted SR's to the public  (only private API key holders)
            if(!isPrivate){
                query+=' AND Deleted__c=false';
            }
            
            
            String limitBy = isPrivate ?' 400':' 1000';
            String orderBy = isPrivate ?' LastUpdateDateTime__c ASC, Name ASC, CaseNumber__c ASC': 'DateTimeOpened__c DESC';
            
            query +=' ORDER BY '+orderBy+' LIMIT '+limitBy;

            system.debug('FILTER:' + filter);
            System.debug(query);
            return database.query(query);
            
        } 
        
        public static void updateCaseAsDeleted(List<String> caseNumbers){
            List<Service_Request_History__c> cases = [Select Id,Deleted__c from Service_Request_History__c WHERE Name IN:caseNumbers];
            List<Id> SRHIds = new List<Id>();
            for(Service_Request_History__c c:cases){
                c.deleted__c=true;
                SRHIds.add(c.Id);
            }
            update cases;
            // Now get the linked FlexNote Historys that are not already marked as deleted
            //    flex notes are master detail, so before delete doesn't fire if Case (master) is deleted
            List<Flex_Note_History__c> FNHs = [SELECT Id,Deleted__c From Flex_Note_History__c WHERE Service_Request_History__c IN:SRHIds AND Deleted__c=false];
            for(Flex_Note_History__c fh:FNHs){
                fh.deleted__c=true;
            }
            update FNHs;
        }
        public static void updateFlexNoteHistoryAsDeleted(List<String> FlexNoteIds){
            List<Flex_Note_History__c> FNHs = [Select Id,Deleted__c from Flex_Note_History__c WHERE Flex_Note_Id__c IN:FlexNoteIds];
            for(Flex_Note_History__c c:FNHs){
                c.deleted__c=true;
            }
            update FNHs;
        }
        public static void updateOUCActivityHistoryAsDeleted(List<String> ActivityIds){
            List<OUC_Activity_History__c> AHs = [Select Id,Deleted__c from OUC_Activity_History__c WHERE Activity_Id__c IN:ActivityIds];
            for(OUC_Activity_History__c c:AHs){
                c.deleted__c=true;
            }
            update AHs;
        }
}