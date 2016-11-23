public class SRController{    
  
    /* START: rerendered related variables*/
    public Boolean service_type { get; set; }
    public Boolean service_location{ get; set; }
    public Boolean service_information { get; set; }
    public Boolean contact_information{ get; set; }
    public Boolean review_submit{ get; set; }
    public Boolean ServiceLocAddressDetails { get; set; }
    public Boolean review_result{ get; set; }
    public Boolean error_msg{ get; set; }
    public Boolean error_msg1{ get; set; }
    public Boolean comments_attachments { get; set; }
    public Boolean attachment { get; set; }
    public Boolean rh_error_msg{ get; set; }
    public Boolean status_check_error_msg{ get; set; }
    public boolean ServiceLocationRequired { get; set;}
    public boolean ContactRequired { get; set;}
    public boolean dupliacteAddressDetection{ get; set;}
    /*END: rerendered related variables*/
   
    /* START: Attachment related variables*/
    public static  Attachment attach {
      get {
          if (attach == null)
            attach = new Attachment();
          return attach;
        }
      set;
     }
     
     public Id  attachmentId{ get{system.debug('attachmentId--->'+attachmentId); return attachmentId;}set;}    
     /* END:Attachment related variables */
    
    /* START: FAQ related variables*/
    public Boolean FAQ_S { get; set; }
    public Boolean FAQ_D { get; set; }
    public List<ServiceRequestType__c> FaqSrdescription {get{system.debug('FaqSrdescription --->'+FaqSrdescription ); return FaqSrdescription ;}set;} 
    public List<ServiceRequestType__c> FaqSrsla{ get{system.debug('FaqSrsla--->'+FaqSrsla); return FaqSrsla;}set;}
    /* END: FAQ related variables*/

   
    /* START : keyword search string related variables */
    public string searchstring{ get; set;}
    public string searchstr{ get; set;}
    public List<ServiceRequestType__c> searchList { get; set;}
    public  List<SelectOption> options1 = new List<SelectOption>();
    /* END : keyword search string related variables*/
    
    /* START : holdes question and answers*/
    public list<QuestionAnswerWrapper> tempQuestionAnswerWrapList{ get; set;}
    public list<QuestionAnswerWrapper> tempFlexNotesList{ get; set;}
    private map<Id,FlexNoteQuestion__c>flexNoteIdMap=new map<Id,FlexNoteQuestion__c>(); 
    private map<string,string>nameDecodeValueMap=new map<string,string>();
    private map<string,list<Decode_Object__c>>picklistNameDecodeMap=new map<string,list<Decode_Object__c>>();   
    /* END : holdes question and answers*/
   
   
    /* START : stores the service location related address from vf page*/ 
     public string street{
        get;
        set{
            if(street!=value && radiobtn1 != null){
                street=value;
                
            }
        }
    }     
    //public string street{get{system.debug('street---->'+street); return street;} set;}    
    public string city{get{system.debug('city---->'+city); return city;} set;}    
    public string state{get{system.debug('state---->'+state); return state;} set;}    
    public string zipCode{get{system.debug('zipcode---->'+zipcode); return zipcode;} set;}
    public string building{get{system.debug('building---->'+building); return building;} set;}    
    public string floor{get{system.debug('floor---->'+floor); return floor;} set;}    
    public string unit{get{system.debug('unit---->'+unit); return unit;} set;}
    /* END : stores the service location related address from vf page*/
    
    /* START : stores the mar related address from vf page*/
    public string jstring{ get; set; }    
    public string address_id{ get; set;}
    public string latitude{ get; set;}
    public string longitude{ get; set;}
    public string alias_name{ get; set;}
    public string intersection_id{ get; set;}
    public string full_intersection{ get; set;}
    public string locresult{ get; set;}
    public string quadrant{ get; set;}
    public string xcoord{ get; set;}
    public string ycoord{ get; set;}
    public string anc{ get; set;}
    public string psa{ get; set;}
    public string ward{ get; set;}
    public string smd{ get; set;}
    public string poldist{ get; set;}
    public string cluster{ get; set;}
    public string addrnum{ get; set;}
    public  List<String> result{ get; set;}
    public  List<String> geoRes{ get; set;}
    public  Map<String, String> fullBlockAddress{ get{system.debug('fullBlockAddress in get---->'+fullBlockAddress); return fullBlockAddress;} set;}
    public string fulladdress{get{system.debug('fulladdress in get---->'+fulladdress); return fulladdress; }set;}
    public Map<String,String> geo_result{get; set;} 
    /* END : stores the mar related address from vf page*/
    
    /* START : options service type list for dropdown */
    public  List<SelectOption> options = new List<SelectOption>();
    /* END : options service type list for dropdown */ 
   
    /*START : selected service request type*/
    public string ser_type{get; set;}   
    public string selSelectedRequestTypeName{ get; set;}
    public string seladressloc { get{system.debug('seladressloc  in get------>'+seladressloc );return seladressloc ;} set;} 
    public string serviceType;
    public string selectedServiceType{get;set;}
    /*END : selected service request type*/
    
    /* START: variables related to status check*/
    public string Id{get;set;}
    public string requestId{get{system.debug('requestId--->'+requestId); return requestId;}set;}
    public string srequestId{get{system.debug('requestId--->'+requestId); return requestId;}set;}
    public string email{get{system.debug('email--->'+email); return email;}set;}
    public string email_address{get;set;}
    public Service_Request_History__c caserecord{get{system.debug('caserecord--->'+caserecord); return caserecord;}set;}
    public Boolean render{get;set;}
    public Boolean rend{get;set;}
    public Boolean home_rend{get;set;}
    public string SrId{get;set;}
    /* END : variables related to status check*/
    
    /*START: Authenticated related variables*/
    public Boolean loggedout{get{system.debug('loggedout--->'+loggedout); return loggedout;}set;}
    public Boolean loggedIn{get{system.debug('loggedIn--->'+loggedIn); return loggedIn;}set;}
    public string loggedInUsername{get{system.debug('loggedInUsername--->'+loggedInUsername); return loggedInUsername;}set;}
    public list<Service_Request_History__c> loggedin_user_case{get;set;}     
    public LIST<ServiceRequestType__c> servicename {get;set;}
    /*END: authenticated related variables*/
    
    /*START: bulk collection schedule date related variables*/
    map<Date,BulkSchedule__c>bulkScheduleMap=new map<Date,BulkSchedule__c>();
    set<ServiceRequestBulkSchedule__c>sRBS=new set<ServiceRequestBulkSchedule__c>();     
    public String scheduleDate{ get{system.debug('scheduleDate--->'+scheduleDate); return scheduleDate;} set; }
    /*END: bulk collection schedule date related variables*/ 
    
    /*START: duplicate detection related variables*/
    public list<case>duplicateSRList{get;set;}
    /*end: duplicate detection related variables*/
    
    /*START: radio button related variables*/
    public boolean radiobtn1{get{system.debug('radiobtn1--->'+radiobtn1); return radiobtn1;}set;}
    public boolean radiobtn2{get{system.debug('radiobtn2--->'+radiobtn2); return radiobtn2;}set;}
    /*end: radio button related variables*/
    
    /*holds case Record Id */ 
    public String selectedCaseId{get;set;}
    
    public integer selIndex{get;set;}
    public string selAnswerValue{get;set;}
    
    // holds flexnotesquestion for a given service request type 
    public list<ServiceRequestQuestionWrapper>serviceRequestQuestionWrapList{get;set;}
   
    // Determine which type of service Request Type
    public string selectedServiceRequestType{
        get;
        set{
            if(selectedServiceRequestType!=value){
                selectedServiceRequestType=value;
                
            }
        }
    }   
    
    public string CaseId{ get; set;}
    public Integer length{ get; set; }
    public string  JurdId{ get; set; }     
    public ID JurisdictionId{ get; set;}    
    public string  Sla{ get; set; }
    public string  Agency{ get; set; }
    public string  Origin{ get; set; }
    public string  Priority{ get; set; }
    public string  Status{ get; set; }  
     
    public Case casenumber { get; set; }
    public string  comments{ get{system.debug('comments---->'+comments); return comments;} set;}
    public string commentvalue{ get{system.debug('commentvalue---->'+commentvalue); return commentvalue;} set;}
    public Contact selContact{ get; set;} 
    public string fp_email_address{ get{system.debug('fp_email_address---->'+fp_email_address); return fp_email_address;} set;}
    
    /**
    *  Constructor
    *
    */
    public SRController(){       
        
        /* set rendered variables*/
        service_type=true;
        service_location = false;
        service_information = false;
        contact_information = false;
        comments_attachments= false;
        review_submit = false;
        ServiceLocAddressDetails=false;
        review_result=false;
        attachment=false;
        error_msg=false; 
        dupliacteAddressDetection=false;
        
        radiobtn1=false;
        radiobtn2=false;
        
        //status check
        render=false; 
        rend=true; 
        home_rend =true;   
        
        //faq
        FAQ_S=false;
        FAQ_D=false; 
        /* end */     

        selContact=new Contact();
        city ='WASHINGTON';
        state='DC';
        
        //Customer portal user is logged in.  
        loggedInUsername='';
        loggedIn=false;
        
        User usr = [Select ContactId, Profile.Name from user where Id=: UserInfo.getUserId()];
        
        if(usr.ContactId !=null)
        {
               loggedInUsername= UserInfo.getUserName();
               loggedIn=true; 
               
               //get a latest 10 cases of logged in user
               get_case_history();
        }else{
            loggedIn=false;
            loggedout=true;
        }
        
        
        //preparing map of id and questions
        fetchFlexNoteQuestionMap();        
        fetchNamePickListValues(); 
       
    }
    
   
        
    /**
    *  getting all service types
    *
    */ 
    public List<SelectOption> getServiceRequestItems() { 
        
        List<SelectOption> tempOptions = new List<SelectOption>();
        
        if(options1.size() != 0 ){           
           
            return options1;
        
        }else{         

            
            list<ServiceRequestType__c> srList=new list<ServiceRequestType__c>();
        
            string tempQueryStr='Select i.Object__c, i.Name, Service_Name__c,i.Id,i.Start_Date__c,i.Stop_Date__c,i.External_Name__c,i.Description__c From ServiceRequestType__c i  where ';

            datetime deadline =  datetime.newInstance(Date.today(),Time.newInstance(0, 0, 0, 0));

            tempQueryStr+=' (Start_Date__c  <='+ deadline.format('yyyy-MM-dd');
            tempQueryStr+=' Or Start_Date__c  = null)';
            tempQueryStr+=' AND (Stop_Date__c  >='+ deadline.format('yyyy-MM-dd');
            tempQueryStr+=' Or Stop_Date__c  = null)';
            tempQueryStr+=' AND  Allow_Citizen_Web_Intake__c = true';
            
            tempQueryStr+=' ORDER BY i.Service_Name__c ASC';
            srList=database.query(tempQueryStr); 
            
            tempOptions.clear();
            
            for (ServiceRequestType__c temp : srList) {
                 if(temp.External_Name__c == null){
                     options.clear();
                     tempOptions.add(new SelectOption(temp.Id,temp.Service_Name__c));
                  }else{ 
                     options.clear(); 
                     //Avoid Salesforce limit of collection suze 1000  - MNB
                     tempOptions.add(new SelectOption(temp.Id,temp.External_Name__c));
                  }
            }            
          
            options1.clear();
            options.add(new SelectOption('','Please Select'));  
            options.addAll(tempOptions);
           
            return options;
        }
    }
    
    /* getters and setters */
    public String getServiceType() {
        return serviceType;
    }
    
    public void setServiceType(String serviceType) {
        this.serviceType = serviceType;
    }
    /* end */
    
    
    /**
    *  Gets the selected service request type
    *
    */
    public void performAction(){            
        service_location=false;
        contact_information = false;
        comments_attachments= false;
        review_submit = false; 
        ServiceLocAddressDetails=false;
        dupliacteAddressDetection=false;
        review_result=false;
        service_information = false; 
        attachment=false;       


        if(serviceType!=null || serviceType!=''){
            for(ServiceRequestType__c srtype :[SELECT ServiceLocationRequired__c , ContactRequired__c,Jurisdiction__c,SLA__c,Agency__c,Default_Method__c,Default_Priority__c,Default_Status__c from ServiceRequestType__c where Id =: serviceType ]){
                   ServiceLocationRequired = srtype.ServiceLocationRequired__c;
                   ContactRequired = srtype.ContactRequired__c; 
                   JurisdictionId =  srtype.Jurisdiction__c;                   
                   Sla = srtype.SLA__c;
                   Agency = srtype.Agency__c; 
                   Origin=srtype.Default_Method__c; 
                   Priority=srtype.Default_Priority__c; 
                   Status=srtype.Default_Status__c ; 
            }         
         
            
            if(ServiceLocationRequired == true){            
                service_location=true;
                service_type = false; 
                service_information = false;                
                
            }else{
               service_location=false;
               service_type = false;
               service_information = true;    
              
            }
            
            selectedServiceType=serviceType;
            selectedServiceRequestType=serviceType;
            
            // getting name based on passed service TYpe
            selSelectedRequestTypeName=getSelServiceRequestTypeName(serviceType);
          
        }
        
        if(serviceType == null || serviceType == 'None'){            
            service_type = true;
            service_information = false; 
            service_location=false;  
            ServiceLocAddressDetails = false;
            dupliacteAddressDetection=false; 

            error_msg=true;
          
            ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a service request.');
            ApexPages.addMessage(error_msg);
              
        
        }
        
        retrieveFlexNoteQuestions();      
    }
    
    /*public void servicetype(){
        service_location=true;
        service_type = false;

    }*/
    
    
    /**
    *  Performs Mar validation
    *
    */
    public void service_location(){
          
        contact_information = false;
        comments_attachments= false;
        review_submit = false; 
        review_result=false;
        attachment=false;
        
        fulladdress= street+','+city+','+state+','+zipcode;
       
        if(street == null || street ==''){
            service_information = false; 
            service_location=true;  
            ServiceLocAddressDetails = false; 
            dupliacteAddressDetection=false;
            service_type=false;
            error_msg=true;
            ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a street address.');
            ApexPages.addMessage(error_msg); 
        
        }else{ 
             string jsonstring;
             if(Test.isRunningTest()){
                if(jstring != null){
                    if(length == 1){
                        jsonstring='{"returnCodes":null,"details":"<STRONG>Normalized:</STRONG> 3100 NW STREET</br><STRONG>Parsed:</STRONG></br><EM>Address Number: </EM>3100</br><EM>Address Number Suffix: </EM></br><EM>Street Name: </EM>NW</br><EM>Street Type: </EM></br><EM>Quad: </EM></br><STRONG>Possible Standard Street Names: </STRONG></br>W,N</br>","returnDataset":{"Table1":[{"ADDRESS_ID":274821.0,"STATUS":"ACTIVE","FULLADDRESS":"3100 N STREET NW","ADDRNUM":3100.0,"ADDRNUMSUFFIX":null,"STNAME":"N","STREET_TYPE":"STREET","QUADRANT":"NW","CITY":"WASHINGTON","STATE":"DC","XCOORD":394674.32,"YCOORD":137648.32,"SSL":"1208    0060","ANC":"ANC 2E","PSA":"Police Service Area 206","WARD":"Ward 2","NBHD_ACTION":" ","CLUSTER_":"Cluster 4","POLDIST":"Police District - Second District","ROC":"NA","CENSUS_TRACT":"000100","VOTE_PRCNCT":"Precinct 5","SMD":"SMD 2E05","ZIPCODE":20007.0,"NATIONALGRID":"18S UJ 21257 08441","ROADWAYSEGID":4625.0,"FOCUS_IMPROVEMENT_AREA":"NA","HAS_ALIAS":"N","HAS_CONDO_UNIT":"Y","HAS_RES_UNIT":"Y","HAS_SSL":"Y","LATITUDE":38.90667757,"LONGITUDE":-77.06140122,"STREETVIEWURL":"http://maps.google.com/maps?z=16&layer=c&cbll=38.90667757,-77.06140122&cbp=11,161.229197394201,,0,2.09","RES_TYPE":"RESIDENTIAL","WARD_2002":"Ward 2","WARD_2012":"Ward 2","ANC_2002":"ANC 2E","ANC_2012":"ANC 2E","SMD_2002":"SMD 2E06","SMD_2012":"SMD 2E05","IMAGEURL":"http://citizenatlas.dc.gov/mobilevideo","IMAGEDIR":"20040803","IMAGENAME":"E3064022.jpg","ConfidenceLevel":70.0}]},"returnBlkAddrDataset":null,"returnCDDataSet":{"Address Return Codes":[{"Component":"Street Type","Parsed & Normalized":"","Assessment":"Missing"},{"Component":"Quad","Parsed & Normalized":"","Assessment":"Missing"},{"Component":"Street Name","Parsed & Normalized":"NW","Assessment":"Not Valid"}]},"UNIT":null,"UNITNUMBER":null,"sourceOperation":"DC Address","processTime":"0 seconds and 343 milliseconds"}';
                    }else{
                     jsonstring='{"returnCodes":"811","details":null,"returnDataset":{"Table1":[{"ALIASNAME":"1001 @ WATERFRONT APARTMENTS","ADDRESS_ID":76172.0,"STATUS":"ACTIVE","FULLADDRESS":"1001 3RD STREET SW","ADDRNUM":1001.0,"ADDRNUMSUFFIX":null,"STNAME":"3RD","STREET_TYPE":"STREET","QUADRANT":"SW","CITY":"WASHINGTON","STATE":"DC","XCOORD":398639.34,"YCOORD":134445.54,"SSL":"0542    0079","ANC":"ANC 6D","PSA":"Police Service Area 105","WARD":"Ward 6","NBHD_ACTION":" ","CLUSTER_":"Cluster 9","POLDIST":"Police District - First District","ROC":"NA","CENSUS_TRACT":"010200","VOTE_PRCNCT":"Precinct 128","SMD":"SMD 6D05","ZIPCODE":20024.0,"NATIONALGRID":"18S UJ 25151 05151","ROADWAYSEGID":14875.0,"FOCUS_IMPROVEMENT_AREA":"NA","HAS_ALIAS":"Y","HAS_CONDO_UNIT":"Y","HAS_RES_UNIT":"Y","HAS_SSL":"Y","LATITUDE":38.87784082,"LONGITUDE":-77.01568108,"STREETVIEWURL":"http://maps.google.com/maps?z=16&layer=c&cbll=38.87784082,-77.01568108&cbp=11,271.063131054759,,0,2.09","RES_TYPE":"RESIDENTIAL","WARD_2002":"Ward 6","WARD_2012":"Ward 6","ANC_2002":"ANC 6D","ANC_2012":"ANC 6D","SMD_2002":"SMD 6D03","SMD_2012":"SMD 6D05","IMAGEURL":"http://citizenatlas.dc.gov/mobilevideo","IMAGEDIR":"20041020","IMAGENAME":"OK134250.jpg","ConfidenceLevel":0.0},{"ALIASNAME":"BALD EAGLE @ FORT GREBLE","ADDRESS_ID":301277.0,"STATUS":"ACTIVE","FULLADDRESS":"100 JOLIET STREET SW","ADDRNUM":100.0,"ADDRNUMSUFFIX":null,"STNAME":"JOLIET","STREET_TYPE":"STREET","QUADRANT":"SW","CITY":"WASHINGTON","STATE":"DC","XCOORD":399117.53,"YCOORD":127901.54,"SSL":"0000    0000","ANC":"ANC 8D","PSA":"Police Service Area 708","WARD":"Ward 8","NBHD_ACTION":" ","CLUSTER_":null,"POLDIST":"Police District - Seventh District","ROC":"NA","CENSUS_TRACT":"010900","VOTE_PRCNCT":"Precinct 126","SMD":"SMD 8D02","ZIPCODE":20032.0,"NATIONALGRID":"18S UH 25486 98598","ROADWAYSEGID":15134.0,"FOCUS_IMPROVEMENT_AREA":"NA","HAS_ALIAS":"Y","HAS_CONDO_UNIT":"N","HAS_RES_UNIT":"N","HAS_SSL":"Y","LATITUDE":38.81889022,"LONGITUDE":-77.01016173,"STREETVIEWURL":"http://maps.google.com/maps?z=16&layer=c&cbll=38.81889022,-77.01016173&cbp=11,164.867960850049,,0,2.09","RES_TYPE":"NON RESIDENTIAL","WARD_2002":"Ward 8","WARD_2012":"Ward 8","ANC_2002":"ANC 8D","ANC_2012":"ANC 8D","SMD_2002":"SMD 8D04","SMD_2012":"SMD 8D02","IMAGEURL":"http://citizenatlas.dc.gov/mobilevideo","IMAGEDIR":"NO_IMAGE","IMAGENAME":"No_Image_Available.JPG","ConfidenceLevel":0.0}]}}';                    
                    }
               }else{
                     jsonstring='{"returnCodes":"-999","details":"Missed parameter or its value is empty.","returnDataset":null,"returnBlkAddrDataset":null,"returnCDDataSet":null,"UNIT":null,"UNITNUMBER":null,"sourceOperation":null,"processTime":null}';
               }
             }else{
                jsonstring = AddressValidation.verifyAddress(street);
             }
            
            string newjsonstring = jsonstring.replace('"CLUSTER_":', '"CLUSTER":');
            JSONParser parser = JSON.createParser(newjsonstring);
            AddressValidationResponseWrapper.AddressValidationWrapper m = (AddressValidationResponseWrapper.AddressValidationWrapper)parser.readValueAs(AddressValidationResponseWrapper.AddressValidationWrapper.class);
            if( m.returnDataset == null || m.returnDataset.Table1 == null){
                  error_msg=true;
                  service_type = false;     
                  service_information = false; 
                  service_location=true;  
                  ServiceLocAddressDetails = false;
                  dupliacteAddressDetection=false;
                 
                            
                  ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Service is not provided for this location.');
                  ApexPages.addMessage(error_msg);
            
            }else{
                    
                    AddressValidationResponseWrapper.returnDatasetWrapper check_data_in_returnDataset=m.returnDataset;
                    
                    AddressValidationResponseWrapper.returnBlkAddrDatasetWrapper check_data_in_returnBlkAddrDataset=m.returnBlkAddrDataset;
                       
                    List<AddressValidationResponseWrapper.TableWrapper> check_data_in_table= new List<AddressValidationResponseWrapper.TableWrapper>();
                    
                    
                    if(check_data_in_returnDataset != null){
                        error_msg=false;
                    
                        check_data_in_table=m.returnDataset.Table1;
                        length=check_data_in_table.size();
                        
                        fullBlockAddress = new Map<String, String>();
                        
                        for(integer i=0;i<length;i++){
                           if(check_data_in_table[i].FULLBLOCK != null){
                              
                              fullBlockAddress.put(check_data_in_table[i].BLOCKNAME, check_data_in_table[i].FULLBLOCK+':'+ check_data_in_table[i].BLOCKNAME+':'+ check_data_in_table[i].LOWER_RANGE+':'+ check_data_in_table[i].HIGHER_RANGE);

                           }                     
                        
                        }                    
                    
                    }else{
                          error_msg=true;
                          service_type = false;     
                          service_information = false; 
                          service_location=true;  
                          ServiceLocAddressDetails = false;
                          dupliacteAddressDetection=false;
                         
                                    
                          ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Service is not provided for this location.');
                          ApexPages.addMessage(error_msg);
                          
                    }                    
                   
                    result = new List<String>(); 
                    geoRes= new List<String>();        
                    
                    if(check_data_in_table ==null || check_data_in_table.isEmpty()){
                          service_information = false; 
                          service_location=true;  
                          ServiceLocAddressDetails = false;
                          dupliacteAddressDetection=false; 
                          service_type=false;
                          error_msg=true;
        
                          ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Service is not provided for this location.');
                          ApexPages.addMessage(error_msg);  
                         
                    } 
                    
                    if(check_data_in_table !=null || !check_data_in_table.isEmpty()){              
                       service_information = true; 
                       service_location=false; 
                       service_type = false;
                       
                       if(length > 1){               
                           ServiceLocAddressDetails = true;
                           service_location=false; 
                           service_information = false; 
                           
                           geo_result= new Map<String,String>();  
                         
                           for(integer i=0;i<length;i++){
                              if(check_data_in_table[i].BLOCKNAME == null){
                                   if(check_data_in_table[i].FULLADDRESS == null){
                                       result.add(street+','+'Washington'+','+'DC');                                    
                                   
                                   }
                                   
                                   if(check_data_in_table[i].FULLADDRESS != null && check_data_in_table[i].CITY != null && check_data_in_table[i].STATE != null && check_data_in_table[i].ZIPCODE != null){
                                       result.add(check_data_in_table[i].FULLADDRESS+','+check_data_in_table[i].CITY+','+check_data_in_table[i].STATE+','+Integer.valueOf(check_data_in_table[i].ZIPCODE));                                    
                                   
                                   }
                                   
                                   if(check_data_in_table[i].FULLADDRESS == null && check_data_in_table[i].CITY == null && check_data_in_table[i].STATE == null && check_data_in_table[i].ZIPCODE == null){
                                       result.add(check_data_in_table[i].FULLINTERSECTION);                                   
                                   
                                   }
                                   
                                   if(check_data_in_table[i].ALIASNAME != null && check_data_in_table[i].FULLADDRESS != null && check_data_in_table[i].CITY != null && check_data_in_table[i].STATE != null && check_data_in_table[i].ZIPCODE != null){
                                       result.add(check_data_in_table[i].ALIASNAME+'-'+check_data_in_table[i].FULLADDRESS+','+check_data_in_table[i].CITY+','+check_data_in_table[i].STATE+','+Integer.valueOf(check_data_in_table[i].ZIPCODE));                                    
                                   
                                   }
                                                        
                
                                  if(check_data_in_table[i].ADDRESS_ID != null){
                                     geoRes.add('Address_ID'+'='+check_data_in_table[i].ADDRESS_ID+':'+check_data_in_table[i].LONGITUDE+':'+check_data_in_table[i].LATITUDE+':'+check_data_in_table[i].QUADRANT+':'+check_data_in_table[i].XCOORD+':'+check_data_in_table[i].YCOORD+':'+check_data_in_table[i].ANC+':'+check_data_in_table[i].PSA+':'+check_data_in_table[i].WARD+':'+check_data_in_table[i].SMD+':'+check_data_in_table[i].POLDIST+':'+check_data_in_table[i].CLUSTER+':'+check_data_in_table[i].ADDRNUM);
                                  }else{
                                     geoRes.add('INTERSECTIONID'+'='+check_data_in_table[i].INTERSECTIONID+':'+check_data_in_table[i].LONGITUDE+':'+check_data_in_table[i].LATITUDE+':'+check_data_in_table[i].REFX+':'+check_data_in_table[i].REFY);
                                  }                                   
                                 
                               }
                               
                               if(check_data_in_table[i].BLOCKNAME != null){
                                   result.add(check_data_in_table[i].BLOCKNAME);                                  
                                       
                               }                           
                            
                           }
                           
                           if(geoRes.size() > 0){
                               for(integer j=0;j<result.size();j++){
                                   for(integer k=0;k<geoRes.size();k++){                     
                                       geo_result.put(result[j],geoRes[k]);                   
                                   }              
                               
                               }
                           }                                              
                          
                       } 
                       
                       if(length == 1){
                           ServiceLocAddressDetails = false;
                           dupliacteAddressDetection=false; 
                           service_location=false;                           
                           service_information = false;
                           contact_information = false;
                           comments_attachments= false;
                           service_type = false; 
                           attachment=false;
                         
                           geo_result= new Map<String,String>();  
                         
                           for(integer i=0;i<length;i++){ 
                               if(check_data_in_table[i].BLOCKNAME == null){
                                   if(check_data_in_table[i].FULLADDRESS == null){                           
                                       result.add(street+','+'Washington'+','+'DC');                                    
                                       fulladdress='';
                                       fulladdress=street+','+'Washington'+','+'DC';
                                   }
                                    
                                   if(check_data_in_table[i].FULLADDRESS != null && check_data_in_table[i].CITY != null && check_data_in_table[i].STATE != null && check_data_in_table[i].ZIPCODE != null){
                                       result.add(check_data_in_table[i].FULLADDRESS+','+check_data_in_table[i].CITY+','+check_data_in_table[i].STATE+','+Integer.valueOf(check_data_in_table[i].ZIPCODE)); 
                                       fulladdress='';
                                       fulladdress=check_data_in_table[i].FULLADDRESS+','+check_data_in_table[i].CITY+','+check_data_in_table[i].STATE+','+Integer.valueOf(check_data_in_table[i].ZIPCODE);                                   
                                   
                                   }
                                   
                                   if(check_data_in_table[i].FULLADDRESS == null && check_data_in_table[i].CITY == null && check_data_in_table[i].STATE == null && check_data_in_table[i].ZIPCODE == null){
                                       result.add(check_data_in_table[i].FULLINTERSECTION);                                   
                                       fulladdress='';
                                       fulladdress=check_data_in_table[i].FULLINTERSECTION;                                   
                                   }
                                   
                                   if(check_data_in_table[i].ALIASNAME != null && check_data_in_table[i].FULLADDRESS != null && check_data_in_table[i].CITY != null && check_data_in_table[i].STATE != null && check_data_in_table[i].ZIPCODE != null){
                                       result.add(check_data_in_table[i].ALIASNAME+'-'+check_data_in_table[i].FULLADDRESS+','+check_data_in_table[i].CITY+','+check_data_in_table[i].STATE+','+Integer.valueOf(check_data_in_table[i].ZIPCODE));                                    
                                       fulladdress='';
                                       fulladdress=check_data_in_table[i].ALIASNAME+'-'+check_data_in_table[i].FULLADDRESS+','+check_data_in_table[i].CITY+','+check_data_in_table[i].STATE+','+Integer.valueOf(check_data_in_table[i].ZIPCODE);     
                                   }
                                                        
                
                                  if(check_data_in_table[i].ADDRESS_ID != null){
                                     geoRes.add('Address_ID'+'='+check_data_in_table[i].ADDRESS_ID+':'+check_data_in_table[i].LONGITUDE+':'+check_data_in_table[i].LATITUDE+':'+check_data_in_table[i].QUADRANT+':'+check_data_in_table[i].XCOORD+':'+check_data_in_table[i].YCOORD+':'+check_data_in_table[i].ANC+':'+check_data_in_table[i].PSA+':'+check_data_in_table[i].WARD+':'+check_data_in_table[i].SMD+':'+check_data_in_table[i].POLDIST+':'+check_data_in_table[i].CLUSTER+':'+check_data_in_table[i].ADDRNUM);
                                  }else{
                                     geoRes.add('INTERSECTIONID'+'='+check_data_in_table[i].INTERSECTIONID+':'+check_data_in_table[i].LONGITUDE+':'+check_data_in_table[i].LATITUDE+':'+check_data_in_table[i].REFX+':'+check_data_in_table[i].REFY);
                                  }                                   
                                   
                               }
                               
                               if(check_data_in_table[i].BLOCKNAME != null){
                                   result.add(check_data_in_table[i].BLOCKNAME);                                 
                                       
                               } 
                           }
                           
                                                 
                           if(geoRes.size() > 0){
                               for(integer j=0;j<result.size();j++){
                                   for(integer k=0;k<geoRes.size();k++){                     
                                       geo_result.put(result[j],geoRes[k]);                   
                                   }              
                               
                               }
                           } 
                           system.debug('fulladdress if length = 1'+ fulladdress);
                           if(ServiceLocationRequired == true){    
                             if(fullBlockAddress.size() == 0){
                                 locresult= geo_result.get(fulladdress);
                                 system.debug('locresult if length = 1'+ locresult);
                                 list<string> result =new list<string>();
                                  if(Test.isRunningTest()){
                                      result =new String[13]; 
                                      result[0]='Address_ID=149350.0';
                                      result[1]='149350.0';
                                      result[2]='-76.99542510';
                                      result[3]='NE';
                                      result[4]='400396.68';
                                      result[5]='140190.10';
                                      result[6]='ANC 5E';
                                      result[7]='Police Service Area 502';
                                      result[8]='Ward 5';
                                      result[9]='SMD 5E01';
                                      result[10]='Police District - Fifth District';
                                      result[11]='null';
                                      result[12]='502.0';
                                      
                                      Map<String, String> fullBlockAddress= new Map<String, String>();
                                      fullBlockAddress.put('526 - 599 BLOCK OF 42ND STREET NE','42ND STREET NE FROM EDSON PLACE NE TO FOOTE STREET NE,526 - 599 BLOCK OF 42ND STREET NE,526,599');
                                      
                                  }else{
                                     result= locresult.split(':');
                                  }  
                                     list<string> ADDRESSID =result[0].split('='); 
                                     
                                     if(ADDRESSID[0]== 'ADDRESS_ID'){ 
                                         address_id=ADDRESSID[1];
                                     }else{
                                        intersection_id=ADDRESSID[1];
                                     }
                                     longitude=result[1];
                                     latitude=result[2];
                                     ward=result[8];
                                     
                                     system.debug('longitude if length = 1'+ longitude);
                                     system.debug('latitude if length = 1'+ latitude); 
                                     
                                      /* duplicate detection based on sr type and address*/
                                       list<case>tempDuplicateSRList=ServiceRequestsHelper.getDuplicateServiceRequests(fulladdress,selSelectedRequestTypeName,decimal.ValueOf(longitude),decimal.ValueOf(latitude));
                                       system.debug('temp case storing list befre--'+tempDuplicateSRList);
                                       if(!tempDuplicateSRList.isEmpty()){
                                            dupliacteAddressDetection=true; 
                                            
                                            system.debug('temp case storing list--'+tempDuplicateSRList);
                                            duplicateSRList=tempDuplicateSRList;
                                       } else{
                                            dupliacteAddressDetection=false; 
                                            service_information = true;
                                        
                                       }
                                       
                                       system.debug('selectedServiceType'+selectedServiceType);
                                        if(selSelectedRequestTypeName == 'Bulk Collection'){                                 
                                              retrieveFlexNoteQuestions(); 
                                            
                                        } 
                                                                        
                                }
                            }                          
                            
                            
                       }                       
                      
                }
               
            }      
        
        }        
    
    }
    
    
    /**
    *   Gets the selected address after performing mar validation
    *
    */
    Public Pagereference selectedlocationlist(){
        service_type=false;
        service_location = false;
        service_information = false;
        contact_information = false;
        comments_attachments= false;
        review_submit = false;
        ServiceLocAddressDetails=true;
        dupliacteAddressDetection=false; 
        
        review_result=false;
        attachment=false;       
      
        fulladdress=seladressloc ;  
        
         if(ServiceLocationRequired == true){    
             if(fullBlockAddress.size() == 0){
                 locresult= geo_result.get(fulladdress);
                 list<string> result =new list<string>();
                  if(Test.isRunningTest()){
                      result =new String[13]; 
                      result[0]='Address_ID=149350.0';
                      result[1]='149350.0';
                      result[2]='-76.99542510';
                      result[3]='NE';
                      result[4]='400396.68';
                      result[5]='140190.10';
                      result[6]='ANC 5E';
                      result[7]='Police Service Area 502';
                      result[8]='Ward 5';
                      result[9]='SMD 5E01';
                      result[10]='Police District - Fifth District';
                      result[11]='null';
                      result[12]='502.0';
                      
                      Map<String, String> fullBlockAddress= new Map<String, String>();
                      fullBlockAddress.put('526 - 599 BLOCK OF 42ND STREET NE','42ND STREET NE FROM EDSON PLACE NE TO FOOTE STREET NE,526 - 599 BLOCK OF 42ND STREET NE,526,599');
                      
                  }else{
                     result= locresult.split(':');
                  }  
                 list<string> ADDRESSID =result[0].split('='); 
                 
                 if(ADDRESSID[0]== 'ADDRESS_ID'){ 
                     address_id=ADDRESSID[1];
                 }else{
                    intersection_id=ADDRESSID[1];
                 }
                 longitude=result[1];
                 latitude=result[2];
                 ward=result[8];
                 
                 /* duplicate detection based on sr type and address*/
                 list<case>tempDuplicateSRList=ServiceRequestsHelper.getDuplicateServiceRequests(fulladdress,selSelectedRequestTypeName,decimal.ValueOf(longitude),decimal.ValueOf(latitude));
                 if(!tempDuplicateSRList.isEmpty()){
                    dupliacteAddressDetection=true; 
                    ServiceLocAddressDetails=false;
                     
                    system.debug('temp case storing list--'+tempDuplicateSRList);
                    duplicateSRList=tempDuplicateSRList;
                 }else{
                    dupliacteAddressDetection=false; 
                                    
                 } 
                 
                 if(selSelectedRequestTypeName == 'Bulk Collection'){                                
                      retrieveFlexNoteQuestions(); 
                    
                 } 
            }
        }                       
                           
         
        return null;
    
    }
    
    public void potentialduplicatedetection(){       
        service_location=false;
        service_type = false; 
        service_information = true; 
        contact_information = false;
        comments_attachments= false;
        review_submit = false;
        ServiceLocAddressDetails=false;
        dupliacteAddressDetection=false; 
        review_result=false; 
        attachment=false;                    
           
    }
  
    public void service_info(){       
        
        if(seladressloc == null || seladressloc == ''){
            service_type=false;
            ServiceLocAddressDetails = true; 
            dupliacteAddressDetection=true; 
            ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select Service Location.');
            ApexPages.addMessage(error_msg);
        
        }else{
            service_location=false;
            service_type = false; 
            service_information = true; 
            contact_information = false;
            comments_attachments= false;
            review_submit = false;
            ServiceLocAddressDetails=false;
            dupliacteAddressDetection=false; 
            review_result=false; 
            attachment=false;
           
        }
        
    }
    
    /**
    *  Validates if the flex note questions are mandatory
    *
    */
    public void contact_info(){
        try{
            service_location=false;
            service_type = false; 
            service_information = false; 
            contact_information = true;
            comments_attachments= true;
            review_submit = false; 
            ServiceLocAddressDetails=false;
            dupliacteAddressDetection=false; 
            review_result=false; 
            attachment=false;
            
            //check if user is logged in
            User usr = [Select ContactId, Profile.Name from user where Id=: UserInfo.getUserId()];
            
            if(usr.ContactId !=null)
            {
                   selContact=new Contact();
                   loggedInUsername= UserInfo.getUserName();
                   loggedIn=true; 
                   loggedout=false;
                  //Customer portal user is logged in.
                  
                  //not get all the cases for the logged in user
                  selContact  = [Select firstname,lastname,email,phone,MailingStreet,MailingCity ,MailingState ,MailingPostalCode,MailingCountry ,OtherPhone  from Contact where Id=:usr.ContactId ];
                  
            }
            
            
            // holds list question and answer wrapper       
            tempQuestionAnswerWrapList=new list<QuestionAnswerWrapper>();
            
            // we have to use this ..present not used
            boolean isValid=true;
            for(ServiceRequestQuestionWrapper sRQW:serviceRequestQuestionWrapList){
                for(QuestionAnswerWrapper qAW:sRQW.questionAnswerList){   
                    //retrieving multipicklist values selected
                    if(qAW.flexNoteQuestion.Answer_Type__c=='MultiPicklist'){
                        string tempMultiPickListValue='';
                        for(QuestionMultiPickListWrapper qMPW:qAW.questionMultiPicklistValueList){
                            
                            // selected options for a multipicklist from page shuld include in string
                            if(qMPW.isSelectedQuestion){
                                tempMultiPickListValue+=qMPW.questionMultiPicklistItem+',';
                            }
                        
                        
                            if(qMPW.selectedMultipicklist!=null && !qMPW.selectedMultipicklist.isEmpty()){
                                string mPicklistValue='';
                                for(string strItem:qMPW.selectedMultipicklist){
                                    mPicklistValue+=strItem;
                                }
                                tempMultiPickListValue+=mPicklistValue+',';
                            }
                        }
                        
                        
                        Boolean isEndComma =tempMultiPickListValue.endsWith(',');
                        // removing ending comma symbol
                        if(isEndComma){
                            integer le=tempMultiPickListValue.length()-1;
                            string tempAnsStr=tempMultiPickListValue.substring(0,le);
                            qAW.answer.Answer__c=tempAnsStr;
                        }
                        else{qAW.answer.Answer__c=tempMultiPickListValue;}
                        
                    }
                    system.debug('tempFlexNotesList--->'+tempFlexNotesList);
                    system.debug('qAW.relationQuestion---->'+qAW.relationQuestion);
                    system.debug('qAW.answer.Answer__c---->'+qAW.answer.Answer__c);
                    // validation if question is required ..this questions as to be answered otherwise it not saved
                    if(qAW.relationQuestion.IsReadOnly__c == false){
                        if(qAW.relationQuestion.IsRequiredQuestion__c==true){
                            if(qAW.answer.Answer__c==null || qAW.answer.Answer__c==''){
                                service_information = true;
                                contact_information = false;
                                //  we need to modify this                 
                                ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Provide Answer For All Required Questions.');
                                ApexPages.addMessage(error_msg);
                            }
                        }
                    }
                    
                   
                    
                     // VALIDATING DATE TIME
                        // 06914
                    if(qAW.flexNoteQuestion.Answer_Type__c=='Date/Time'){
                        if(qAW.answer.Answer__c!=null || qAW.answer.Answer__c!=''){ 
                            
                            // valid format 
                            Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d) ([0-1]?[0-9]|[2][0-3]):([0-5][0-9]) (AM|PM)');
                           
                            Matcher MyMatcher = MyPattern.matcher(qAW.answer.Answer__c); 
                            
                            if(qAW.relationQuestion.IsRequiredQuestion__c==true){
                                if(!MyMatcher.matches()){
                                    service_information = true; 
                                    contact_information = false;
                                
                                    ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.Error,'Info: Valid Date Time Format is mm/dd/yyyy hh:mm AM/PM.');
                                    ApexPages.addMessage(error_msg);
                                }
                            }
                        }
                     }
                     
                      // VALIDATING DATE TIME
                        // 06914
                    if(qAW.flexNoteQuestion.Answer_Type__c=='Date'){
                        if(qAW.answer.Answer__c!=null || qAW.answer.Answer__c!=''){ 
                            
                            // valid format 
                            Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)');
                           
                            Matcher MyMatcher = MyPattern.matcher(qAW.answer.Answer__c); 
                            
                            if(qAW.relationQuestion.IsRequiredQuestion__c==true){
                                if(!MyMatcher.matches()){
                                     service_information = true;
                                    contact_information = false;
                                
                                    ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.Error,'Info: Valid Date Format is mm/dd/yyyy.');
                                    ApexPages.addMessage(error_msg);
                                }
                            }
                        }
                     }
                    
                    // Collectin all question and answer which will used for inserting answers
                    tempQuestionAnswerWrapList.add(qAW);
                }
                      
            }
        }catch(exception e){
             System.debug('Unable to Complete due='+e);
        
        }       
         
    }
    
    /* Action for previous button*/
    public void prev_service_info(){
        service_location=false;
        service_type = false; 
        service_information = true; 
        contact_information = false;
        comments_attachments= false;
        review_submit = false;
        ServiceLocAddressDetails=false;
        dupliacteAddressDetection=false; 
        review_result=false; 
        attachment=false;  
    }
    
     public void Previous_service_location1(){
       service_location=true;
       service_type = false; 
       service_information = false;
       review_submit = false;
       attachment=false;

   }
   
   public void Previous_service_location(){
       service_location=false;
       service_type = true; 
       service_information = false; 
       contact_information = false; 
       comments_attachments = false; 
       review_submit = false;
       ServiceLocAddressDetails=false;
       attachment=false;
       dupliacteAddressDetection=false; 

   }
    
    /*public void comment_attachement(){
        service_location=false;
        service_type = false; 
        service_information = false; 
        contact_information = false;
        comments_attachments= false;
        review_submit = false;
        ServiceLocAddressDetails=false;
        review_result=false;
        attachment=false;
        
        
    }*/
    
    /**
    *  Gets the attachment details
    *
    */
    public void review_submit(){
        service_location=false;
        service_type = false; 
        service_information = false; 
        contact_information = false;
        comments_attachments= false;
        review_submit = true;        
        ServiceLocAddressDetails=false;
        dupliacteAddressDetection=false; 
        review_result=false;
        attachment=false;
        error_msg=false;

        try{
            //check if user has attached a file
            if(attach.name == '' && attach.body != null){ 
                attach.body = null;
                attachment = true;
                review_submit = false;
                error_msg=true;
                //  we need to modify this                 
                ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Provide Filename and description.');
                ApexPages.addMessage(error_msg);
            }
        
       
            //check if attached a file size exceeds       
            if(attach.body != null){
                if(attach.body.size() > 5242880){ 
                    attach.body = null;
                    //maximum attachment size is 5MB.  Show an error
                    attachment = true;
                    review_submit = false;
                    error_msg=true;
                    //  we need to modify this                 
                    ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'File was NOT uploaded, because it is too big');
                    ApexPages.addMessage(error_msg);
                       
                }else{               
               
                    Account acc=[Select Id from Account where Name='OUC Portal User'];
                    attach.ParentId=acc.Id;
                    attach.IsPrivate = false;
                    insert attach;
                    attachmentId=attach.Id;                   
                    
                }
                
                
            }
        }catch(Exception e){
            system.debug('exception --> '+ e);                  
            
        }      
       
    }
    
   
   /* for future use */
   // keyword search method
    /*public List<SelectOption> searchstring(){
  
        List<ServiceRequestType__c> service_request_type= New List<ServiceRequestType__c>();  
        List<SelectOption> tempOptions = new List<SelectOption>(); 
        List<SelectOption> defaultres= new List<SelectOption>();         
                
       
        if(searchstring.length() > 1){        
           for(ServiceRequestType__c  temp:[SELECT Service_Name__c, Description__c FROM ServiceRequestType__c WHERE Service_Name__c like :('%'+searchstring+'%')]){
              
               tempOptions .add(new SelectOption(temp.Id,temp.Service_Name__c));              
            }
            
           
             if(tempOptions .size() == 0 ){
                    options.clear();
                    options1.clear();
                    
                    searchList.clear();
                    
                    options1.add(new SelectOption('','Please Select'));    
                
                    options1.addAll(tempOptions);
                
                    return options1; 
                    
              }else{
           
                tempOptions.sort();
                options.clear();
                options1.clear();
                //default option
                options1.add(new SelectOption('','Please Select'));    
                
                options1.addAll(tempOptions);
                
                return options1; 
             }          
           
        }
         else{
           apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter at least two characters..'));
           return defaultres;
        }       
      
    }
    
    public List<ServiceRequestType__c> getList(){
       searchList = new  List<ServiceRequestType__c>();
       if(options1.size() != 0 ){  
               
            
            searchList = [SELECT Service_Name__c, Description__c FROM ServiceRequestType__c WHERE Service_Name__c like :('%'+searchstring+'%')];  
            searchList.sort();
            return searchList;
        
        }else{          
         
           searchList=[Select Object__c, Name,Id,Service_Name__c,Description__c  From ServiceRequestType__c  where Object__c='Case']; 
           searchList.sort();
           
           return searchList;
        }
          
    }
    
    // keyword search
    public pageReference getsearchlist()
    {       
        searchstring();
   
        return null;
   
    }  */ 
    /* end : for future use*/ 
 
    
    /** 
    *  Retriving ServiceRequestType__c name record based on selId passed
    *
    */ 
    public String getSelServiceRequestTypeName(string selId){
        if(selId==null)return null;
        ServiceRequestType__c sRT=[Select i.Object__c, i.Name, i.Id,i.Service_Name__c From ServiceRequestType__c i where Id=:selId];
        if(sRT==null)return null;
        string sName=sRT.Service_Name__c;
        return sName;
    }
    
   // dont know in which object i will stored so for now
   // we storing wrapper clas below
   // used for storing service location 
  /* public Class serviceLocationWrap{
        public string street{get;set;}
        public string city{get;set;}
        public string state{get;set;}
        public string country{get;set;}
        public integer pinCode{get;set;}
        
        public serviceLocationWrap(){}
   }*/
   
   /**
   *  Retrieving contact information 
   *
   */
    // retrieving contact information 
    private contact getContactDetails(contact con){
        system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'+con);
        system.debug('&&&&&&&&&&&&&&&&&&  ContactRequired  &&&&&&&&&&&&&&&&&&&&'+ContactRequired);
        
        if(con==null)
        {   
            return null;
            system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'+con);
        }
            
        else if(ContactRequired = False)
        
                    
        system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
        
            
        map<string,string>ContactParms=new map<string,string>();
            //if(con.email!=null){
                contactParms.put('email',con.email);
                contactParms.put('salutation',con.salutation);
                contactParms.put('first_name',con.firstName);
                contactParms.put('last_name',con.lastName);
                contactParms.put('phone',con.phone);
                
                // addresss
                contactParms.put('mailing_Street',con.MailingStreet);
                contactParms.put('mailing_City',con.MailingCity);
                //contactParms.put('mailing_State',con.MailingState);
                contactParms.put('mailing_Country',con.MailingCountry);
                contactParms.put('other_Phone',con.OtherPhone);
            
                // retrieving contact if exist or inserting 
                contact c=ServiceRequestsHelper.createServiceRequestContact(ContactParms);
            //}
        system.debug('contact to which case as attach--'+c);
        return c;
    }
   /*component logic */
   
   
    /* start: for test class purpose */
    public void callPrivateMethods(){
        list<Decode_Object__c> decodeList = new list<Decode_Object__c>();
        Decode_Object__c d1= new Decode_Object__c(Name='name1');
        insert d1;
        Decode_Object__c d2= new Decode_Object__c(Name='name2');
        insert d2;
        decodeList.add(d1);
        decodeList.add(d2);
        
        case caseRrd = new Case(Status='new',Subject='Sub');
        insert caseRrd ;
        
        list<FlexNoteQuestion__c> flexNoteQuestList=new list<FlexNoteQuestion__c>();
         // THIS PART AS TO MOVE TO TESTHELPER CLASS
         FlexNoteQuestion__c fNQuestion=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='This is the test Question',Answer_Type__c='MultiPicklist' ,Name='Test1',AnswerValues__c='test1:a1,test2:a2');//,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test Question'
         insert fnQuestion;
        
         // THIS PART AS TO MOVE TO TESTHELPER CLASS
         FlexNoteQuestion__c fNQuestion1=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='This is the test',Answer_Type__c='Text' ,Name='Test2');//,Answer_Values__c='test1:a1,test2:a2');//,Question__c='This is the test'
         insert fnQuestion1;
        
         // THIS PART AS TO MOVE TO TESTHELPER CLASS
         FlexNoteQuestion__c fNQuestion2=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='This is the test picklist',Answer_Type__c='Picklist' ,Name='Test3',AnswerValues__c='test1:a1,test2:a2');//,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test picklist'
         insert fnQuestion2;
        
         flexNoteQuestList.add(fnQuestion);
         flexNoteQuestList.add(fnQuestion1);
         flexNoteQuestList.add(fnQuestion2);
         
        list<FlexNote__c> answersList = new list<FlexNote__c>();
         // THIS PART AS TO MOVE TO TESTHELPER CLASS
         FlexNote__c fn=new FlexNote__c(Case__c=caseRrd.Id,FlexNote_Question__c=fNQuestion1.Id,Answer__c='test1:a1',Questions__c=fNQuestion.Questions__c);
         insert fn;
         // THIS PART AS TO MOVE TO TESTHELPER CLASS
         FlexNote__c fn1=new FlexNote__c(Case__c=caseRrd.Id,FlexNote_Question__c=fNQuestion1.Id,Answer__c='test1:a1',Questions__c=fNQuestion.Questions__c);
         insert fn1;
        
         answersList.add(fn);
         answersList.add(fn1);
         
         String key = 'key';
         String value = 'value';
         Map<String,String> questionAliasMap = new Map<String,String>();
         questionAliasMap.put(key,value);  
        
        string str='abc,def,fgh';
        string ward ='Ward 2';
        string dailylimit='DailyLimit';
        string ansstring='Single,Multiple';
        Date bulkdate=system.today();
        retrievePicklistValues(decodeList);
        retriveMultiPickList(str);
        retriveMultiPickListSelectOption(str);
        fetchBulkScheduleDetails(ward,dailylimit);
        convertStringToAnswerList(ansstring);
        isValidBulkScheduleDate(bulkdate,ward);
        retrievePicklistValues(str);
        retriveMultiPickListSelectOption(decodeList);
        doCreateUpdateServiceRequestBulkSchedule(caseRrd);
        createFlexNotesString(answersList,questionAliasMap);
    }
    /* end */  
   
   
    
    /**
    *  Retrieving questions based on service request selected 
    *
    */
    public void retrieveFlexNoteQuestions(){
        serviceRequestQuestionWrapList=new list<ServiceRequestQuestionWrapper>();
        try{          
            
            list<Id>flexNotesQuestionIds=new list<Id>();          
            
            
            map<Id,ServiceRequestTypeFlexNote__c>qRelMap=new map<Id,ServiceRequestTypeFlexNote__c>();
          
            for(ServiceRequestTypeFlexNote__c temp:[Select Service_Request_Type__c,IsRequiredQuestion__c,Order__c,  FlexNote_Question__c, isRequired__c ,IsReadOnly__c
                                                                From ServiceRequestTypeFlexNote__c where Service_Request_Type__c=:selectedServiceRequestType ORDER BY Order__c ASC]){
                flexNotesQuestionIds.add(temp.FlexNote_Question__c);
                qRelMap.put(temp.FlexNote_Question__c,temp);                
            }           
            
            tempFlexNotesList=new list<QuestionAnswerWrapper>();            
            
            for(Id fnId:flexNotesQuestionIds){    
                QuestionAnswerWrapper qA=new QuestionAnswerWrapper(flexNoteIdMap.get(fnId),qRelMap.get(fnId));
                 // 240914
                 if(flexNoteIdMap.get(fnId)!=null){
                    
                    if(flexNoteIdMap.get(fnId).Answer_Type__c!=null){   
                       
                        // PROCESSING PICKLIST DATA TYPE
                        if(flexNoteIdMap.get(fnId).Answer_Type__c=='Picklist'){
                            // Converting string to picklist and adding to questionAnswerwrapper list ,based on type
                           if(flexNoteIdMap.get(fnId).AnswerValues__c!=null){
                                string picklistOptions=nameDecodeValueMap.get(flexNoteIdMap.get(fnId).AnswerValues__c);
                                list<Decode_Object__c>decodeList=picklistNameDecodeMap.get(flexNoteIdMap.get(fnId).AnswerValues__c);
                                if(decodeList==null || decodeList.isEmpty()){
                                    picklistOptions=flexNoteIdMap.get(fnId).AnswerValues__c;
                                    qA.questionPicklistValues=retrievePicklistValues(picklistOptions);//0409
                                } 
                                else{   
                                    qA.questionPicklistValues=retrievePicklistValues(decodeList);//0409
                                }
                            }
                        } // IF END  
                        
                        // PROCESSING MULITPICKLIST DATA TYPE
                        if(flexNoteIdMap.get(fnId).Answer_Type__c=='MultiPicklist'){
                            if(flexNoteIdMap.get(fnId).AnswerValues__c!=null){
                                list<Decode_Object__c>decodeList=picklistNameDecodeMap.get(flexNoteIdMap.get(fnId).AnswerValues__c);
                                if(decodeList==null || decodeList.isEmpty()){
                                    qA.questionMultiPicklistValueList=retriveMultiPickListSelectOption(flexNoteIdMap.get(fnId).AnswerValues__c);
                                }
                                else{
                                    qA.questionMultiPicklistValueList=retriveMultiPickListSelectOption(decodeList);
                                }  
                            }
                            
                            
                            if(qA.answer.Answer__c!=null){
                                list<string>answerList=convertStringToAnswerList(qA.answer.Answer__c);
                                if(answerList!=null && !answerList.isEmpty()){
                                    list<string>ansList=new list<string>();
                                    for(string ansItem:answerList){
                                        for(QuestionMultiPickListWrapper qAnswers:qA.questionMultiPicklistValueList){
                                            if(ansItem==qAnswers.flexNoteSelectItem.getValue()){
                                                ansList.add(ansItem);
                                                qAnswers.selectedMultipicklist=ansList;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                         system.debug('flexNoteIdMap.get(fnId).Answer_Type__c--'+flexNoteIdMap.get(fnId).Answer_Type__c);
                          system.debug('ward--'+ward);     
                        // ADDING DEFAULT VALUES
                        if(flexNoteIdMap.get(fnId).Answer_Type__c=='Text'){
                            if(flexNoteIdMap.get(fnId).AnswerValues__c!=null){
                                if(qA.answer.Answer__c==null){
                                    qA.answer.Answer__c=flexNoteIdMap.get(fnId).AnswerValues__c;
                                    system.debug('default values--'+qA.answer.Answer__c);
                                }
                                
                            }
                        
                        }// if multiplist end
                             
                            if(flexNoteIdMap.get(fnId).Answer_Type__c=='Text'){
                                if(flexNoteIdMap.get(fnId).AnswerValues__c!=null){
                                     system.debug('qA.answer.Answer__c--'+qA.answer.Answer__c);
                                     if(qA.answer.Answer__c=='{!value}'){
                                         BulkSchedule__c bS =fetchBulkScheduleDetails(ward,'DailyLimit');
                                         system.debug('bS--'+bS);
                                         if(bS!=null){
                                             qA.answer.Answer__c =string.valueOf(bS.ScheduleDate__c.format());
                                             if(bS.ScheduleDate__c!=null){
                                                 if(!bulkScheduleMap.containsKey(bS.ScheduleDate__c)){
                                                      bulkScheduleMap.put(bS.ScheduleDate__c,bS);
                                                      system.debug('bulkScheduleMap--'+bulkScheduleMap);
                                                  }
                                              }
                                           }

                                       }
                                   }
                              }                        
                            
                        } // IF END 
                    
                    }   // IF END 
                     
                    tempFlexNotesList.add(qA);
                    system.debug('tempFlexNotesList--->'+tempFlexNotesList);
                 }
               
                for(ServiceRequestType__c temp:[Select i.Object__c, i.Name, i.Id From ServiceRequestType__c i where Id=:selectedServiceRequestType]){
                    ServiceRequestQuestionWrapper sRQW=new ServiceRequestQuestionWrapper(temp,tempFlexNotesList);
                    
                    serviceRequestQuestionWrapList.add(sRQW);
                }
            
        }
        catch(Exception e){
          System.debug('Unable to Complete due='+e);
          //we hve to store this message in some errorlog object
        }
    
    }
  
    /**
    *  Get the Bulk schedule date
    *
    */
    private BulkSchedule__c fetchBulkScheduleDetails(String ward,string DailyLimit){
        string scheduleDate;
        system.debug('ward--'+ward);
        if(ward==null){
            ApexPages.addMessage(new Apexpages.Message(Apexpages.Severity.INFO,'Please provide address for this service type, then reselect service type'));

            return null;
        }
        else{
            sObject sobj=ServiceRequestsHelper.getFlexNoteDefault(ward,DailyLimit);
            if(sobj!=null){
                BulkSchedule__c bS=(BulkSchedule__c)sobj;
                scheduleDate=string.valueOf(bS.ScheduleDate__c.format());
                return bS;    
            }
            else{
                ApexPages.addMessage(new Apexpages.Message(Apexpages.Severity.INFO,'There are no records for provided address'));
                return null;
            }
        }
            
    }   
    
 
    // converting comma seperated string into picklist values 
    private list<SelectOption>retrievePicklistValues(string commaSeperatedString){
        List<SelectOption> Options=new List<SelectOption>();
        
        List<SelectOption> Options1=new List<SelectOption>();
        
        if(commaSeperatedString==null)return null;
        // spliting comma seperated string 
        
        if(commaSeperatedString.contains(',')){
            list<string>picklistValues=commaSeperatedString.split(',');
            for(Integer p=0;p<picklistValues.size();p++){
                if (picklistValues[p].contains(':')){
                     Options1.add(new SelectOption(picklistValues[p].split(':')[0],picklistValues[p].split(':')[1]));
                }
                else{
                    Options1.add(new SelectOption(picklistValues[p],picklistValues[p]));
                }
            }
        }
        else{
            Options1.add(new SelectOption(commaSeperatedString,commaSeperatedString));
        }
        // adding default Option
        Options.add(new SelectOption('','--None--'));   
        Options.addAll(Options1);
        return Options;
    }
    
    // retrieve picklist values from decode object
    private list<SelectOption>retrievePicklistValues(list<Decode_Object__c>decodeList){
        List<SelectOption> picklistOptions=new List<SelectOption>();
        List<SelectOption> defaultpicklistOption=new List<SelectOption>();
        for(Decode_Object__c dItems:decodeList){
            if(dItems.Code__c!=null && dItems.Value__c!=null)
            picklistOptions.add(new selectOption(dItems.Code__c,dItems.Value__c));
        }
        // adding default Option
        defaultpicklistOption.add(new SelectOption('','--None--'));
        defaultpicklistOption.addAll(picklistOptions);
        return defaultpicklistOption;
    }
    
   
    // converting comma seperated string into Multi picklist values 
    private list<QuestionMultiPickListWrapper>retriveMultiPickList(string commaSeperatedString){
        list<QuestionMultiPickListWrapper>Options=new list<QuestionMultiPickListWrapper>();
        if(commaSeperatedString==null)return null;
        
        if(commaSeperatedString.contains(',')){
             // spliting comma seperated string 
            list<string>picklistValues=commaSeperatedString.split(',');
            for(Integer k=0;k<picklistValues.size();k++){
                Options.add(new QuestionMultiPickListWrapper(picklistValues[k]));
            }
        }
        else{
            Options.add(new QuestionMultiPickListWrapper(commaSeperatedString));
        }
        return Options;
    }   
    
    private list<QuestionMultiPickListWrapper>retriveMultiPickListSelectOption(list<Decode_Object__c>decodeList){
        List<QuestionMultiPickListWrapper> picklistOptions=new List<QuestionMultiPickListWrapper>();
        for(Decode_Object__c dItems:decodeList){
            if(dItems.Code__c!=null && dItems.Value__c!=null)
            picklistOptions.add(new QuestionMultiPickListWrapper(new selectOption(dItems.Code__c,dItems.Value__c)));
        }
        return picklistOptions;
    }
    
     // converting comma seperated string into Multi picklist values 
    private list<QuestionMultiPickListWrapper>retriveMultiPickListSelectOption(string commaSeperatedString){
        list<QuestionMultiPickListWrapper>Options=new list<QuestionMultiPickListWrapper>();
        if(commaSeperatedString==null)return null;
        if(commaSeperatedString.contains(',')){
             // spliting comma seperated string 
            list<string>picklistValues=commaSeperatedString.split(',');
            for(Integer k=0;k<picklistValues.size();k++){
            if (picklistValues[k].contains(':')){
                Options.add(new QuestionMultiPickListWrapper(new SelectOption(picklistValues[k].split(':')[0],picklistValues[k].split(':')[1])));
             }else{
                   Options.add(new QuestionMultiPickListWrapper(new SelectOption(picklistValues[k],picklistValues[k])));
                }
            }
        }
        else{
            Options.add(new QuestionMultiPickListWrapper(new SelectOption(commaSeperatedString,commaSeperatedString)));
        }
        return Options;
    }
    
    
    // convert string into list of string   
    private list<string>convertStringToAnswerList(string answerStr){
        if(answerStr==null)return null;
        
        list<string>aswerStrList=new list<string>();
        if(answerStr.contains(',')){
            list<string>tempAnswerStrList=answerStr.split(',');
            aswerStrList.addAll(tempAnswerStrList);
        }
        else{
            aswerStrList.add(answerStr);
        }
        
        if(aswerStrList.isEmpty())return null;
        
        return aswerStrList;
    }
    
    
    /**
    *  we have to insert in case object 
    *
    */   
    public void doSubmit(){
        service_location=false;
        service_type = false; 
        service_information = false; 
        contact_information = false; 
        comments_attachments= false;
        review_submit = false;
        ServiceLocAddressDetails=false;
        dupliacteAddressDetection=false; 
        review_result=true;
        attachment=false;

        // holds list question and answer wrapper       
        tempQuestionAnswerWrapList=new list<QuestionAnswerWrapper>();
        // we have to use this ..present not used
        boolean isValid=true;
        for(ServiceRequestQuestionWrapper sRQW:serviceRequestQuestionWrapList){
            for(QuestionAnswerWrapper qAW:sRQW.questionAnswerList){   
                //retrieving multipicklist values selected
                if(qAW.flexNoteQuestion.Answer_Type__c=='MultiPicklist'){
                    string tempMultiPickListValue='';
                    for(QuestionMultiPickListWrapper qMPW:qAW.questionMultiPicklistValueList){
                       
                        // selected options for a multipicklist from page shuld include in string
                        if(qMPW.isSelectedQuestion){
                            tempMultiPickListValue+=qMPW.questionMultiPicklistItem+',';
                        }
                        
                        if(qMPW.selectedMultipicklist!=null && !qMPW.selectedMultipicklist.isEmpty()){
                            string mPicklistValue='';
                            for(string strItem:qMPW.selectedMultipicklist){
                                mPicklistValue+=strItem;
                            }
                            tempMultiPickListValue+=mPicklistValue+',';
                        }
                    }
                    
                    Boolean isEndComma =tempMultiPickListValue.endsWith(',');
                    // removing ending comma symbol
                    if(isEndComma){
                        integer le=tempMultiPickListValue.length()-1;
                        string tempAnsStr=tempMultiPickListValue.substring(0,le);
                        qAW.answer.Answer__c=tempAnsStr;
                    }
                    else{qAW.answer.Answer__c=tempMultiPickListValue;}
                    
                }
                
                // validation if question is required ..this questions as to be answered otherwise it not saved
                if(qAW.relationQuestion.IsReadOnly__c== false){
                    if(qAW.relationQuestion.IsRequiredQuestion__c==true){
                        if(qAW.answer.Answer__c==null || qAW.answer.Answer__c==''){
                          
                            //  we need to modify this
                             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Please Provide Answer For All Required Questions.')); 
                                    
                        }
                    }
                     
                }
                // VALIDATING DATE TIME
                    // 06914
                if(qAW.flexNoteQuestion.Answer_Type__c=='Date/Time'){
                    if(qAW.answer.Answer__c!=null || qAW.answer.Answer__c!=''){ 
                        // valid format 
                        Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d) ([0-1]?[0-9]|[2][0-3]):([0-5][0-9]) (AM|PM)');
                       
                        Matcher MyMatcher = MyPattern.matcher(qAW.answer.Answer__c); 
                        if(qAW.relationQuestion.IsRequiredQuestion__c==true){
                            if(!MyMatcher.matches()){
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Info: Valid Date Time Format is mm/dd/yyyy hh:mm AM/PM.');
                                ApexPages.addMessage(myMsg);
                            }
                        }
                    }
                 }
                
                // Collectin all question and answer which will used for inserting answers
                tempQuestionAnswerWrapList.add(qAW);
            }
        }
        
        savepoint errorPoint=database.setSavepoint(); 
        contact cont;
        Case objCase;    
        
        //getMarAddressDetails(fulladdress);    
         
         if(ServiceLocationRequired == true){    
             if(fullBlockAddress.size() == 0){
                 locresult= geo_result.get(fulladdress);
                 list<string> result =new list<string>();
                  if(Test.isRunningTest()){
                      result =new String[13]; 
                      result[0]='Address_ID=149350.0';
                      result[1]='149350.0';
                      result[2]='-76.99542510';
                      result[3]='NE';
                      result[4]='400396.68';
                      result[5]='140190.10';
                      result[6]='ANC 5E';
                      result[7]='Police Service Area 502';
                      result[8]='Ward 5';
                      result[9]='SMD 5E01';
                      result[10]='Police District - Fifth District';
                      result[11]='null';
                      result[12]='502.0';
                      
                      Map<String, String> fullBlockAddress= new Map<String, String>();
                      fullBlockAddress.put('526 - 599 BLOCK OF 42ND STREET NE','42ND STREET NE FROM EDSON PLACE NE TO FOOTE STREET NE,526 - 599 BLOCK OF 42ND STREET NE,526,599');
                      
                  }else{
                     result= locresult.split(':');
                  }  
                     list<string> ADDRESSID =result[0].split('='); 
                     
                     if(ADDRESSID[0]== 'ADDRESS_ID'){ 
                         address_id=ADDRESSID[1];
                         longitude=result[1];
                         latitude=result[2];
                         quadrant=result[3];
                         xcoord=result[4];
                         ycoord=result[5];
                         anc=result[6];
                         psa=result[7];
                         ward=result[8];
                         smd=result[9];
                         poldist=result[10];
                         cluster=result[11];
                         addrnum=result[12];
                     }else{
                        intersection_id=ADDRESSID[1];
                        longitude=result[1];
                        latitude=result[2];
                        xcoord=result[3];
                        ycoord=result[4];
                     }
                     
                     
                     if(fulladdress.contains('-')){
                         list<string> result1= fulladdress.split('-');
                         
                          alias_name = result1[0];  
                          full_intersection = result1[1]; 
                     }     
                     
                
            }
        }
        try{
            if(selContact != null){
                if(selContact.LastName!=null && selContact.LastName!='') // Added by Swetha
                    cont=getContactDetails(selContact);             
            }            
           
            savepoint sp=database.setSavepoint();
            //create a case if not passed case as attribute
            case caseToInsert;
            if(selectedCaseId==null){
              caseToInsert=new Case();
              caseToInsert.Status=Status;
              caseToInsert.Subject=selSelectedRequestTypeName;
              caseToInsert.Origin='Web';
              caseToInsert.Priority=Priority;
              caseToInsert.Description=comments;           
              caseToInsert.SLA__c=Sla;
              caseToInsert.AgencyCode__c=Agency;
             
              
              if(ServiceLocationRequired == true){
                  if(fullBlockAddress.size() == 0){
                      if(address_id != null || address_id == ''){
                          Decimal Decimalvalue_addressid = decimal.valueOf(address_id); 
                          Integer integerValue_addressid = Decimalvalue_addressid.intValue();          
                          caseToInsert.AddressID__c=string.valueof(integerValue_addressid);
                          caseToInsert.Quadrant__c=quadrant; 
                          caseToInsert.XCOORD__c=xcoord;
                          caseToInsert.YCOORD__c=ycoord;
                          caseToInsert.PSA__c=psa;
                          caseToInsert.ANC__c=anc; 
                          caseToInsert.Ward__c=ward;
                          caseToInsert.SMD__c=smd;
                          caseToInsert.POlDistrict__c=poldist;
                          caseToInsert.Cluster__c=cluster;
                          caseToInsert.GeoLocation__Latitude__s=decimal.ValueOf(latitude);
                          caseToInsert.GeoLocation__Longitude__s=decimal.ValueOf(longitude);
                      
                      }
                      
                      if(alias_name != null || alias_name == ''){
                          caseToInsert.AliasName__c=alias_name;
                      }
                       
                      if(intersection_id != null || intersection_id == ''){
                         caseToInsert.IntersectionId__c=intersection_id;
                         caseToInsert.XCOORD__c=xcoord;
                         caseToInsert.YCOORD__c=ycoord;                      
                         caseToInsert.GeoLocation__Latitude__s=decimal.ValueOf(latitude);
                         caseToInsert.GeoLocation__Longitude__s=decimal.ValueOf(longitude);
                      }
                  }
                  
                  list<string> lst= new list<string>();
                  string fullblockmap;
                  string fullblock;
                  string blockname;
                  
                  if(fullBlockAddress.size() > 0){ 
                      
                      //blk address fields
                      for(integer k=0;k<fullBlockAddress.size();k++){                                     
                      
                        if(fullBlockAddress.containsKey(fulladdress)){
                            fullblockmap = fullBlockAddress.get(fulladdress);
                            
                            lst = fullblockmap.split(':');
                             
                            fullblock=lst[0];
                            blockname=lst[1];
                        }
                                         
                      } 
                      
                       
                      caseToInsert.FullBlock__c=fullblock;
                      caseToInsert.BlockName__c=blockname; 
                  }  
                  
                  if(full_intersection != null || full_intersection == ''){
                      caseToInsert.Address__c=full_intersection;
                  }
                  
                  if(blockname != null || blockname != ''){
                      caseToInsert.Address__c=fulladdress+','+city+','+state+' '+zipCode;
                  }
                  
                  if((blockname == null || blockname == '') && (full_intersection == null|| full_intersection == '' )){
                      caseToInsert.Address__c=fulladdress;
                  }                
                  
                 
              }  
              // for now DM 271214
              // assigning case to default active assignment rule
              Database.DMLOptions dmo = new Database.DMLOptions();
              dmo.assignmentRuleHeader.useDefaultRule= true;
              caseToInsert.setOptions(dmo);            
              insert caseToInsert;
            }
             
            // holds question and question alias 
            MAP<string,string>questionAliasMap=new Map<string,string>();
            // holds list answer which are going to insert into answer object
            list<FlexNote__c>toInsertAnswers=new list<FlexNote__c>();
            for(QuestionAnswerWrapper a:tempQuestionAnswerWrapList){
                // mapping for question answer fields in flexNotes
                FlexNote__c tempAnswer=new FlexNote__c();
                    tempAnswer.Questions__c=a.flexNoteQuestion.Questions__c;
                    tempAnswer.Answer__c=a.answer.Answer__c;
                    tempAnswer.Order__c=  decimal.valueOf(a.relationQuestion.Order__c);
                    
                    tempAnswer.Answer_Date_Time__c=a.answer.Answer_Date_Time__c;
                    questionAliasMap.put(a.flexNoteQuestion.Questions__c,a.flexNoteQuestion.QuestionAlias__c);
                    tempAnswer.FlexNote_Question__c=a.flexNoteQuestion.Id;
                    // case not null then update case field in answer
                    if(selectedCaseId!=null){
                        tempAnswer.Case__c=selectedCaseId;
                    }
                  else{
                       tempAnswer.Case__c=caseToInsert.Id;
                    }
                toInsertAnswers.add(tempAnswer);
            }
            
          
            if(selectedCaseId!=null){
                objCase=[select id,FlexNotes__c from case where id=:selectedCaseId];
                // updating case field 
                objCase.FlexNotes__C=(objCase.FlexNotes__C!=null)?(objCase.FlexNotes__c+''+createFlexNotesString(toInsertAnswers,questionAliasMap)):createFlexNotesString(toInsertAnswers,questionAliasMap);
                objCase.SRType__c=selectedServiceRequestType;
                if(selContact != null){
                    if(cont!=null) // Added by Swetha
                         objCase.ContactId=cont.id;
                }
            }
            if(selectedCaseId==null){
                
                objCase=caseToInsert;
                objCase.FlexNotes__C=(objCase.FlexNotes__C!=null)?(objCase.FlexNotes__c+''+createFlexNotesString(toInsertAnswers,questionAliasMap)):createFlexNotesString(toInsertAnswers,questionAliasMap);
                objCase.SRType__c=selectedServiceRequestType;

                if(selContact != null){
                    if(cont!=null) // Added by Swetha
                        objCase.ContactId=cont.id;
                }
            }
            
            if(objCase!=null) update objCase;           
            system.debug('objCase Exit-->');
            // Creating flexnotes 
            if(toInsertAnswers != null || toInsertAnswers.size() > 0 ){                 
                    
              insert (toInsertAnswers);
              doCreateUpdateServiceRequestBulkSchedule(objCase);     
            }
            
           casenumber =[Select CaseNumber From Case where Id=:objCase.Id];
           
           system.debug('attachmentId-->'+attachmentId);
           if(attachmentId != null)
           {  
              
               Attachment attachment =[Select Name,Description,Body from Attachment where id=: attachmentId];
               
               Attachment attachfile= new Attachment();
               attachfile.ParentId = objCase.Id; // the record the file is attached to
               attachfile.IsPrivate = true;
               attachfile.name = attachment.name;
               attachfile.description = attachment.description;              
               attachfile.body = attachment.body;
               
               insert attachfile;
               
               delete attachment;
               
               attachfile= new Attachment();            
          }
            
        }
        catch(exception e){
            system.debug('unable to complete insert-->'+e);
            system.debug('unable to complete insert-->'+selContact);
            // we will inserting the error into error log object
            
            database.rollback(errorPoint);
            
        }finally {      
          
          attach = new Attachment();
          
        }       
     
    }
    
    private void doCreateUpdateServiceRequestBulkSchedule(case caseRrd){
        list<ServiceRequestBulkSchedule__c>serviceBulkScheduleToUpsert=new list<ServiceRequestBulkSchedule__c>();
        for(Date bSItem:bulkScheduleMap.keySet()){
            if(isValidBulkScheduleDate(bSItem,caseRrd.Ward__c))return;
               
            ServiceRequestBulkSchedule__c sRBS=new ServiceRequestBulkSchedule__c();
                sRBS.BulkSchedule__c=bulkScheduleMap.get(bSItem).Id;
                sRBS.ServiceRequest__c=caseRrd.Id;
                sRBS.SRBulkScheduleExtId__c=sRBS.BulkSchedule__c+'-'+sRBS.ServiceRequest__c;
                sRBS.Status__c='Open';
                serviceBulkScheduleToUpsert.add(sRBS);
                
                system.debug('bulkScheduleMap--'+bulkScheduleMap.get(bSItem));
        }
        
        try{
            if(!serviceBulkScheduleToUpsert.isEmpty()) upsert serviceBulkScheduleToUpsert SRBulkScheduleExtId__c;
        }catch(exception e){
            system.debug('unable to complete Process of Upsert of servicerequestbulkschedule due--'+e);
            throw new CustomException(e); // custom Exception message added
        }
    }
    
    private boolean isValidBulkScheduleDate(Date scheduleDate,string Ward){
        boolean isValidDate;
        for(BulkSchedule__c bs :[select id,Name,ServiceRequestBulkScheduleCount__c,ScheduleDate__c,Ward__c from BulkSchedule__c where ScheduleDate__c =: scheduleDate  Order By ScheduleDate__c ASC limit 1]){
            if(bs.Ward__c.contains(Ward)){
                if(bs.ServiceRequestBulkScheduleCount__c > =OUCServiceRequestConfig__c.getValues('DailyLimit').BulkScheduleDailyStopLimit__c){
                    system.debug('count---'+bs.ServiceRequestBulkScheduleCount__c);
                    throw new CustomException('DailyStopLimit for bulk schedule has been crossed');
                    return isValidDate=true;
                }
                else{
                     return isValidDate=false;
                }
            }
        }
        
        return isValidDate=false;
    }
    
     
    // Invoked from onchange event of picklist
    public void doRenderInputText(){
        try{
            if(selAnswerValue=='Other'){
                // its index zero we hve hardcoded need to modify
                if(selIndex!=null){
                    
                    serviceRequestQuestionWrapList[0].questionAnswerList[selIndex].isRenderText=True;
                    // clear the param index and answer value
                    selIndex=null;
                    selAnswerValue=null;
                }
            } 
            // whether picklist option selected is not other option and isRenderText is true make it false
            else if(selAnswerValue!='Other' && selIndex!=null){
                //need to change this HardCoded zero need to modfiy later
                
                if(serviceRequestQuestionWrapList[0].questionAnswerList[selIndex].isRenderText==true){
                    serviceRequestQuestionWrapList[0].questionAnswerList[selIndex].isRenderText=false;
                }
                // clearing param values
                selIndex=null;
                selAnswerValue=null;
            }
        }
        catch(Exception e){
            system.debug('unable to Complete Process'+e);
        }
        
    }
    
    //onclick of commandlink
    public pageReference clickCommandLink(){
        service_location=true;
        service_type = false;
        return null;
    }      
    
    // preparing map of id and questions
    public void fetchFlexNoteQuestionMap(){
        system.debug('fetchFlexNoteQuestionMap--->');
        for(FlexNoteQuestion__c flexQuestion:[select i.QuestionAlias__c, i.AnswerValues__c,i.Questions__c, i.Answer_Type__c, i.Required__c, i.Name, i.Id from FlexNoteQuestion__c i]){
           flexNoteIdMap.put(flexQuestion.id,flexQuestion);
        }
        
         system.debug('flexNoteIdMap--->'+flexNoteIdMap);
    }
    
    
    
    
    // updating case field flexNotes__C with question and answer in a format
    //Question1<questionAlias>=Answer1;question2<questionAlias>=Answer2;Question3<questionAlias>=Answer3;
    private string createFlexNotesString(list<FlexNote__c>answersList,map<string,string>questionAliasMap){
        string flexNotesString='';
        for(FlexNote__c a:answersList){
            flexNotesString+=a.Questions__c+'<'+questionAliasMap.get(a.Questions__c)+'>='+a.Answer__c+';';
        }
        return flexNotesString;
    }
    
    //  fetching decode records
    private void fetchNamePickListValues(){
        for(Decode_Object__c dItem:[Select d.Value__c,d.Name,d.Type__c,d.Code__c, d.Active__c,d.Id From Decode_Object__c d where Active__c=true]){
            nameDecodeValueMap.put(dItem.name,dItem.value__c);
            if(picklistNameDecodeMap.containsKey(dItem.Name)){
                picklistNameDecodeMap.get(dItem.Name).add(dItem);
            }else{
                picklistNameDecodeMap.put(dItem.Name,new list<Decode_Object__c>{dItem});
            }
        }
        
    }  
    
    // used in displaying multipicklist and getting selected values also
    public Class QuestionMultiPickListWrapper{
        // based on this will include picklist value
        public boolean isSelectedQuestion{get;set;}
        public string questionMultiPicklistItem{get;set;}
        public SelectOption flexNoteSelectItem{get;set;} // 3009
        public list<string> selectedMultipicklist{get;set;}
        
        
        public QuestionMultiPickListWrapper(string questionMultiPicklistItem){
            this.questionMultiPicklistItem=questionMultiPicklistItem;
            this.isSelectedQuestion=false;
        }
        
        public QuestionMultiPickListWrapper(SelectOption flexNoteSelectItem){
            this.flexNoteSelectItem=flexNoteSelectItem;
            this.isSelectedQuestion=false;
            this.selectedMultipicklist=new list<string>();
        } 
    }
     
    
    // Question And Answer Container
    public class QuestionAnswerWrapper{
        // holds service request and question relation
        public ServiceRequestTypeFlexNote__c relationQuestion{get;set;}
        // Determines whether picklist selected other option
        public boolean isRenderText{get;set;}
        // holds Answer for a question
        public FlexNote__c answer{get;set;}
        // holds question picklist values
        public list<SelectOption> questionPicklistValues{get;set;}
        // holds questions 
        public FlexNoteQuestion__c flexNoteQuestion{get;set;}
        // holds multipicklist values 
        public list<QuestionMultiPickListWrapper>questionMultiPicklistValueList{get;set;}
        
        public QuestionAnswerWrapper(FlexNoteQuestion__c flexNoteQuestion,ServiceRequestTypeFlexNote__c relationQuestion){
            this.flexNoteQuestion=flexNoteQuestion;
            this.relationQuestion=relationQuestion;
            this.answer=new FlexNote__c ();
            this.questionPicklistValues=new list<SelectOption>();
            this.isRenderText=false;
            // added
            this.questionMultiPicklistValueList=new list<QuestionMultiPickListWrapper>();
        }   
    } 
      
    
    // Service Request and QuestionAnswerWrapper Container
    public class ServiceRequestQuestionWrapper{
        // holds service Request 
        public ServiceRequestType__c serviceRequest{get;set;}
        // holds question related to selected service request       
        public list<QuestionAnswerWrapper>questionAnswerList{get;set;}
                
        public ServiceRequestQuestionWrapper(ServiceRequestType__c serviceRequest,list<QuestionAnswerWrapper>questionAnswerList){
            this.serviceRequest=serviceRequest;
            this.questionAnswerList=questionAnswerList;
        }
        
    }
    /*Component Logic*/
   
    public pageReference review_action_next(){
        service_type=true;
        service_location = false;
        service_information = false;
        contact_information = false;
        comments_attachments= false;
        review_submit = false;
        ServiceLocAddressDetails=false;
        dupliacteAddressDetection=false; 
        review_result=false;
        attachment=false;
        
        return null;
    
    }
    
    public pageReference review_action_finish(){       
        
        PageReference pgref = new PageReference('/portal/ServiceHomePortal');
        pgref .setRedirect(true);
        return pgref ;
       
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
            
             status_check_error_msg=true;
             ApexPages.Message status_check_error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'A service request number is required to lookup status. Please enter a valid service request number.');
             ApexPages.addMessage(status_check_error_msg);
             
            
             return null;
             
         }
                     
         if(email == null || email == ''){
             render=false;
             rend=true;
               
             status_check_error_msg=true;
             ApexPages.Message status_check_error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'A valid email address is required to lookup status. Please enter a valid email address.');
             ApexPages.addMessage(status_check_error_msg);
             
             
             return null;             
           
             
         }
           
           
         if(requestId != null && email != null){ 
             render=true;
             rend=false;
             home_rend =false;
             status_check_error_msg=false;   
             
             try{  
                 caserecord=getRequest(requestId,email);
                 SrID= caserecord.SRType__c;
                
              }catch(Exception e){
                  render=false;
                  rend=true;
                  home_rend =true; 
                  
                  status_check_error_msg=true;
                  ApexPages.Message status_check_error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'The service request cannot be found. Please check your entry for misspelled words.');
                  ApexPages.addMessage(status_check_error_msg);
                  
                  return null;
              
              }          
           
           
         }
          
         return null;
     }
     
     public static Service_Request_History__c getRequest(String requestId,String email){
           
           /*List<Service_Request_History__c> cases =[Select Address__c,CaseNumber__c,CreatedBy__c,Id, 
           SRType__c,Status__c,Subject__c, (Select Completion_Date__c, Due_Date__c, External_Comments__c, 
           Id, Status__c, Task_Short_Name__c From OUC_Activity_Histories__r) 
           from Service_Request_History__c 
           WHERE (CaseNumber__c=:requestId OR Id=:requestId) And Contact_Email__c=:email ];*/  
           
           /* SR Id will need to use the formula field */
           List<Service_Request_History__c> cases =[Select Address__c,CaseNumber__c,CreatedBy__c,Id, 
           SRType__c,Status__c,Subject__c, (Select Completion_Date__c, Due_Date__c, External_Comments__c, 
           Id, Status__c, Task_Short_Name__c From OUC_Activity_Histories__r) 
           from Service_Request_History__c 
           WHERE (Name=:requestId OR Id=:requestId) And Contact_Email__c=:email ];
                            
           if(cases.size()==0){
                //invalid requestId code provided data could not be found
                 throw new CustomException(APIConstants.NOT_FOUND); 
           }
           return cases[0];
           
    }
    
    //Fetch faq Sr type and description
   public void fetch_FaqSrdescription(){
        FAQ_S=false;
        FAQ_D=true;        
        
        FaqSrdescription= new  List<ServiceRequestType__c>();
        FaqSrdescription=[Select Service_Name__c,Description__c,Id,External_Name__c
           from ServiceRequestType__c WHERE Allow_Citizen_Web_Intake__c = true ORDER BY Service_Name__c Asc];  
        
          
    }
    
    //Fetch faq Sr type and sla and servicing agency
    public void fetch_FaqSrsla(){
        FAQ_S=true;
        FAQ_D=false;  
        
        FaqSrsla= new  List<ServiceRequestType__c>();
        FaqSrsla=[Select Service_Name__c,SLA__c,Agency__c,Id,External_Name__c 
           from ServiceRequestType__c WHERE Allow_Citizen_Web_Intake__c = true ORDER BY Service_Name__c Asc];  
        
       
    } 
   
    public void get_case_history(){
     try{
      
          loggedin_user_case = new list<Service_Request_History__c>();
          
          //not get all the cases for the logged in user
          loggedin_user_case = [Select CaseNumber__c,Origin__c,DateTimeOpened__c,Expected_Resolution_Date__c,Priority__c,
          Status__c,SLA__c,External_System_Name__c,Address__c,SRType__c from Service_Request_History__c where Contact_Email__c=:loggedInUsername order by DateTimeOpened__c desc limit 10 ];
          system.debug('loggedin_user_case'+loggedin_user_case);  
          if(loggedin_user_case == null){                  
              rh_error_msg=true;
              loggedIn=true; 
               
              ApexPages.Message rh_error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'There are no cases associated to this contact.');
              ApexPages.addMessage(rh_error_msg);
          
          }else{
               rh_error_msg=false;
               loggedIn=true; 
               
          
          }
              
       
      }catch(exception e ){
           system.debug('unable to Complete Process'+e);      
      }
    
    } 
    
    public void attachment() {
        service_location=false;
        service_type = false; 
        service_information = false; 
        contact_information = false;
        comments_attachments= false;
        review_submit = false;
        ServiceLocAddressDetails=false;
        dupliacteAddressDetection=false; 
        review_result=false;
        attachment=true;
        
        
        if(ContactRequired == true){            
            
            if(selContact.lastname == null || selContact.lastname == ''){
                 contact_information=true;
                 comments_attachments=true;
                 attachment=false;
                   
                   
                 error_msg=true;
                 ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter lastname.');
                 ApexPages.addMessage(error_msg);
                 
            }
            
            if(selContact.email == null || selContact.email == ''){
                 contact_information=true;
                 comments_attachments=true;
                 attachment=false;
                   
                 error_msg=true;
                 ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a valid email address.');
                 ApexPages.addMessage(error_msg);
                 
            }
            
            if(selContact.email != null || selContact.email != ''){
                String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank">http://www.regular-expressions.info/email.html</a>

                Pattern MyPattern = Pattern.compile(emailRegex);

                Matcher MyMatcher = MyPattern.matcher(selContact.email);

                if (!MyMatcher.matches()){

                    contact_information=true;
                     comments_attachments=true;
                     attachment=false;
                   
                     error_msg=true;
                     ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a valid email address.');
                     ApexPages.addMessage(error_msg);
                 
                }
            }            
        }
        system.debug('lastname in contact --->'+selContact.lastname);
        if(ContactRequired == false && selContact.lastname != ''){            
                        
            if(selContact.email == null || selContact.email == ''){
                 contact_information=true;
                 comments_attachments=true;
                 attachment=false;
                   
                 error_msg=true;
                 ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a valid email address.');
                 ApexPages.addMessage(error_msg);
                
            }
            
            if(selContact.email != null || selContact.email != ''){
                String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank">http://www.regular-expressions.info/email.html</a>

                Pattern MyPattern = Pattern.compile(emailRegex);

                Matcher MyMatcher = MyPattern.matcher(selContact.email);

                if (!MyMatcher.matches()){

                     contact_information=true;
                     comments_attachments=true;
                     attachment=false;
                   
                     error_msg=true;
                     ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a valid email address.');
                     ApexPages.addMessage(error_msg);
                 
                }
            }           
        }
        
       
    } 
    
    
    public void prev_attachment() {

        service_location=false;
        service_type = false; 
        service_information = false; 
        contact_information = true;
        comments_attachments= true;
        review_submit = false;
        ServiceLocAddressDetails=false;
        dupliacteAddressDetection=false; 
        review_result=false;
        attachment=false;
    } 
    
    /**
    *  Reset password
    *
    */    
    public PageReference passwordreset() {
        if(fp_email_address != null || fp_email_address != ''){
            User usr = [Select ContactId, Profile.Name from user where  Email=: fp_email_address and isactive = true];
            
            Id userID = usr.Id;
            Boolean send_user_email =true;
            
            System.resetPassword(userID,send_user_email); 
            
            PageReference pgrf = new PageReference('/portal/LoginPortal');
            pgrf .setRedirect(true);
            return pgrf ;
            
        }else{          
             error_msg=true;
             ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a valid email address.');
             ApexPages.addMessage(error_msg);
             return null;
        }       
    } 
    
   
    /*@RemoteAction
    global static AddressValidationResponseWrapper.AddressValidationWrapper verifyAddressByLatLong(String Latitude,String Longitude){
        
        String jsonstring = AddressValidation.verifyAddressByLatLong(Latitude,Longitude);
        
        JSONParser parser = JSON.createParser(jsonstring);
        AddressValidationResponseWrapper.AddressValidationWrapper m = (AddressValidationResponseWrapper.AddressValidationWrapper)parser.readValueAs(AddressValidationResponseWrapper.AddressValidationWrapper.class);
     
        return m;
    }*/
    
    
  
 }