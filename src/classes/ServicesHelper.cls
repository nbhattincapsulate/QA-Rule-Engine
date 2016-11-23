/*
  
  Helper class: contains all the required method for service apis

*/
public class ServicesHelper{
        
       /**
       * Queries for the specified Service by serviceCode and returns the corresponding
       * response object.
       *
       * @param id  Service's serviceCode
       * @return    A response version of the matching Service.
       *            If no records are found, it will simply return a custom error message that the service code
                    is invalid
       */
        public static ServiceRequestType__c getService(String serviceCode){
            List<ServiceRequestType__c> srtypes= [
                Select 
                  Id, 
                  Name, 
                  Service_Name__c, 
                  External_Name__c, 
                  Flex_Note_Count__c, 
                  External_Description__c, 
                  Flex_Notes_Link_Indicator__c, 
                  Group__c, 
                  Keywords__c, 
                  Description__c, 
                  LongExternalDescription__c,
                  Agency__c, 
                  SLA__c,
                  SLAType__c,
                  ServiceLocationRequired__c
                From 
                  ServiceRequestType__c 
                Where 
                  Name=:serviceCode 
                LIMIT 1
            ];
            
            if(srtypes.isEmpty()){
                //invalid service code provided data could not be found
                throw new CustomException(APIConstants.NOT_FOUND);          
            }
            return srtypes[0]; 
        } 
        
    /**
       * Queries for the specified Service Flexnotes by serviceCode and returns the corresponding
       * response object.
       *
       * @param id  Service's serviceCode
       * @return    A response version of the matching Service Flexnotes.
       *            If no records are found, it will simply return null
       */
        public static List<ServiceRequestTypeFlexNote__c> getServiceMetadata(String serviceCode){
                
                return [Select FlexNote_Question__r.Answer_Type__c,FlexNote_Question__r.AnswerValues__c,FlexNote_Question__c,Order__c,
                        FlexNote_Question__r.Name,FlexNote_Question__r.Questions__c ,FlexNote_Question__r.Required__c, isRequired__c, IsRequiredQuestion__c                     
                        FROM ServiceRequestTypeFlexNote__c WHERE Service_Request_Type__r.Name=:serviceCode 
                ];
                
        }
        
        /**
       * Queries for the specified Service Flexnotes by serviceCode and returns the corresponding
       * response object.
       *
       * @param id  Service's serviceCode
       * @return    A response version of the matching Service Flexnotes along with decode object that contains answers if any
       *            If no records are found, it will simply return null
       */
        public static List<ServiceRequestTypeFlexNote> getServiceMetadata2(String serviceCode){
                
                List<ServiceRequestTypeFlexNote> response = new List<ServiceRequestTypeFlexNote>();
                
                List<ServiceRequestTypeFlexNote__c> notes = [Select FlexNote_Question__r.Answer_Type__c,FlexNote_Question__r.AnswerValues__c,FlexNote_Question__c,Order__c,
                        FlexNote_Question__r.Name,FlexNote_Question__r.Questions__c ,FlexNote_Question__r.Required__c, isRequired__c, IsRequiredQuestion__c                      
                        FROM ServiceRequestTypeFlexNote__c WHERE Service_Request_Type__r.Name=:serviceCode 
                ];
                Map<String,List<Decode_Object__c>> answerDcodeMap= new Map<String,List<Decode_Object__c>>();
                if(notes.size()>0){
                	Set<STring> nameValues = new Set<STring>();
                	for(ServiceRequestTypeFlexNote__c n:notes){
                		nameValues.add(n.FlexNote_Question__r.AnswerValues__c);
                	}

                	for(Decode_Object__c dc:[Select Name,Code__c,Value__c from Decode_Object__c WHERE Name IN:nameValues]){
                		List<Decode_Object__c> objs= answerDcodeMap.get(dc.name)!=null ?answerDcodeMap.get(dc.name):new List<Decode_Object__c>();
                		objs.add(dc);
                		answerDcodeMap.put(dc.name,objs);
                	}
                	
                }
                
                for(ServiceRequestTypeFlexNote__c n:notes){
                	response.add( new ServiceRequestTypeFlexNote(n,answerDcodeMap.get(n.FlexNote_Question__r.AnswerValues__c)));
                }
                return response;
                
        }
        
        /**
       * Queries for list of Services records and and returns the corresponding
       * response object (list of Service).  If any non-null parameters are 
       * provided, the list will be filtered by the specified field.
       *
       * @param jurisdiction_id    Id of jurisdiction
       * @return              Collection of Service objects, as an list
       */
        public static List<ServiceRequestType__c> listAllServices(String jurisdiction_id ){
            
            String query = 'Select Id, Name, Service_Name__c, External_Name__c, External_Description__c, Flex_Notes_Link_Indicator__c, Flex_Note_Count__c,group__c,keywords__c,description__c,Allow_Citizen_Web_Intake__c, LongExternalDescription__c, Agency__c, SLA__c, SLAType__c, ServiceLocationRequired__c FROM ServiceRequestType__c';
            
            /*if(jurisdiction_id!=null){
                query +=' WHERE Id IN (Select ServiceRequestType__c FROM ServiceRequestType_Jurisdiction__c WHERE Jurisdiction__r.Name=\''+jurisdiction_id+'\')';
            }*/
            query += ' Order By External_Name__c ASC';
            
            return database.query(query);
        }
        
        public class ServiceRequestTypeFlexNote{
        	public ServiceRequestTypeFlexNote__c flexnote {get;set;}
        	public List<Decode_Object__c> keyValueAns {get;set;}
        	
        	public ServiceRequestTypeFlexNote(ServiceRequestTypeFlexNote__c fn,List<Decode_Object__c> ans){
        		flexnote = fn;
        		keyValueAns = ans;
        	}
        }
        
        
}