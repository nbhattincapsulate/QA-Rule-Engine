public with sharing class ServiceRequestController{    
    
    public string CaseId{ get; set;}
    public Boolean service_type { get; set; }
    public Boolean service_location{ get; set; }
    public Boolean service_information { get; set; }
    public Boolean contact_information{ get; set; }
    public Boolean comments_attachments { get; set; }
    public Boolean review_submit{ get; set; }
    public Boolean ServiceLocAddressDetails { get; set; }
    public Boolean review_result{ get; set; }
    public Boolean title{ get; set; }
    public Boolean error_msg{ get; set; }
    public Boolean information { get; set; }
    public string jstring{ get; set; }
    
    public Integer length{ get; set; }
    public string  JurdId{ get; set; }
    public string  Sla{ get; set; }
    public string  Agency{ get; set; }
    public string  Origin{ get; set; }
    public string  Priority{ get; set; }
    public string  Status{ get; set; }
    
    //title
    public string step1{ get; set;}
    public string step2{ get; set;}
    public string step3{ get; set;}
    public string step4{ get; set;}
    public string step5{ get; set;}
    public string step6{ get; set;}
    public string title_name{ get; set;}
     
    public Case casenumber { get; set; }
   // used to store the keyword string
    public string searchstring{ get; set;}
    public string searchstr{ get; set;}
    
    public boolean ServiceLocationRequired { get; set;}
    public boolean ContactRequired { get; set;}
    public ID JurisdictionId{ get; set;}
    
    //holdes question and answers
    public list<QuestionAnswerWrapper> tempQuestionAnswerWrapList{ get; set;}
    public list<QuestionAnswerWrapper> tempFlexNotesList{ get; set;}
   
    public List<ServiceRequestType__c> searchList { get; set;}
    
    //options service type list for keyword search
    public  List<SelectOption> options1 = new List<SelectOption>();
    
    //options service type list for dropdown 
    public  List<SelectOption> options = new List<SelectOption>(); 
    
    //holds the list of service loc address coming from mar 
    public  List<String> result{ get; set;}
    public  List<String> geoRes{ get; set;}
    
    public Map<String,String> geo_result{get; set;}  
             
   
    public string ser_type{get; set;} 
    
    //holds service loc address as a complete string
    //public string fulladdress{get{system.debug('fulladdress in get---->'+fulladdress);if(seladressloc !=null){system.debug('xxxxxxxx');fulladdress=seladressloc ;}else{fulladdress=fulladdress;} return fulladdress; }set;}
    public string fulladdress{get{system.debug('fulladdress in get---->'+fulladdress); return fulladdress; }set;}
    
    //stores the service location address
    public string street{get{system.debug('street---->'+street); return street;} set;}    
    public string city{get{system.debug('city---->'+city); return city;} set;}    
    public string state{get{system.debug('state---->'+state); return state;} set;}    
    public string zipCode{get{system.debug('zipcode---->'+zipcode); return zipcode;} set;}
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
    
    // used in displaying selectedRequestTypeName in all tabs
    public string selSelectedRequestTypeName{ get; set;}
    
    //holds comments value
     public string  comments{ get{system.debug('comments---->'+comments); return comments;} set;}
     
     public string commentvalue{ get{system.debug('commentvalue---->'+commentvalue); return commentvalue;} set;}
     
    // holds contact details passed in contact info
    public Contact selContact{ get; set;} 
    
    public string seladressloc { get{system.debug('seladressloc  in get------>'+seladressloc );return seladressloc ;} set;} 

    // holds location informations
    //public serviceLocationWrap selServiceLocation{get{system.debug('selServiceLocation---->'+selServiceLocation); return selServiceLocation ;}set;}
    private map<Id,FlexNoteQuestion__c>flexNoteIdMap=new map<Id,FlexNoteQuestion__c>();
    public ServiceRequestController(){
        // preparing map of id and questions
        fetchFlexNoteQuestionMap();
        
        service_type=true;
        service_location = false;
        service_information = false;
        contact_information = false;
        comments_attachments = false;
        review_submit = false;
        ServiceLocAddressDetails=false;
        review_result=false;
        title=true;        
        error_msg=false;
        
        step1='Select Service Type';
         
        selContact=new Contact();
        //selContact.MailingCity = 'WASHINGTON';
        //selContact.MailingState = 'DC';
        //selServiceLocation=new serviceLocationWrap();
        //selServiceLocation.city='WASHINGTON';
        //selServiceLocation.state='DC';       
        city ='WASHINGTON';
        state='DC';
        
        
      
    }
    
    public string serviceType;
    public string selectedServiceType{get;set;}
        
    // getting all service types 
    public List<SelectOption> getServiceRequestItems() { 
        
        List<SelectOption> tempOptions = new List<SelectOption>();
        
        if(options1.size() != 0 ){           
           
            return options1;
        
        }else{
        
            // we only concentrating on case object template
            for(ServiceRequestType__c temp:[Select i.Object__c, i.Name, i.Id,i.Service_Name__c,i.Description__c  From ServiceRequestType__c i where Object__c='Case' AND Allow_Citizen_Web_Intake__c = true ORDER BY Service_Name__c Asc]){
                  /*if (tempOptions.size()>1000)
                      continue;*/
                      tempOptions.add(new SelectOption(temp.Id,temp.Service_Name__c));  
                      //Avoid Salesforce limit of collection suze 1000  - MNB
                 

            }            
            
            options1.clear();
            //default option
            options.add(new SelectOption('','Please Select'));    
            
            options.addAll(tempOptions);
           
            return options;
        }
    }
    
    public String getServiceType() {
        return serviceType;
    }
    
    public void setServiceType(String serviceType) {
        this.serviceType = serviceType;
    }
    
    public void performAction(){         
        service_information = false; 
        contact_information = false; 
        comments_attachments = false; 
        review_submit = false; 
        ServiceLocAddressDetails=false;
        review_result=false;         
        title=true;
        
        step2='Service Location';   
        
        if(serviceType!=null || serviceType!=''){
            for(ServiceRequestType__c srtype :[SELECT ServiceLocationRequired__c , ContactRequired__c,Jurisdiction__c,SLA__c,Agency__c,Default_Method__c,Default_Priority__c,Default_Status__c from ServiceRequestType__c where Id =: serviceType ]){
                   system.debug('srtype ------------->'+srtype );
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
                service_type = true;
                
            }else{
               service_location=false;
               service_type = false; 
                      
                service_information = true; 
                contact_information = true; 
                comments_attachments = true; 
                information= true;
                
                title=true;
        
                step3='Service Information';
                Step4='Contact Information'; 
                step5='Comments And Attachments';                  
           
            }
            
            system.debug('serviceType-----------> '+ serviceType);
            selectedServiceType=serviceType;
            selectedServiceRequestType=serviceType;
            
            // getting name based on passed service TYpe
            selSelectedRequestTypeName=getSelServiceRequestTypeName(serviceType);
            // calling component method to retrieve all flex note questions 
            retrieveFlexNoteQuestions();
        }
        
        if(serviceType == null || serviceType == ''){
            service_location=false;
            service_type = true;  
        
        }      
    }
    
    public void servicetype(){
        service_location=true;
        service_type = false;

        system.debug('ser_type--->'+ser_type);
        /* 
        service_location=true;
        service_type = false; 
        service_information = false; 
        contact_information = false; 
        comments_attachments = false; 
        review_submit = false;    
       
        
        if(ser_type!=null || ser_type!=''){
            system.debug('serType-----------> '+ ser_type);
            selectedServiceType=ser_type;
            selectedServiceRequestType=ser_type;
            
            // getting name based on passed service TYpe
            selSelectedRequestTypeName=getSelServiceRequestTypeName(ser_type);
            // calling component method to retrieve all flex note questions 
            retrieveFlexNoteQuestions();
        }*/
    }
    
    public void service_location(){

          
        contact_information = false; 
        comments_attachments = false; 
        review_submit = false; 
        review_result=false;
        title=true;
        
        step2='Service Location';   
        
        //system.debug('selServiceLocation--->'+selServiceLocation);  
        
       //String StreetAddress= ApexPages.currentPage().getParameters().get('StreetAddress');
        //system.debug('StreetAddress---->'+StreetAddress); 
        
        fulladdress= street+','+city+','+state+' '+zipcode;
        //system.debug('service_locationfulladdress--->'+fulladdress);
        //string address= selServiceLocation.street;
        //system.debug('address--->'+address); 
        if(street == null || street ==''){
            service_information = false; 
            service_location=true;  
            ServiceLocAddressDetails = false; 
            service_type=true;
            error_msg=true;
            ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a street address.');
            ApexPages.addMessage(error_msg); 
        
        }else{ 
            //String jsonstring ='{"returnCodes":null,"details":"<STRONG>Normalized:</STRONG> 753 JACKSON PLACE NORTHWEST</br><STRONG>Parsed:</STRONG></br><EM>Address Number: </EM>753</br><EM>Address Number Suffix: </EM></br><EM>Street Name: </EM>JACKSON</br><EM>Street Type: </EM>PLACE</br><EM>Quad: </EM>NW</br><STRONG>Possible Standard Street Names: </STRONG></br>JACKSON</br>","returnDataset":{"Table1":[{"ADDRESS_ID":279883.0,"STATUS":"ACTIVE","FULLADDRESS":"700 JACKSON PLACE NW","ADDRNUM":700.0,"ADDRNUMSUFFIX":null,"STNAME":"JACKSON","STREET_TYPE":"PLACE","QUADRANT":"NW","CITY":"WASHINGTON","STATE":"DC","XCOORD":396683.33,"YCOORD":136793.01,"SSL":"0167    0048","ANC":"ANC 2B","PSA":"Police Service Area 207","WARD":"Ward 2","NBHD_ACTION":" ","CLUSTER_":"Cluster 6","POLDIST":"Police District - Second District","ROC":"-","CENSUS_TRACT":"010700","VOTE_PRCNCT":"Precinct 17","SMD":"SMD 2B05","ZIPCODE":20006.0,"NATIONALGRID":"18S UJ 23247 07541","ROADWAYSEGID":3616.0,"FOCUS_IMPROVEMENT_AREA":null,"HAS_ALIAS":"N","HAS_CONDO_UNIT":"N","HAS_RES_UNIT":"N","HAS_SSL":"Y","LATITUDE":38.89898252,"LONGITUDE":-77.03823467,"STREETVIEWURL":null,"RES_TYPE":"NON RESIDENTIAL","WARD_2002":"Ward 2","WARD_2012":"Ward 2","ANC_2002":"ANC 2B","ANC_2012":"ANC 2B","SMD_2002":"SMD 2B05","SMD_2012":"SMD 2B05","IMAGEURL":"http://citizenatlas.dc.gov/mobilevideo","IMAGEDIR":"20041030","IMAGENAME":"EU104216.jpg","ConfidenceLevel":77.5},{"ADDRESS_ID":218718.0,"STATUS":"ACTIVE","FULLADDRESS":"704 JACKSON PLACE NW","ADDRNUM":704.0,"ADDRNUMSUFFIX":null,"STNAME":"JACKSON","STREET_TYPE":"PLACE","QUADRANT":"NW","CITY":"WASHINGTON","STATE":"DC","XCOORD":396684.75,"YCOORD":136800.21,"SSL":"0167    0815","ANC":"ANC 2B","PSA":"Police Service Area 207","WARD":"Ward 2","NBHD_ACTION":" ","CLUSTER_":"Cluster 6","POLDIST":"Police District - Second District","ROC":"-","CENSUS_TRACT":"010700","VOTE_PRCNCT":"Precinct 17","SMD":"SMD 2B05","ZIPCODE":20006.0,"NATIONALGRID":"18S UJ 23249 07548","ROADWAYSEGID":3616.0,"FOCUS_IMPROVEMENT_AREA":null,"HAS_ALIAS":"N","HAS_CONDO_UNIT":"N","HAS_RES_UNIT":"N","HAS_SSL":"Y","LATITUDE":38.89904738,"LONGITUDE":-77.03821833,"STREETVIEWURL":null,"RES_TYPE":"NON RESIDENTIAL","WARD_2002":"Ward 2","WARD_2012":"Ward 2","ANC_2002":"ANC 2B","ANC_2012":"ANC 2B","SMD_2002":"SMD 2B05","SMD_2012":"SMD 2B05","IMAGEURL":"http://citizenatlas.dc.gov/mobilevideo","IMAGEDIR":"20041030","IMAGENAME":"EU104209.jpg","ConfidenceLevel":77.5}]}}';     
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
            system.debug('jsonstring --->'+jsonstring );
            string newjsonstring = jsonstring.replace('"CLUSTER_":', '"CLUSTER":');
            system.debug('newjsonstring--->'+newjsonstring);
            JSONParser parser = JSON.createParser(newjsonstring);
            system.debug('parser --->'+parser );
            AddressValidationResponseWrapper.AddressValidationWrapper m = (AddressValidationResponseWrapper.AddressValidationWrapper)parser.readValueAs(AddressValidationResponseWrapper.AddressValidationWrapper.class);
            System.debug('returndataset'+ m.returnDataset);
            
            AddressValidationResponseWrapper.returnDatasetWrapper check_data_in_returnDataset=m.returnDataset;
            
            List<AddressValidationResponseWrapper.TableWrapper> check_data_in_table= new List<AddressValidationResponseWrapper.TableWrapper>();
            
            system.debug('check_data_in_returnDataset--->'+check_data_in_returnDataset);
            if(check_data_in_returnDataset !=null){
                error_msg=false;
            
                check_data_in_table=m.returnDataset.Table1;
                length=check_data_in_table.size();
                system.debug('length---->'+length);
            
            }else{ 
                  error_msg=true;
                  service_type = true;     
                  service_information = false; 
                  service_location=true;  
                  ServiceLocAddressDetails = false;
                 
                            
                  ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Service is not provided for this location.');
                  ApexPages.addMessage(error_msg);
                  
            }
            
            result = new List<String>(); 
            geoRes= new List<String>();        
            
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
                       if(check_data_in_table[i].FULLADDRESS == null){
                           result.add(street+','+check_data_in_table[i].CITY+','+check_data_in_table[i].STATE+' '+Integer.valueOf(check_data_in_table[i].ZIPCODE));                                    
                       
                       }
                       
                       if(check_data_in_table[i].FULLADDRESS != null && check_data_in_table[i].CITY != null && check_data_in_table[i].STATE != null && check_data_in_table[i].ZIPCODE != null){
                           result.add(check_data_in_table[i].FULLADDRESS+','+check_data_in_table[i].CITY+','+check_data_in_table[i].STATE+' '+Integer.valueOf(check_data_in_table[i].ZIPCODE));                                    
                       
                       }
                       
                       if(check_data_in_table[i].FULLADDRESS == null && check_data_in_table[i].CITY == null && check_data_in_table[i].STATE == null && check_data_in_table[i].ZIPCODE == null){
                           result.add(check_data_in_table[i].FULLINTERSECTION);                                   
                       
                       }
                       
                       if(check_data_in_table[i].ALIASNAME != null && check_data_in_table[i].FULLADDRESS != null && check_data_in_table[i].CITY != null && check_data_in_table[i].STATE != null && check_data_in_table[i].ZIPCODE != null){
                           result.add(check_data_in_table[i].ALIASNAME+'-'+check_data_in_table[i].FULLADDRESS+','+check_data_in_table[i].CITY+','+check_data_in_table[i].STATE+' '+Integer.valueOf(check_data_in_table[i].ZIPCODE));                                    
                       
                       }
                                            
    
                      if(check_data_in_table[i].ADDRESS_ID != null){
                         geoRes.add('Address_ID'+'='+check_data_in_table[i].ADDRESS_ID+':'+check_data_in_table[i].LONGITUDE+':'+check_data_in_table[i].LATITUDE+':'+check_data_in_table[i].QUADRANT+':'+check_data_in_table[i].XCOORD+':'+check_data_in_table[i].YCOORD+':'+check_data_in_table[i].ANC+':'+check_data_in_table[i].PSA+':'+check_data_in_table[i].WARD+':'+check_data_in_table[i].SMD+':'+check_data_in_table[i].POLDIST+':'+check_data_in_table[i].CLUSTER);
                      }else{
                         geoRes.add('INTERSECTIONID'+'='+check_data_in_table[i].INTERSECTIONID+':'+check_data_in_table[i].LONGITUDE+':'+check_data_in_table[i].LATITUDE+':'+check_data_in_table[i].QUADRANT+':'+check_data_in_table[i].XCOORD+':'+check_data_in_table[i].YCOORD+':'+check_data_in_table[i].ANC+':'+check_data_in_table[i].PSA+':'+check_data_in_table[i].WARD+':'+check_data_in_table[i].SMD+':'+check_data_in_table[i].POLDIST+':'+check_data_in_table[i].CLUSTER);
                      }
                       system.debug('result------->'+result);
                       system.debug('geoRes------->'+geoRes);
                       system.debug('geo_result------->'+ geo_result);
                       
                       
                   }
                   
                   for(integer j=0;j<result.size();j++){
                       for(integer k=0;k<geoRes.size();k++){                     
                           geo_result.put(result[j],geoRes[k]);                   
                       }              
                   
                   }
                   
                   system.debug('geo------->'+geo_result);
                  
               } 
               
               if(length == 1){
                   ServiceLocAddressDetails = false;
                   service_location=false; 
                   service_information = true;
                   contact_information = true;
                   comments_attachments = true; 
                   information = true;
                   service_type = false; 
                   
                   step3='Service Information';
                   Step4='Contact Information'; 
                   step5='Comments And Attachments';
                   step6='Review And Submit';    
                   
                   geo_result= new Map<String,String>();  
                 
                   for(integer i=0;i<length;i++){ 
                       if(check_data_in_table[i].FULLADDRESS == null){                           
                           result.add(street+','+check_data_in_table[i].CITY+','+check_data_in_table[i].STATE+' '+Integer.valueOf(check_data_in_table[i].ZIPCODE));                                    
                           fulladdress='';
                           fulladdress=street+','+check_data_in_table[i].CITY+','+check_data_in_table[i].STATE+' '+Integer.valueOf(check_data_in_table[i].ZIPCODE);
                       }
                        
                       if(check_data_in_table[i].FULLADDRESS != null && check_data_in_table[i].CITY != null && check_data_in_table[i].STATE != null && check_data_in_table[i].ZIPCODE != null){
                           result.add(check_data_in_table[i].FULLADDRESS+','+check_data_in_table[i].CITY+','+check_data_in_table[i].STATE+' '+Integer.valueOf(check_data_in_table[i].ZIPCODE)); 
                           fulladdress='';
                           fulladdress=check_data_in_table[i].FULLADDRESS+','+check_data_in_table[i].CITY+','+check_data_in_table[i].STATE+' '+Integer.valueOf(check_data_in_table[i].ZIPCODE);                                   
                       
                       }
                       
                       if(check_data_in_table[i].FULLADDRESS == null && check_data_in_table[i].CITY == null && check_data_in_table[i].STATE == null && check_data_in_table[i].ZIPCODE == null){
                           result.add(check_data_in_table[i].FULLINTERSECTION);                                   
                           fulladdress='';
                           fulladdress=check_data_in_table[i].FULLINTERSECTION;                                   
                       }
                       
                       if(check_data_in_table[i].ALIASNAME != null && check_data_in_table[i].FULLADDRESS != null && check_data_in_table[i].CITY != null && check_data_in_table[i].STATE != null && check_data_in_table[i].ZIPCODE != null){
                           result.add(check_data_in_table[i].ALIASNAME+'-'+check_data_in_table[i].FULLADDRESS+','+check_data_in_table[i].CITY+','+check_data_in_table[i].STATE+' '+Integer.valueOf(check_data_in_table[i].ZIPCODE));                                    
                           fulladdress='';
                           fulladdress=check_data_in_table[i].ALIASNAME+'-'+check_data_in_table[i].FULLADDRESS+','+check_data_in_table[i].CITY+','+check_data_in_table[i].STATE+' '+Integer.valueOf(check_data_in_table[i].ZIPCODE);     
                       }
                                            
    
                      if(check_data_in_table[i].ADDRESS_ID != null){
                         geoRes.add('Address_ID'+'='+check_data_in_table[i].ADDRESS_ID+':'+check_data_in_table[i].LONGITUDE+':'+check_data_in_table[i].LATITUDE+':'+check_data_in_table[i].QUADRANT+':'+check_data_in_table[i].XCOORD+':'+check_data_in_table[i].YCOORD+':'+check_data_in_table[i].ANC+':'+check_data_in_table[i].PSA+':'+check_data_in_table[i].WARD+':'+check_data_in_table[i].SMD+':'+check_data_in_table[i].POLDIST+':'+check_data_in_table[i].CLUSTER);
                      }else{
                         geoRes.add('INTERSECTIONID'+'='+check_data_in_table[i].INTERSECTIONID+':'+check_data_in_table[i].LONGITUDE+':'+check_data_in_table[i].LATITUDE+':'+check_data_in_table[i].QUADRANT+':'+check_data_in_table[i].XCOORD+':'+check_data_in_table[i].YCOORD+':'+check_data_in_table[i].ANC+':'+check_data_in_table[i].PSA+':'+check_data_in_table[i].WARD+':'+check_data_in_table[i].SMD+':'+check_data_in_table[i].POLDIST+':'+check_data_in_table[i].CLUSTER);
                      }
                       system.debug('result------->'+result);
                       system.debug('geoRes------->'+geoRes);
                       
                       
                   }
                   
                   for(integer j=0;j<result.size();j++){
                       for(integer k=0;k<geoRes.size();k++){                     
                           geo_result.put(result[j],geoRes[k]);                   
                       }              
                   
                   }
                   
                   system.debug('geo------->'+geo_result);
               
               }        
    
               
            }        
        
            if(check_data_in_table ==null || check_data_in_table.isEmpty()){
                  service_information = false; 
                  service_location=true;  
                  ServiceLocAddressDetails = false; 
                  service_type=true;
                  error_msg=true;

                  ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Service is not provided for this location.');
                  ApexPages.addMessage(error_msg);  
                  
                  system.debug('else--->'+service_location);           
               
            } 
        }        
      
        
    }
    
    Public Pagereference selectedlocationlist(){
        service_type=true;
        service_location = false;
        service_information = false;
        contact_information = false;
        comments_attachments = false;
        review_submit = false;
        ServiceLocAddressDetails=true;
        review_result=false;
        title=true;

        
        step2='Service Location';   
        
        
        //fulladdress = null;
        //seladressloc = System.currentPagereference().getParameters().get('conid');
        
        //fulladdress='';
        fulladdress=seladressloc ;
        //system.debug('seladressloc  in selectedlocationlist---->'+seladressloc );
        //system.debug('fulladdress---->'+fulladdress);
       
      
        /*street=seladressloc.substringBefore(',');
        system.debug('street---->'+street);
       
        zipcode= seladressloc.substringAfterLast(' ');
        system.debug('zipcode---->'+zipcode);*/
      
        //selServiceLocation=new serviceLocationWrap();
       
        //selServiceLocation.street=street;
        //selServiceLocation.pinCode=Integer.ValueOf(zipcode);
        //selServiceLocation.city='WASHINGTON';
        //selServiceLocation.state='DC';
        
       // fulladdress= street+','+'WASHINGTON'+','+'DC'+' '+Integer.ValueOf(zipcode);
        
        //system.debug('service_locationfulladdress--->'+fulladdress);
        
        //system.debug('selServiceLocation value--->'+selServiceLocation);
        
        return null;
    
    }
  
    public void service_info(){       
        
        if(seladressloc == null || seladressloc == ''){
            service_type=true;
            ServiceLocAddressDetails = true; 
            ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select Service Location.');
            ApexPages.addMessage(error_msg);
        
        }else{
            service_location=false;
            service_type = false; 
            service_information = true; 
            contact_information = true; 
            comments_attachments = true; 
            information = true;
            review_submit = false;
            ServiceLocAddressDetails=false;
            review_result=false; 
            title=true;
            
            step3='Service Information';
            Step4='Contact Information'; 
            step5='Comments And Attachments';
            step6='Review And Submit';  
        
        }
        
        system.debug('seladressloc  in service_info---->'+seladressloc );
        system.debug('fulladdressservice_info--->'+fulladdress);  
    }
    
    public void contact_info(){
        service_location=false;
        service_type = false; 
        service_information = false; 
        contact_information = true; 
        comments_attachments = false; 
        review_submit = false; 
        ServiceLocAddressDetails=false;
        review_result=false;
        title=true;

        
        Step4='Contact Information';   
    }
    
    public void comment_attachement(){
        service_location=false;
        service_type = false; 
        service_information = false; 
        contact_information = false; 
        comments_attachments = true; 
        review_submit = false;
        ServiceLocAddressDetails=false;
        review_result=false;
        title=true;

        
        step5='Comments And Attachments';   
         system.debug('ContactInfo--->'+selContact);   
    }
    
    public void review_submit(){
        service_location=false;
        service_type = false; 
        service_information = false; 
        contact_information = false; 
        comments_attachments = false; 
        information=false; 
        review_submit = true;        
        ServiceLocAddressDetails=false;
        review_result=false;
        title=true;

        //selContact=new Contact();
        step6='Review And Submit';   
        system.debug('ContactInfo--->'+selContact);         
        
        // holds list question and answer wrapper       
        tempQuestionAnswerWrapList=new list<QuestionAnswerWrapper>();
        
        // we have to use this ..present not used
        boolean isValid=true;
        for(ServiceRequestQuestionWrapper sRQW:serviceRequestQuestionWrapList){
            system.debug('sRQW--->'+sRQW.questionAnswerList);
            for(QuestionAnswerWrapper qAW:sRQW.questionAnswerList){   
                system.debug('qAW--->'+qAW);         
                //retrieving multipicklist values selected
                if(qAW.flexNoteQuestion.Answer_Type__c=='MultiPicklist'){
                    string tempMultiPickListValue='';
                    for(QuestionMultiPickListWrapper qMPW:qAW.questionMultiPicklistValueList){
                        // selected options for a multipicklist from page shuld include in string
                        if(qMPW.isSelectedQuestion){
                            tempMultiPickListValue+=qMPW.questionMultiPicklistItem+',';
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
                if(qAW.relationQuestion.IsRequiredQuestion__c==true){
                    if(qAW.answer.Answer__c==null || qAW.answer.Answer__c==''){
                        service_information = true; 
                        contact_information = true; 
                        comments_attachments = true;
                        information=true; 
                        review_submit = false;
                        //  we need to modify this                 
                        ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Provide Answer For All Required Questions.');
                        ApexPages.addMessage(error_msg);
                        // isValid=false;
                        //return null;            
                    }
                     
                }
                
                 // VALIDATING DATE TIME
                    // 06914
                if(qAW.flexNoteQuestion.Answer_Type__c=='Date/Time'){
                    if(qAW.answer.Answer__c!=null || qAW.answer.Answer__c!=''){ 
                        
                        // valid format 
                        system.debug('Test--DateTime'+qAW.flexNoteQuestion.Answer_Type__c);
                        Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d) ([0-1]?[0-9]|[2][0-3]):([0-5][0-9]) (AM|PM)');
                       
                        Matcher MyMatcher = MyPattern.matcher(qAW.answer.Answer__c); 
                        system.debug('matches--'+MyMatcher.matches());
                        
                        if(!MyMatcher.matches()){
                             service_information = true; 
                            contact_information = true; 
                            comments_attachments = true;
                            information=true; 
                            review_submit = false;
                        
                            ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.Error,'Info: Valid Date Time Format is mm/dd/yyyy hh:mm AM/PM.');
                            ApexPages.addMessage(error_msg);
                            //return ;
                        }
                    }
                 }
                 
                  // VALIDATING DATE TIME
                    // 06914
                if(qAW.flexNoteQuestion.Answer_Type__c=='Date'){
                    if(qAW.answer.Answer__c!=null || qAW.answer.Answer__c!=''){ 
                        
                        // valid format 
                        system.debug('Test--DateTime'+qAW.flexNoteQuestion.Answer_Type__c);
                        Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)');
                       
                        Matcher MyMatcher = MyPattern.matcher(qAW.answer.Answer__c); 
                        system.debug('matches--'+MyMatcher.matches());
                        
                        if(!MyMatcher.matches()){
                             service_information = true; 
                            contact_information = true; 
                            comments_attachments = true;
                            information=true; 
                            review_submit = false;
                        
                            ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.Error,'Info: Valid Date Format is mm/dd/yyyy.');
                            ApexPages.addMessage(error_msg);
                            //return ;
                        }
                    }
                 }
                
                // Collectin all question and answer which will used for inserting answers
                tempQuestionAnswerWrapList.add(qAW);
            }
        }
    }
    
     public void Previous_service_location(){
       service_location=false;
       service_type = false; 
       service_information = true; 
       contact_information = true; 
       comments_attachments = true; 
       review_submit = false;
       information = true;      
       
         //system.debug('selServiceLocation--->'+selServiceLocation);  
   }
   
   public void Previous_service_location1(){
       service_location=false;       
       service_type = true; 
       service_information = false; 
       contact_information = false; 
       comments_attachments = false; 
       review_submit = false;
       information = false;
      
       
         //system.debug('selServiceLocation--->'+selServiceLocation);  
   }
   
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
                    system.debug('tempOptions size---->');
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
            system.debug('searchList1 ------------>'+searchList);         
            return searchList;
        
        }else{          
         
           searchList=[Select Object__c, Name,Id,Service_Name__c,Description__c  From ServiceRequestType__c  where Object__c='Case']; 
           system.debug('searchList ------------>'+searchList ); 
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
 
    
    // retriving ServiceRequestType__c name record based on selId passed 
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
   public Class serviceLocationWrap{
        public string street{get;set;}
        public string city{get;set;}
        public string state{get;set;}
        public string country{get;set;}
        public integer pinCode{get;set;}
        
        public serviceLocationWrap(){}
   }
   
   // retrieving contact information 
    private contact getContactDetails(contact con){
        if(con==null)return null;
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
   
       //holds case Record Id
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
   
   
    
    // retrieving questions based on service request selected 
    public void retrieveFlexNoteQuestions(){
        serviceRequestQuestionWrapList=new list<ServiceRequestQuestionWrapper>();
        try{
            
            /*            
            if(selectedCaseId==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'CaseId Attribute Not Defined.'));
                return;
            }
            */
            
            // if selected service request null return nothing
            if(selectedServiceRequestType==null && selectedServiceRequestType!='None'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'ServiceRequestType  not defined.'));
                return;
            }
            
            list<Id>flexNotesQuestionIds=new list<Id>();          
            
            
            map<Id,ServiceRequestTypeFlexNote__c>qRelMap=new map<Id,ServiceRequestTypeFlexNote__c>();
            
            for(ServiceRequestTypeFlexNote__c temp:[Select Service_Request_Type__c,IsRequiredQuestion__c,Order__c,  FlexNote_Question__c, isRequired__c 
                                                                From ServiceRequestTypeFlexNote__c where Service_Request_Type__c=:selectedServiceRequestType ORDER BY Order__c ASC]){
                flexNotesQuestionIds.add(temp.FlexNote_Question__c);
                qRelMap.put(temp.FlexNote_Question__c,temp);                
            }           
            
            tempFlexNotesList=new list<QuestionAnswerWrapper>(); 
           // for(FlexNoteQuestion__c tempflexNoteQuest:[Select i.QuestionAlias__c, i.AnswerValues__c,i.Questions__c, i.Answer_Type__c, i.Required__c, i.Name, i.Id From FlexNoteQuestion__c i where id IN:flexNotesQuestionIds]){
            for(Id fnId:flexNotesQuestionIds){    
                QuestionAnswerWrapper qA=new QuestionAnswerWrapper(flexNoteIdMap.get(fnId),qRelMap.get(fnId));
                 // 240914
                 if(flexNoteIdMap.get(fnId)!=null){
                    if(flexNoteIdMap.get(fnId).Answer_Type__c!=null){   
                        if(flexNoteIdMap.get(fnId).Answer_Type__c=='Picklist'){
                        // Converting string to picklist and adding to questionAnswerwrapper list ,based on type
                            qA.questionPicklistValues=retrievePicklistValues(flexNoteIdMap.get(fnId).AnswerValues__c);
                        }
                        
                        if(flexNoteIdMap.get(fnId).Answer_Type__c=='MultiPicklist'){
                            qA.questionMultiPicklistValueList=retriveMultiPickList(flexNoteIdMap.get(fnId).AnswerValues__c);
                        }
                    }
                 }
                
                tempFlexNotesList.add(qA);
                system.debug('questionanswer-->'+tempFlexNotesList);
            } 
            
            
            
            if(tempFlexNotesList.isEmpty() && selectedServiceRequestType!='None'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'There Are No Flex Notes Defined For a given Service Request Type .'));
                return ;
            }
            
            for(ServiceRequestType__c temp:[Select i.Object__c, i.Name, i.Id From ServiceRequestType__c i where Id=:selectedServiceRequestType]){
                ServiceRequestQuestionWrapper sRQW=new ServiceRequestQuestionWrapper(temp,tempFlexNotesList);
                
                serviceRequestQuestionWrapList.add(sRQW);
                system.debug('list of service request and flexnotes to be displayed--'+serviceRequestQuestionWrapList);
            }
            
            if(serviceRequestQuestionWrapList.isEmpty() && selectedServiceRequestType!='None'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Please Select a Valid Service Request Type.'));
                return ;
            }
        }
        catch(Exception e)
        {
          System.debug('Unable to Complete due='+e);
          //we hve to store this message in some errorlog object
        }
    
    }
  /*      
    // converting comma seperated string into picklist values 
   private list<SelectOption>retrievePicklistValues(string commaSeperatedString){
       List<SelectOption> Options=new List<SelectOption>();
       
       List<SelectOption> Options1=new List<SelectOption>();
       system.debug('commaSeperatedString---'+commaSeperatedString);
        // spliting comma seperated string 
       list<string>picklistValues=commaSeperatedString.split(',');
        
       for(Integer p=0;p<picklistValues.size();p++){
           
           if (picklistValues[p].contains(':'))
                Options1.add(new SelectOption(picklistValues[p].split(':')[0],picklistValues[p].split(':')[1]));
           else
               Options1.add(new SelectOption(picklistValues[p],picklistValues[p]));
       }
       // adding default Option
       Options.add(new SelectOption('','-None-'));   
       Options.addAll(Options1);
       system.debug('Options--->'+Options);
       return Options;
   }
   
   */
   
       // converting comma seperated string into picklist values 
    @TestVisible private list<SelectOption>retrievePicklistValues(string commaSeperatedString){
        List<SelectOption> Options=new List<SelectOption>();
        
        List<SelectOption> Options1=new List<SelectOption>();
        
        if(commaSeperatedString==null)return null;
        system.debug('commaSeperatedString---'+commaSeperatedString);
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
        system.debug('Options--->'+Options);
        return Options;
    }
   /*
    // converting comma seperated string into Multi picklist values 
    private list<QuestionMultiPickListWrapper>retriveMultiPickList(string commaSeperatedString){
        list<QuestionMultiPickListWrapper>Options=new list<QuestionMultiPickListWrapper>();
        // spliting comma seperated string 
        list<string>picklistValues=commaSeperatedString.split(',');
        for(Integer k=0;k<picklistValues.size();k++){
            Options.add(new QuestionMultiPickListWrapper(picklistValues[k]));
            
        }
        return Options;
    }
    
    */
        // converting comma seperated string into Multi picklist values 
    @TestVisible private list<QuestionMultiPickListWrapper>retriveMultiPickList(string commaSeperatedString){
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
    
    // invoked from submit button from component page
    // we have to insert in case object 
    public void doSubmit(){
        service_location=false;
        service_type = false; 
        service_information = false; 
        contact_information = false; 
        comments_attachments = false; 
        review_submit = false;
        ServiceLocAddressDetails=false;
        review_result=true;

        
        // system.debug('selContact info--->'+selContact);
        
        system.debug('serviceRequestQuestionWrapList--->'+serviceRequestQuestionWrapList);
        
        // holds list question and answer wrapper       
        tempQuestionAnswerWrapList=new list<QuestionAnswerWrapper>();
        // we have to use this ..present not used
        boolean isValid=true;
        for(ServiceRequestQuestionWrapper sRQW:serviceRequestQuestionWrapList){
            system.debug('sRQW--->'+sRQW.questionAnswerList);
            for(QuestionAnswerWrapper qAW:sRQW.questionAnswerList){   
                system.debug('qAW--->'+qAW);         
                //retrieving multipicklist values selected
                if(qAW.flexNoteQuestion.Answer_Type__c=='MultiPicklist'){
                    string tempMultiPickListValue='';
                    for(QuestionMultiPickListWrapper qMPW:qAW.questionMultiPicklistValueList){
                        // selected options for a multipicklist from page shuld include in string
                        if(qMPW.isSelectedQuestion){
                            tempMultiPickListValue+=qMPW.questionMultiPicklistItem+',';
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
                if(qAW.relationQuestion.IsRequiredQuestion__c==true){
                    if(qAW.answer.Answer__c==null || qAW.answer.Answer__c==''){
                      
                        //  we need to modify this
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Please Provide Answer For All Required Questions.')); 
                        // isValid=false;
                        //return null;            
                    }
                     
                }
                // VALIDATING DATE TIME
                    // 06914
                if(qAW.flexNoteQuestion.Answer_Type__c=='Date/Time'){
                    if(qAW.answer.Answer__c!=null || qAW.answer.Answer__c!=''){ 
                        // valid format 
                        system.debug('Test--DateTime'+qAW.flexNoteQuestion.Answer_Type__c);
                        Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d) ([0-1]?[0-9]|[2][0-3]):([0-5][0-9]) (AM|PM)');
                       
                        Matcher MyMatcher = MyPattern.matcher(qAW.answer.Answer__c); 
                        system.debug('matches--'+MyMatcher.matches());
                        
                        if(!MyMatcher.matches()){
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Info: Valid Date Time Format is mm/dd/yyyy hh:mm AM/PM.');
                            ApexPages.addMessage(myMsg);
                            //return ;
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
          
         //string locaddress=street+','+city+','+state+' '+zipcode;
         //system.debug('seladressloc--->'+seladressloc);
         
        //fetch latitude, longitude and address id        
         /*String address_id;
         String longitude;
         String latitude;
         String alias_name;
         String intersection_id;
         String full_intersection;*/
         
         if(ServiceLocationRequired == true){    
             locresult= geo_result.get(fulladdress);
             system.debug('locresult--->'+locresult);            
             list<string> result =new list<string>();
              if(Test.isRunningTest()){
                  result =new String[12]; 
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
                  
              }else{
                 result= locresult.split(':');
                 system.debug('result--->'+result);
              }  
                 list<string> ADDRESSID =result[0].split('='); 
                 
                 if(ADDRESSID[0]== 'ADDRESS_ID'){ 
                     address_id=ADDRESSID[1];
                 }else{
                    intersection_id=ADDRESSID[1];
                 }
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
                 
                 if(fulladdress.contains('-')){
                     list<string> result1= fulladdress.split('-');
                     
                      alias_name = result1[0];  
                      full_intersection = result1[1]; 
                 }      
                 
                 system.debug('address_id--->'+address_id+ 'longitude--->'+longitude+'latitude--->'+latitude);
            
        }
        try{
            if(selContact != null){
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
             
              //Adding jursdiction id  
               
              //caseToInsert.SRType_Jurisdiction__c=JurisId ;
              caseToInsert.SLA__c=Sla;
              caseToInsert.AgencyCode__c=Agency;
             
              
              if(ServiceLocationRequired == true){
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
                  
                  if(alias_name != null || alias_name == ''){
                      caseToInsert.AliasName__c=alias_name;
                  }
                   
                  if(intersection_id != null || intersection_id == ''){
                     caseToInsert.IntersectionId__c=intersection_id;
                  }
                   
                  if(full_intersection != null || full_intersection == ''){
                      caseToInsert.Address__c=full_intersection;
                  }else{
                      caseToInsert.Address__c=fulladdress;
                  }
                  
                  caseToInsert.GeoLocation__Latitude__s=decimal.ValueOf(latitude);
                  caseToInsert.GeoLocation__Longitude__s=decimal.ValueOf(longitude);
              }              
              system.debug('caseToInsert-------------------->'+caseToInsert);
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
            
           /* if(toInsertAnswers.isEmpty()){
                //roll back if there no answers to insert
                database.rollback(sp);
              //return null;    
            }*/
            
            
            if(selectedCaseId!=null){
                objCase=[select id,FlexNotes__c from case where id=:selectedCaseId];
                // updating case field 
                objCase.FlexNotes__C=(objCase.FlexNotes__C!=null)?(objCase.FlexNotes__c+''+createFlexNotesString(toInsertAnswers,questionAliasMap)):createFlexNotesString(toInsertAnswers,questionAliasMap);
                objCase.SRType__c=selectedServiceRequestType;
                system.debug('Entry -->');
                if(selContact != null){
                objCase.ContactId=cont.id;
                }
                system.debug('Exit-->');
            }
            if(selectedCaseId==null){
                
                objCase=caseToInsert;
                system.debug('contact id --'+objCase);
                objCase.FlexNotes__C=(objCase.FlexNotes__C!=null)?(objCase.FlexNotes__c+''+createFlexNotesString(toInsertAnswers,questionAliasMap)):createFlexNotesString(toInsertAnswers,questionAliasMap);
                objCase.SRType__c=selectedServiceRequestType;

                if(selContact != null){
                objCase.ContactId=cont.id;
                }
                system.debug('contact id --'+objCase);
                //system.debug('Exit cont.id -->' + cont.id);
            }
            
            //if(objCase!=null)update objCase;
            if(objCase!=null) update objCase;           
            system.debug('objCase Exit-->');
            // Creating flexnotes 
            if(toInsertAnswers != null || toInsertAnswers.size() > 0 ){                 
                         
              insert (toInsertAnswers);
            }
            
           casenumber =[Select CaseNumber From Case where Id=:objCase.Id];
           system.debug('casenumber --->'+casenumber );
            
        }
        catch(exception e){
            system.debug('unable to complete insert-->'+e);
            // we will inserting the error into error log object

            database.rollback(errorPoint);
            
            //return null;
        }
        
        
       system.debug('case --->'+objCase);
       /*try{
           casenumber =[Select CaseNumber From Case where Id=:objCase.Id];
           system.debug('casenumber --->'+casenumber );
       }catch(exception e){
            system.debug('unable casenumber -->'+e);                   
       }*/
        // we redirecting to contact 
        /*if(cont!=null){
            pageReference p=new pageReference('/'+cont.Id); 
            p.setRedirect(true);
            Return p;
        }
        
        pageReference p=new pageReference('/'+objCase.Id); 
        p.setRedirect(true);
        Return p;*/
        

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
                system.debug('selIndex'+selIndex);
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
        system.debug('xxxxxxxxxxxxx');
        service_location=true;
        service_type = false;
        return null;
    }      
    
    // preparing map of id and questions
    public void fetchFlexNoteQuestionMap(){
        
        for(FlexNoteQuestion__c flexQuestion:[select i.QuestionAlias__c, i.AnswerValues__c,i.Questions__c, i.Answer_Type__c, i.Required__c, i.Name, i.Id from FlexNoteQuestion__c i]){
           flexNoteIdMap.put(flexQuestion.id,flexQuestion);
        }
    }
    
    
    
    
    
    
    
    // updating case field flexNotes__C with question and answer in a format
    //Question1<questionAlias>=Answer1;question2<questionAlias>=Answer2;Question3<questionAlias>=Answer3;
    private string createFlexNotesString(list<FlexNote__c>answersList,map<string,string>questionAliasMap){
        string flexNotesString='';
        for(FlexNote__c a:answersList){
            flexNotesString+=a.Questions__c+'<'+questionAliasMap.get(a.Questions__c)+'>='+a.Answer__c+';';
        }
        system.debug('flexNotesstring'+flexNotesString);
        return flexNotesString;
    }
    
    // used in displaying multipicklist and getting selected values also
    public Class QuestionMultiPickListWrapper{
        // based on this will include picklist value
        public boolean isSelectedQuestion{get;set;}
        public string questionMultiPicklistItem{get;set;}
        public QuestionMultiPickListWrapper(string questionMultiPicklistItem){
            this.questionMultiPicklistItem=questionMultiPicklistItem;
            this.isSelectedQuestion=false;
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
    
    
    public pageReference StartOver(){
        service_type=true;
        service_location = false;
        service_information = false;
        contact_information = false;
        comments_attachments = false;
        review_submit = false;
        ServiceLocAddressDetails=false;
        review_result=false;
        
        return null;
    
    }
    
    public pageReference review_action_next(){
        service_type=true;
        service_location = false;
        service_information = false;
        contact_information = false;
        comments_attachments = false;
        review_submit = false;
        ServiceLocAddressDetails=false;
        review_result=false;
        
        return null;
    
    }
    
    public pageReference review_action_finish(){       
        
        PageReference pgref = new PageReference('/apex/ServiceHome');
        pgref .setRedirect(true);
        return pgref ;
       
    }
 }