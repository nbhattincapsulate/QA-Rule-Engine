public with sharing class ServiceRequestAdminCntrl {
    /*  
    *   ServiceRequestAdminCntrl Component Referred By ServiceRequestAdminPge  
    *   Replace Methods Description here
    *   CreatedBy:D M
    *   Copyright ?   All rights reserved.
    */  
    
    public string selectedSRTypeId{get;set;}
    
    public boolean showPopUp{get;set;}
    public boolean hidePopUp{get;set;}
    public string selQuestionIds{get;set;}
    
    private set<FlexNoteQuestion__c>toRemoveFNFrmAvailabe;
    public SRTFlexNoteQuestionRelationWrapper sRTFlexNoteRelation{get;set;}
    public SRTFlexNoteQuestionRelationWrapper tempSRTFlexNoteRelations;
    HelperPaginationCls hPClass;
    public integer noOfRowsToDisplay{get;set;}
    public boolean isShowPopUpRelation{get;set;}
    public ServiceRequestTypeFlexNote__c relation{get;set;}
    public string flexNoteQuestionId{get;set;}
    public boolean isEditMode{get;set;}
    public string serviceRequestToDeleteId{get;set;}
    public string sRTypeId{get;set;}
    private List<FlexNoteQuestionRelationWrapper>flexNotesQuestionRelPriorList;
    public boolean isClone{get;set;}
    // holds object name
    private string objectName;
    private string contactstatus;
    private integer tempRowsToDisplay;
    public list<ServiceRequestType__c>SRTypesList{get;set;}
    public ApexPages.StandardSetController setCont{get;set;}
    private string isInvokedFrmFNQuestion;
    private string isEditSRType;
    private Id sRTId;
    public list<string>alphaList{get;set;}
    public string filterStr{get;set;}
    private map<Id,ServiceRequestType_Jurisdiction__c>sRTypeJurisMap=new map<Id,ServiceRequestType_Jurisdiction__c>();
    private map<Id,FlexNoteQuestion__c>flexNoteIdMap=new map<Id,FlexNoteQuestion__c>();
    private map<Id,ServiceRequestTypeFlexNote__c >relationIdMap=new map<Id,ServiceRequestTypeFlexNote__c >();
    // flexnote questionId and serviceRequestTypeFlexNote
    private map<Id,ServiceRequestTypeFlexNote__c>flexNoteSRelationMap=new map<Id,ServiceRequestTypeFlexNote__c>();
    public string relationQuestion{get;set;}
    public string flexNoteDataType{get;set;}
    public string serviceTypeName{get;set;}
    public string selectedFilter{get;set;}
    private set<Id>toRemoveFlexNoteIds;
        
    public Integer flexnote_list_total_size { get; set; }
    private Integer flexnote_list_counter = 0;  //keeps track of the offset
    private static final Integer flexnote_list_size = 500;
	
	// Below are not used needed to remove once testing done
  	//  public string fNFilter{get;set;}
  	//public string unSelQuestionIds{get;set;}
    //public string leftSelQuestionIds{get;set;}
    //public string leftUnSelQuestionIds{get;set;}
    
    // constructor initiallization.
    public ServiceRequestAdminCntrl(){
        toRemoveFNFrmAvailabe=new set<FlexNoteQuestion__c>();
        
        toRemoveFlexNoteIds=new set<Id>();
        // default to 3
        noOfRowsToDisplay=20;  // made 10 to 20 as per requirement .2710
        // default setting noof rows to display
        setNoRowsDisplay();
        
        hPClass=new HelperPaginationCls('select id,name,Object__c,Service_Name__c from ServiceRequestType__c ORDER BY Service_Name__c','ServiceRequestType__c',noOfRowsToDisplay);
        SRTypesList=hPClass.getRecords();
        
        fetchFlexNoteQuestionMap();
        fetchRelationIdMap();
        // fetching map  
        fetchSRTypeJuris(); 
        isInvokedFrmFNQuestion=Apexpages.currentPage().getParameters().get('isInvokedFrmFNQuestion');
        isEditSRType=ApexPages.currentPage().getParameters().get('isEdit');
        sRTId=ApexPages.currentPage().getParameters().get('sRTypeId');
        // need to remove not used
        if(isInvokedFrmFNQuestion=='True'){     
            if(isEditSRType=='true'){
                selectedSRTypeId=sRTId; 
                doEditSRType();
            }else{
                doNewSRType();
            }
        }
        alphaList = new list<String> {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};

    }
    
    // invoked from input text on change           
    public void setNoRowsDisplay(){
        if(noOfRowsToDisplay!=null){
            tempRowsToDisplay=noOfRowsToDisplay;
        }
    }       
    

    /*pagination methods*/
    public integer TotalNumber{
        get{
             return hPClass.getRecordCount();
        }
        set;
    }
    

    public boolean hasNextPage{
        get {
            return hPClass.hasNextPage();
        }
        set;
    }
    
    public boolean hasPreviousPage{
        get{
            return hPClass.hasPreviousPage();
        }
        set;
    }
    
    public void firstPage(){
        SRTypesList=hPClass.getFirstPage();
    }
    
    public void lastPage(){
        SRTypesList=hPClass.getLastPage();
    }
    
    public void nextPage(){
        SRTypesList=hPClass.nextPage();
    }
    
    public void previousPage(){
        SRTypesList=hPClass.previousPage(); 
    }
    
    public integer PageNum{
        get{
            return hPClass.getCurrentPage();
        }
        set;
    }
    
    public integer TotalPageSize{
        get{
            return 0 == hPClass.getTotalPages() ? 1 : hPClass.getTotalPages();
        }set;
    }
    
    
    /*end of paginations methods*/
    // invoked from on change of object name
    // retreive object name and based which the question will fetched 
    public void retriveObjectName(){
        if(sRTFlexNoteRelation.sRType.Object__c!=null)
        objectName=sRTFlexNoteRelation.sRType.Object__c;
        
    }
    
    public void retrieveContactStatus(){
        if(sRTFlexNoteRelation.sRType.ContactStatus__c!=null)
        contactstatus=sRTFlexNoteRelation.sRType.ContactStatus__c;
        
    }
    
    
    //retrieveing questions to display in available questions 
    public list<FlexNoteQuestion__c>getFlexNoteQuestions(){
        list<FlexNoteQuestion__c>AvailableflexNoteQuestionList=new List<FlexNoteQuestion__c>();
        string queryStr='';
        queryStr+='select id,name,Questions__c,Answer_Type__c,AnswerValues__c,Object_Name__c from FlexNoteQuestion__c';
        String countQueryStr = 'Select Count() From FlexNoteQuestion__c';
        String objName = String.escapeSingleQuotes(objectName);
        
        if(objectName!=null){
          queryStr+= ' WHERE Object_Name__c = \'' + String.escapeSingleQuotes(objectName) + '\'';
          queryStr+='ORDER By CreatedDate Desc';     
          
          countQueryStr += ' WHERE Object_Name__c = \'' + String.escapeSingleQuotes(objectName) + '\'';
          system.debug('executes--'); 
        }
        queryStr += ' LIMIT :flexnote_list_size OFFSET :flexnote_list_counter';
        
        flexnote_list_total_size = database.countQuery(countQueryStr);
        list<FlexNoteQuestion__c>availableQuestionsList=database.query(queryStr);
        Map<id,FlexNoteQuestion__c>tempFNList=new map<Id,FlexNoteQuestion__c>();
        
        for(FlexNoteQuestion__c questinsItems:availableQuestionsList){         
            tempFNList.put(questinsItems.Id,questinsItems);
            system.debug('question---'+questinsItems);
        }
        
        if(toRemoveFlexNoteIds.isEmpty()){ 
            for(FlexNoteQuestion__c fNItem:availableQuestionsList){
                AvailableflexNoteQuestionList.add(fNItem);
            }
            system.debug('if condition of remove flex note');
        } else {
            for(FlexNoteQuestion__c fNItem:availableQuestionsList){
            	system.debug('toRemoveFlexNoteIds--'+toRemoveFlexNoteIds);
                if(toRemoveFlexNoteIds.contains(fNItem.Id)){
                	system.debug('flexnote =='+fNItem);
                	continue;
                	system.debug('flexnote to be --'+fNItem);
                	}
                AvailableflexNoteQuestionList.add(fNItem);      
            }
             system.debug('else condition of remove flex note');
        }
        
        system.debug('toRemove flexnotes-'+toRemoveFlexNoteIds);
        system.debug('questions to display--'+AvailableflexNoteQuestionList);
        system.debug('filter value--'+selectedFilter);
        
        if(!AvailableflexNoteQuestionList.isEmpty()){
        	list<Id>fNQListId=new list<Id>();
        	for(FlexNoteQuestion__c fn :AvailableflexNoteQuestionList){
        		fNQListId.add(fn.Id);
        	}
        	
	        list<FlexNoteQuestion__c>flexNoteList=new list<FlexNoteQuestion__c>();
	        if(selectedFilter=='All'){
	        	// nothing to do get all available display
	        }
	        if(selectedFilter=='Most Recent - 10 questions created'){
	        	for(integer i=0;i<(AvailableflexNoteQuestionList).size();i++){
	        	    //i--; 
	        		system.debug('AvailableflexNoteQuestionList--'+AvailableflexNoteQuestionList[i]);
	        		flexNoteList.add(AvailableflexNoteQuestionList[i]);
	        		if(flexNoteList.size()==10)break;
	        	}      
	        	if(!flexNoteList.isEmpty()){
	        		AvailableflexNoteQuestionList=flexNoteList;
	        	}
	        	
	        }
	        if(selectedFilter=='Most common - 10 questions used in most SR?s'){
	        	list<FlexNoteQuestion__c>tempQuestList=doFetchRecentUsedFlexNoteQuestion(fNQListId);
	        	if(tempQuestList!=null || !tempQuestList.isEmpty()){
	        		for(FlexNoteQuestion__c fn:tempQuestList){
	        			system.debug('AvailableflexNoteQuestionList--'+fn);
	        			flexNoteList.add(fn);
	        			if(flexNoteList.size()==10)break;
	        		}
	        	}
	        	if(!flexNoteList.isEmpty()){
	        		AvailableflexNoteQuestionList=flexNoteList;
	        	}
	        }  
	        system.debug('to display questinList--'+flexNoteList);
        }
        return AvailableflexNoteQuestionList;
    }
    
    public list<selectOption>getFilterOptions(){
    	list<selectOption>fnFilters=new list<selectOption>();
    	//fnFilters.add(new selectOption('','--Select--'));
    	fnFilters.add(new selectOption('All','All'));
    	fnFilters.add(new selectOption('Most common - 10 questions used in most SR?s','Most common - 10 questions used in most SR?s'));
    	fnFilters.add(new selectOption('Most Recent - 10 questions created','Most Recent - 10 questions most recently created'));
    	
    	return fnFilters;    
    }
   
	public void doRetrieveFlexNotesBasedFilter(){
		system.debug('filter method execute');
	}
    
    
    private list<FlexNoteQuestion__c>doFetchRecentUsedFlexNoteQuestion(list<Id>fNQuestionIdList){
    	if(fNQuestionIdList.isEmpty())return null;
    	list<FlexNoteQuestion__c>recentFlexNoteQuestion=new list<FlexNoteQuestion__c>();
    	for(FlexNoteQuestion__c fNQ:[select id,name,Questions__c,Answer_Type__c,AnswerValues__c,Object_Name__c,SRJunctionCount__c from FlexNoteQuestion__c where Id IN:fNQuestionIdList ORDER By SRJunctionCount__c Desc]){
    		recentFlexNoteQuestion.add(fNQ);
    	}
    	if(recentFlexNoteQuestion.isEmpty())return null;
    	return recentFlexNoteQuestion;
    }
    
    
    
    // invoke from remove link
    public PageReference doDeleteServiceRequestType(){
        try{
        if(serviceRequestToDeleteId==null)
        return null;
        ServiceRequestType__c serviceRequestToDelete=[select id,name from  ServiceRequestType__c where id=:serviceRequestToDeleteId];
            if (serviceRequestToDelete==null)return null;
                delete (serviceRequestToDelete);
        }
        catch (exception e){
            system.debug('unable to complete delete procee--> '+e);
        }
        serviceRequestToDeleteId=null;
        // added on to reinitizalize list 
        SRTypesList=hPClass.getRecords();
        return null;
    }
    
    
    // retrieving all service request flex note question and relationship 
    private SRTFlexNoteQuestionRelationWrapper retrieveSRTFlexNoteQuestion(string selSRTypeId){
        //SRTFlexNoteQuestionRelationWrapper tempSRTFlexNoteRelation=new SRTFlexNoteQuestionRelationWrapper();
        if(selSRTypeId==null)return null;
        
        list<Id>flexNoteQuestionIds=new list<Id>(); 
        map <id,ServiceRequestTypeFlexNote__c>tempFlexNoteRelationMap=new map<id,ServiceRequestTypeFlexNote__c>();
        for(ServiceRequestTypeFlexNote__c rel:[select id, name,FlexNote_Question__c ,Service_Request_Type__c,Order__c,DisplaySortOrder__c,Lower_Limit__c,Auto_Create__c,Upper_Limit__c,Force_Upper__c,Used_By_Interface_Only__c,
                                                    Start_Date__c,Stop_Date__c,isRequired__c,IsReadOnly__c from ServiceRequestTypeFlexNote__c where Service_Request_Type__c=:selSRTypeId ORDER BY DisplaySortOrder__c ASC]){
            flexNoteQuestionIds.add(rel.FlexNote_Question__c);
            tempFlexNoteRelationMap.put(rel.FlexNote_Question__c,rel);
        }
        
        list<FlexNoteQuestionRelationWrapper>tempFlexNoteRelation=new list<FlexNoteQuestionRelationWrapper>();
        for(Id FLNId:flexNoteQuestionIds){
                 FlexNoteQuestionRelationWrapper fNQRW=new FlexNoteQuestionRelationWrapper(flexNoteIdMap.get(FLNId),tempFlexNoteRelationMap.get(FLNId));
            tempFlexNoteRelation.add(fNQRW);
            system.debug('flexnote question---'+flexNoteIdMap.get(FLNId));
            system.debug('service request ---'+tempFlexNoteRelationMap.get(FLNId));
            system.debug('wrapper variable --'+fNQRW);
        }
        
               
        SRTFlexNoteQuestionRelationWrapper SRTFN; 
        for(ServiceRequestType__c SRT:[select id,name,Object__c,External_Description__c,LongExternalDescription__c,External_Name__c ,Service_Name__c,Default_Status__c,
                                    Start_Date__c, Default_Method__c,Stop_Date__c,Default_Priority__c,SR_Alert_Message__c,SendEmailOnSRCreation__c,SendEmailOnSRClosed__c,DuplicateRadius__c,Duplicate_Threshold_Period__c,
                                    Flex_Notes_Link_Indicator__c,Activities_Link_Indicator__c,Participant_Link_Indicator__c,Attachment_Link_Indicator__c,Keep_SR_Open__c,Remarks__c,DuplicateDetectionMethod__c,
                                    Allow_Citizen_Web_Intake__c,ServiceLocationRequired__c,ContactRequired__c,SLAType__c,ContactStatus__c,ServiceLocationStatus__c,Jurisdiction__c,SLA__c,Agency__c,Jurisdiction__r.Department__c from ServiceRequestType__c where id=:selSRTypeId]){
            SRTFN=new SRTFlexNoteQuestionRelationWrapper(SRT);
            SRTFN.flexNoteRelationList=tempFlexNoteRelation;
            system.debug('SRTFN.flexNoteRelationList--'+SRTFN.flexNoteRelationList);
            //tempSRTFlexNoteRelation.=SRTFN;        
           
        }
       
        if(SRTFN==null)return null; // added on 1109
        return SRTFN;
    }
    
    
    // invoked from edit button link page list  
    public void doEditSRType(){
        
        //flexNoteSRelationMap=new Map<Id,ServiceRequestTypeFlexNote__c>();
        if(selectedSRTypeId!=null){
            system.debug('entering this line--');
            
           SRTFlexNoteQuestionRelationWrapper temSRTFNR=retrieveSRTFlexNoteQuestion(selectedSRTypeId);
            system.debug('entere this line--');
           
            if(temSRTFNR!=null){
                 sRTFlexNoteRelation=temSRTFNR;
                flexNotesQuestionRelPriorList=new list<FlexNoteQuestionRelationWrapper>();
                //tempSRTFlexNoteRelations=sRTFlexNoteRelation;
                for(FlexNoteQuestionRelationWrapper q:temSRTFNR.flexNoteRelationList){
                    flexNotesQuestionRelPriorList.add(q);
                    // added to remove from available list
                    toRemoveFNFrmAvailabe.add(q.flexNoteQuestion);
                    
                    if(q.flexNoteQuestion!=null)toRemoveFlexNoteIds.add(q.flexNoteQuestion.Id);
                    
                    if(q.flexNoteQuestion!=null){
                         flexNoteSRelationMap.put(q.flexNoteQuestion.Id,q.sRFlexNoteRelation);
                    }
                    system.debug('entering this line2');
                }
                system.debug('flexNotesQuestionRelPriorList--->'+flexNotesQuestionRelPriorList);
                system.debug('entering this line3');
                // enable clone function if are no selected questions
                if(temSRTFNR.flexNoteRelationList.isEmpty()){
                    isClone=true;
                }
                system.debug('entering this line4');
                        
         		// defaut case object //0910
        		retriveObjectName();
        		
        		// defaut contact status
        		retrieveContactStatus();
            }     
            
        }
        
        showPopUp=true; 
        isEditMode=true;
    }    
     
    
  
    // invoked from Add button from page
    public void doNewSRType(){
        ServiceRequestType__c t=new ServiceRequestType__c(Object__c='Case',ContactStatus__c='Avaliable');
        sRTFlexNoteRelation=new SRTFlexNoteQuestionRelationWrapper(t);
        
        // defaut case object 
        retriveObjectName();
        
        // defaut contact status
        retrieveContactStatus();
        
        // enabling clone function
        isClone=true;
        
        showPopUp=true;
        isEditMode=false;
    }

    
    public void addSelectedQuestions(){
        if(selQuestionIds==null)return;
        //set<string>tempSelQuestion=retrieveFlexNotes(selQuestionIds);
        list<string>tempQuestion=retrieveFlexNotesRelation(selQuestionIds);
        //tempQuestion.addAll(tempSelQuestion);
        if(tempQuestion.isEmpty())return;
        // clear flex note list if present and reconstruct in below for loop
        if(!sRTFlexNoteRelation.flexNoteRelationList.isEmpty())sRTFlexNoteRelation.flexNoteRelationList.clear();
        
        // collecting question to removed from available box
        if(!toRemoveFNFrmAvailabe.isEmpty())toRemoveFNFrmAvailabe.clear();  // 2509
        
        if(!toRemoveFlexNoteIds.isEmpty())toRemoveFlexNoteIds.clear();   
        
        system.debug('passed from javascript question and relation ids'+tempQuestion);  
        for(string ids:tempQuestion){
            // fetch question id 
            string questionId=retrieveQuestionsId(ids);
            // fetch relation id if present
            string relationId=retrieveRelations(ids);
            // if question id and relation id present add them else will create relation record  and add them to list
            if(questionId=='' || questionId==null)return ;
            
            if(flexNoteSRelationMap.containsKey(questionId)){
                // bring service request junction object from map else create one
                ServiceRequestTypeFlexNote__c relationRcrd=flexNoteSRelationMap.get(questionId);
                FlexNoteQuestionRelationWrapper fnq=new FlexNoteQuestionRelationWrapper(flexNoteIdMap.get(questionId),relationRcrd);
                sRTFlexNoteRelation.flexNoteRelationList.add(fnq);
            }else{
                ServiceRequestTypeFlexNote__c relationRcrd=new ServiceRequestTypeFlexNote__c(FlexNote_Question__c=questionId);
                FlexNoteQuestionRelationWrapper fnq=new FlexNoteQuestionRelationWrapper(flexNoteIdMap.get(questionId),relationRcrd);
                sRTFlexNoteRelation.flexNoteRelationList.add(fnq);
            }
            
            for(FlexNoteQuestionRelationWrapper fnqRItem:sRTFlexNoteRelation.flexNoteRelationList){
                system.debug('flexnote question to added to selected box-- '+fnqRItem.sRFlexNoteRelation );
            }
            
            
            toRemoveFNFrmAvailabe.add(flexNoteIdMap.get(questionId));//2509
            
            toRemoveFlexNoteIds.add(questionId);
            system.debug('total flexnote to remove from available list--'+toRemoveFNFrmAvailabe);
        }
        
        // clear hidden input
        selQuestionIds=null;
    }
    
    // getting question ids
    private string retrieveQuestionsId(string originalSplitedStr){
        if(originalSplitedStr==null)return null;
        //list<string>questionList=new list<string>();
        string question;
        list<string>tempQ=new list<string>();
        if(originalSplitedStr.contains(':')){
            tempQ=originalSplitedStr.split(':');
            system.debug('tempQ---'+tempQ);
            question=tempQ[0];
        }else{
            //questionList.add(originalSplitedStr);
            question=originalSplitedStr;
        }
        
        if(question==null)return null;
        
        return question;
    }
   
   // getting relation id  
    private string retrieveRelations(string originalSplitedStr){
        if(originalSplitedStr==null)return null;
        //list<string>relationList=new list<string>();
        string relation;
        list<string>tempQ=new list<string>();
        if(originalSplitedStr.contains(':')){
            tempQ=originalSplitedStr.split(':');
            if(tempQ.size()>2){
                //relationList.add(tempQ[1]);
                if(tempQ[1]!=null)relation=tempQ[1];
            }
        }
        if(relation==null)return null;
        return relation;
    }
    
    private void fetchRelationIdMap(){
        for(ServiceRequestTypeFlexNote__c rel:[Select s.IsReadOnly__c,s.Order__c,DisplaySortOrder__c, s.isRequired__c, s.Used_By_Interface_Only__c, s.Upper_Limit__c, s.Stop_Date__c, s.Start_Date__c, s.Service_Request_Type__c, s.Name, s.Lower_Limit__c, s.Id, s.Force_Upper__c, s.FlexNote_Question__c, s.Auto_Create__c From ServiceRequestTypeFlexNote__c s]){
            relationIdMap.put(rel.Id,rel);
           
        }
    }
    
    // converting comma seperate into set of questions
    private list<string>retrieveFlexNotesRelation(string questionsStr){
        system.debug('questionsStr-'+questionsStr);
        if(questionsStr==null)return null;
        list<string>qlist=new list<string>();
        //set<string>qIds=new set<string>();
        if(questionsStr.contains(',')){
            list<string>qList1=questionsStr.split(',');
            qlist.addAll(qList1);
            //qIds.addAll(qList);
            system.debug('qIds--->'+qList);
        }
        else{
           // qIds.add(questionsStr);
            qlist.add(questionsStr);
        }
        
        return qlist;
    }
    
    // converting comma seperate into set of questions
    private set<string>retrieveFlexNotes(string questionsStr){
        system.debug('questionsStr-'+questionsStr);
        if(questionsStr==null)return null;
        set<string>qIds=new set<string>();
        if(questionsStr.contains(',')){
            list<string>qList=questionsStr.split(',');
            qIds.addAll(qList);
            system.debug('qIds--->'+qIds);
        }
        else{
            qIds.add(questionsStr);
        }
        
        return qIds;
    }
    
    // retriveing all relation pop data
    public void showPopUpRelation(){
        isShowPopUpRelation=true;
        retrieveRelationData();
    }
    
    
    
    private void retrieveRelationData(){
        if(sRTFlexNoteRelation!=null){
            for(FlexNoteQuestionRelationWrapper items:sRTFlexNoteRelation.flexNoteRelationList){
                if(items.flexNoteQuestion.Id==flexNoteQuestionId){
                    relation=items.sRFlexNoteRelation;
                    relationQuestion=items.flexNoteQuestion.Questions__c;
                    flexNoteDataType=items.flexNoteQuestion.Answer_Type__c;
                    system.debug('flexNoteDataType--'+flexNoteDataType);
                    system.debug('relationQuestion--'+relationQuestion);
                    system.debug('relation--'+relation);
                }
            }
            serviceTypeName=sRTFlexNoteRelation.sRType.Service_Name__c;
            system.debug('serviceTypeName--'+serviceTypeName);
            
        }
    }
    
    // cancel from service request type pop window 
    public pageReference doCancel(){
        showPopUp=false;
        isEditMode=null;
        selectedFilter=null;  //2809
        
        if(!toRemoveFlexNoteIds.isEmpty())toRemoveFlexNoteIds.clear();   
        return null;
    }
    
    // save from relation pop window 
    public PageReference doRelationSave(){
        try{
            if(sRTFlexNoteRelation!=null){
                for(FlexNoteQuestionRelationWrapper items:sRTFlexNoteRelation.flexNoteRelationList){
                    if(items.flexNoteQuestion.Id==flexNoteQuestionId){
                        items.sRFlexNoteRelation=relation;
                        
                    }
                }
            }
            if(relation!=null){
               // upsert relation;
              if(flexNoteQuestionId!=null){
                
                if (flexNoteSRelationMap.containsKey(flexNoteQuestionId)){
                    // removing if present and adding again
                    flexNoteSRelationMap.remove(flexNoteQuestionId);
                    flexNoteSRelationMap.put(flexNoteQuestionId,relation);
                }
                // add  to map if question Id does not 
                else{
                    flexNoteSRelationMap.put(flexNoteQuestionId,relation);
                }
              } 
              
            }            
            flexNoteQuestionId=null;
            isShowPopUpRelation=false;
        }
        catch (exception e){
            system.debug('unable to complete insert or update process-->'+e);
        }
        return null;
    }
    
    // cancel from relation pop window 
    public PageReference  doRelationPopCancel(){
        flexNoteQuestionId=null;
        isShowPopUpRelation=false;
        system.debug('isShowPopUpRelation--->'+isShowPopUpRelation);
        return null;
    }
    
    // retrieving question and relation to be added into selected question list
    private list<FlexNoteQuestionRelationWrapper>retrieveQuestions(string SRId){
        if(SRId==null)return null;
        map<Id,ServiceRequestTypeFlexNote__c>tempQuestionRelationMap=new map<Id,ServiceRequestTypeFlexNote__c>();
        list<FlexNoteQuestionRelationWrapper>tempQuestionRelationList=new list<FlexNoteQuestionRelationWrapper>();
        
        try{
            list<Id>questIds=new list<Id>();
            for(ServiceRequestTypeFlexNote__c rel:[select id, name,FlexNote_Question__c ,Service_Request_Type__c,Order__c,DisplaySortOrder__c,Lower_Limit__c,Auto_Create__c,Upper_Limit__c, Force_Upper__c,Used_By_Interface_Only__c,
                                                Start_Date__c,Stop_Date__c, isRequired__c,IsRequiredQuestion__c,IsReadOnly__c from ServiceRequestTypeFlexNote__c where Service_Request_Type__c=:SRId ORDER BY DisplaySortOrder__c ASC]){
                questIds.add(rel.FlexNote_Question__c);
                tempQuestionRelationMap.put(rel.FlexNote_Question__c,rel);
            }

            for(Id qIds:questIds){
                FlexNoteQuestionRelationWrapper fNQRW=new FlexNoteQuestionRelationWrapper(flexNoteIdMap.get(qIds),tempQuestionRelationMap.get(qIds));
                tempQuestionRelationList.add(fNQRW);
                // included to remove from available question list
                toRemoveFNFrmAvailabe.add(flexNoteIdMap.get(qIds));
                
                toRemoveFlexNoteIds.add(qIds);
            }
            
            
        }
        catch(exception e){
            system.debug('unable to complete query Process due--'+e);
        }
        return tempQuestionRelationList;
    }
               
    // 
    public list<selectOption>getSRTypesOptions(){
        list<SelectOption>selOptions=new list<selectOption>();
        list<SelectOption>tempselOptions=new list<selectOption>();
        for(ServiceRequestType__c sRTyeItem:[select id,Name,Service_Name__c from ServiceRequestType__c where id !=:selectedSRTypeId ORDER BY Service_Name__c ASC]){
            if(sRTyeItem.Service_Name__c!=null)
            selOptions.add(new selectoption(sRTyeItem.Id,sRTyeItem.Service_Name__c));
        }
        //default option
        tempselOptions.add(new selectOption('null','Please Select'));
        tempselOptions.addAll(selOptions);  
        return tempselOptions;
    }
    
    
     
    // invoke from clone button
    // adding all question to selected question list based on service request type selected 
    public void doCloneSRType(){
        try{
            if(sRTypeId==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Please Select ServiceRequest Type.'));
            return ;
            }
            
            list<FlexNoteQuestionRelationWrapper>tempRetrieveQuestionList=retrieveQuestions(sRTypeId);
            if(tempRetrieveQuestionList.isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'There are No FlexNotes For a Selected Service Request Type.'));
                return ;
            }
            set<Id>QuestionIdsComparingSet=new set<Id>();
            if(sRTFlexNoteRelation!=null){
                for(FlexNoteQuestionRelationWrapper fnRelWrap:sRTFlexNoteRelation.flexNoteRelationList){
                    QuestionIdsComparingSet.add(fnRelWrap.flexNoteQuestion.Id);
                }
            }
            
            for(FlexNoteQuestionRelationWrapper relItem:tempRetrieveQuestionList){
                ServiceRequestTypeFlexNote__c temRel=relItem.sRFlexNoteRelation.clone(false,false,false);
                FlexNoteQuestion__c tempQuestion=relItem.flexNoteQuestion;
                FlexNoteQuestionRelationWrapper fnw =new FlexNoteQuestionRelationWrapper(tempQuestion,temRel);
                
                system.debug('service relation recrd--'+temRel);
                system.debug('flexnote question recrd--'+tempQuestion);
                system.debug('relation and flex note question --'+fnw);
                
                // comparing set not empty else add the 
                if(!QuestionIdsComparingSet.isEmpty()){ 
                    if(!QuestionIdsComparingSet.contains(tempQuestion.Id)){
                        sRTFlexNoteRelation.flexNoteRelationList.add(fnw);
                    }
                }
                else{
                    sRTFlexNoteRelation.flexNoteRelationList.add(fnw);
                }
                
            }
            //sRTFlexNoteRelation.flexNoteRelationList.addAll(tempRetrieveQuestionList);  // 2108
            isClone=false;
            sRTypeId=null;// clear previous servicerequest for clone
        }
        catch(exception e){
            system.debug('unable to get the questions list due--'+e);
            ApexPages.addMessages(e);
        }
         
    }
    

    
    private boolean doValidationCheck(SRTFlexNoteQuestionRelationWrapper sRTFNQRel){
        // validation for checking object name ,service code and atleast a question 
        if(sRTFNQRel.sRType.Object__c==null){
            Apexpages.Message objNameMsg=new Apexpages.Message(apexpages.severity.Info,'Please Provide Object, Its Required.');
            ApexPages.addMessage(objNameMsg);
            return True;
        }
        system.debug('serviceRequestType-'+sRTFNQRel.sRType);
        if(sRTFNQRel.sRType.Name==null){
            Apexpages.Message serviceCodeMsg=new Apexpages.Message(apexpages.severity.Info,'Please Provide Service Code, Its Required.');
            ApexPages.addMessage(serviceCodeMsg);
            return True;
        }
        /* ER:  2014-09-02 Flex Notes not required in all cases
        if(sRTFNQRel.flexNoteRelationList.isEmpty()){
            Apexpages.Message questionListMsg=new Apexpages.Message(apexpages.severity.Info,'Please Provide Atleast a Question, Its Required.');
            ApexPages.addMessage(questionListMsg);
            return True;
        }*/
        return false;
    }
    
    
    
    public void doSearchByAlphabet(){
        system.debug('filterString ---->'+filterStr);
        if(filterStr==null)return ;
        
         String queryStr='select id,name,Object__c,Service_Name__c from ServiceRequestType__c ';
         queryStr+=' Where Service_Name__c Like \''+string.escapesingleQuotes(filterStr)+ '%\' ORDER BY Service_Name__c';
         hPClass=new HelperPaginationCls(queryStr,'ServiceRequestType__c',20);
         System.debug('results--->'+hPClass.getRecords());
         SRTypesList=hPClass.getRecords();
         
         if(SRTypesList.isEmpty()){
                Apexpages.Message Msg=new Apexpages.Message(apexpages.severity.Info,'There are No Records.');
            ApexPages.addMessage(Msg);
         }
    }
           
     
    public void fetchFlexNoteQuestionMap(){
        for(FlexNoteQuestion__c flexQuestion:[select id,name ,Questions__c,Answer_Type__c,AnswerValues__c from FlexNoteQuestion__c ]){
           flexNoteIdMap.put(flexQuestion.id,flexQuestion);
            system.debug('execute fetch relation id map');
        }
    }      
    
    
    // invoked from save button
    public void doSaveServiceRequestType(){
        ServiceRequestType__c SRTypeToInsert;
        if(sRTFlexNoteRelation==null)return;
        
        list<FlexNoteQuestion__c>flexNotesListToInsert=new list<FlexNoteQuestion__c>();
        list<ServiceRequestTypeFlexNote__c >relationshipListToInsert=new list<ServiceRequestTypeFlexNote__c >();
        
        integer qIndex=0;
        for(FlexNoteQuestionRelationWrapper flexNoteRelItem: sRTFlexNoteRelation.flexNoteRelationList){
            flexNoteRelItem.sRFlexNoteRelation.Order__c=string.Valueof(qIndex);
            relationshipListToInsert.add(flexNoteRelItem.sRFlexNoteRelation);
            //flexNotesListToInsert.add(flexNoteRelItem.flexNoteQuestion);
             qIndex++;
        } 
        SRTypeToInsert=sRTFlexNoteRelation.sRType;
        
        // validation is check satified then continue else return from this method 
        if(doValidationCheck(sRTFlexNoteRelation))return;
        
        savepoint sp=database.setSavepoint();
        try{
            if(SRTypeToInsert!=null){
            	//if(SRTypeToInsert.Start_Date__c==null)SRTypeToInsert.Start_Date__c=system.today();  //21/11
            	//if(SRTypeToInsert.Stop_Date__c==null)SRTypeToInsert.Stop_Date__c=system.today();
                insert (SRTypeToInsert);
            }
            
             // updating service request id to junction object
            for(ServiceRequestTypeFlexNote__c sRelationItem:relationshipListToInsert){
                //if(sRelationItem.Id!=null)sRelationItem.Service_Request_Type__c=SRTypeToInsert.Id;
                sRelationItem.Service_Request_Type__c=SRTypeToInsert.Id;
                system.debug('relation to be inserted --'+sRelationItem);
            }
            
                      
            if(relationshipListToInsert.size()>0){
                upsert(relationshipListToInsert);
            }
            
            // disable clone function 
            isClone=false;
            // close popup window
            showPopUp=false;
            isEditMode=null;
            selectedFilter=null;  //2809
            if(!toRemoveFNFrmAvailabe.isEmpty())toRemoveFNFrmAvailabe.clear();  // clear selected question list 160914
            
            if(!toRemoveFlexNoteIds.isEmpty())toRemoveFlexNoteIds.clear();  // clear selected question list 
            
            
        }
        catch(exception e){
            system.debug('unable to complete insert Process--'+e);
            ApexPages.addMessages(e);
            database.rollback(sp);
            
        } 
        // added on to reinitizalize list 
        SRTypesList=hPClass.getRecords();
        
    }
    
    public void doUpdateServiceRequestType(){
               
        ServiceRequestType__c SRTypeToInsert;
        if(sRTFlexNoteRelation==null)return;
        list<FlexNoteQuestion__c>flexNotesListToInsert=new list<FlexNoteQuestion__c>();
        list<ServiceRequestTypeFlexNote__c >relationshipListToInsert=new list<ServiceRequestTypeFlexNote__c >();
        
        list<ServiceRequestTypeFlexNote__c>relationFlexNotesToDelete=new list<ServiceRequestTypeFlexNote__c>();
        list<FlexNoteQuestionRelationWrapper>comparingQuestionList=new list<FlexNoteQuestionRelationWrapper>();
        
        list<Id>TotalQuestionsList=new list<Id>();
        
        set<FlexNoteQuestionRelationWrapper>tempFlexNoteRel=new set<FlexNoteQuestionRelationWrapper>();
        
         // holds new flexnotes questions
        set<FlexNoteQuestion__c>newFlexNotesList=new set<FlexNoteQuestion__c>();
        // holds old flexnotes questions
        set<FlexNoteQuestion__c>priorFlexNotesList=new set<FlexNoteQuestion__c>();
        
        
        integer qIndex=0;
        for(FlexNoteQuestionRelationWrapper flexNoteRelItem: sRTFlexNoteRelation.flexNoteRelationList){
            flexNoteRelItem.sRFlexNoteRelation.Order__c=string.Valueof(qIndex);
            relationshipListToInsert.add(flexNoteRelItem.sRFlexNoteRelation);
            tempFlexNoteRel.add(flexNoteRelItem);
            newFlexNotesList.add(flexNoteRelItem.flexNoteQuestion);
            qIndex++;
        } 
        
        // collectiong old flexnotes questions
        for(FlexNoteQuestionRelationWrapper qRel:flexNotesQuestionRelPriorList){
            tempFlexNoteRel.add(qRel);
            priorFlexNotesList.add(qRel.flexNoteQuestion);
        }
        
        list<ServiceRequestTypeFlexNote__c>flexNoteRelToDeleteList=new list<ServiceRequestTypeFlexNote__c>();
        list<ServiceRequestTypeFlexNote__c>flexNoteRelUpsertList=new list<ServiceRequestTypeFlexNote__c>();
        
        
        for(FlexNoteQuestionRelationWrapper flexNoteRel:tempFlexNoteRel){
            if(!(newFlexNotesList.contains(flexNoteRel.flexNoteQuestion)) && priorFlexNotesList.contains(flexNoteRel.flexNoteQuestion)){
                system.debug('DELETE--->'+flexNoteRel.sRFlexNoteRelation);
                flexNoteRelToDeleteList.add(flexNoteRel.sRFlexNoteRelation);
            }
        }
        
        if(doValidationCheck(sRTFlexNoteRelation))return;
        
        savepoint sp1=database.setSavepoint();
        try{
            SRTypeToInsert=sRTFlexNoteRelation.sRType;
            if(SRTypeToInsert!=null){
            	
            	//if(SRTypeToInsert.Start_Date__c==null)SRTypeToInsert.Start_Date__c=system.today(); //21/11
            	//if(SRTypeToInsert.Stop_Date__c==null)SRTypeToInsert.Stop_Date__c=system.today();
            	update SRTypeToInsert;
            }
            
            // updating service request id to junction object
            for(ServiceRequestTypeFlexNote__c sRelationItem:relationshipListToInsert){
                if(sRelationItem.Id==null)sRelationItem.Service_Request_Type__c=SRTypeToInsert.Id;
                system.debug('relation to be upsert in update method--'+sRelationItem);
            }
            
            if(relationshipListToInsert.size()>0)upsert(relationshipListToInsert);
            // calling doUpsert method service type jurdi invoked
          //  doUpdateSRTypeJuris(SRTypeToInsert.Id,SRTypeToInsert.Jurisdiction__c);
            
            // list to be deleted is not empty call delete method 
            if(!flexNoteRelToDeleteList.isEmpty())doDeleteFlexNoteRelation(flexNoteRelToDeleteList);
            // close popup
            showPopUp=false;
            // clearing editmode value
            isEditMode=null;
            // disable clone 
            isClone=false;  
            selectedFilter=null;  //2809
         	if(!toRemoveFNFrmAvailabe.isEmpty())toRemoveFNFrmAvailabe.clear();  // clear selected question list 160914
             
         	if(!toRemoveFlexNoteIds.isEmpty())toRemoveFlexNoteIds.clear();
             
        }
        catch(exception e){
            system.debug('Unable to complete Upsert Delete Process'+e);
            ApexPages.addMessages(e);
            database.rollback(sp1);
        }
        
    	// added on to reinitizalize list // 13.08
        SRTypesList=hPClass.getRecords();
    }
    
   
   	private void doDeleteFlexNoteRelation(list<ServiceRequestTypeFlexNote__c>relationToDelete){
        if(relationToDelete.isEmpty())return;
        // adding all the flex note relation to set ,REMOVING Duplicate ids
        set<ServiceRequestTypeFlexNote__c>toBeDelete=new set<ServiceRequestTypeFlexNote__c>();
        toBeDelete.addAll(relationToDelete);
        
        if(toBeDelete.isEmpty())return;
            
        relationToDelete.clear();
        relationToDelete.addALL(toBeDelete);
        
        savepoint relDeletePoint=database.setSavepoint();
        try{
            delete(relationToDelete);
        }
        catch(exception e){
            system.debug('unable to complete delete relation--'+e);
            database.rollback(relDeletePoint);
        }
   	} 
    
     
    /*flexnote question creation */
    public FlexNoteQuestion__c flexNoteQuestion{get;set;}
    public boolean showQuestionPopUp{get;set;}
    
    // invoked from add flex note question button   
    public pageReference doCreateFlexNoteQuestion(){
        flexNoteQuestion=new FlexNoteQuestion__c(Object_Name__c='Case'); 
        showQuestionPopUp=true;
        return null;
    }
    
     // invoked from save button
    public pageReference doSaveFlexNoteQuestion(){
        // validation check point
        if(doValidationCheck(flexNoteQuestion))return null;
        if(isValidDate(flexNoteQuestion))return null;
        savepoint sp1=database.setSavepoint();
        try{
            if(flexNoteQuestion!=null){
            	if(flexNoteQuestion.AnswerValues__c!='' || flexNoteQuestion.AnswerValues__c!=null)flexNoteQuestion.AnswerValues__c=removeLineBreaks(flexNoteQuestion.AnswerValues__c);
                insert (flexNoteQuestion);
                
                // 19.09
                if (flexNoteIdMap!=null){
                    if(!flexNoteIdMap.containskey(flexNoteQuestion.Id)){
                    flexNoteIdMap.put(flexNoteQuestion.id,flexNoteQuestion);
                    system.debug('flexNoteIdMap---'+flexNoteIdMap);
                    }
                }
                else{
                	flexNoteIdMap.put(flexNoteQuestion.id,flexNoteQuestion);
                }
                ServiceRequestTypeFlexNote__c relationRcrd=new ServiceRequestTypeFlexNote__c(FlexNote_Question__c=flexNoteQuestion.Id);
                FlexNoteQuestionRelationWrapper fnq=new FlexNoteQuestionRelationWrapper(flexNoteIdMap.get(flexNoteQuestion.Id),relationRcrd);
                sRTFlexNoteRelation.flexNoteRelationList.add(fnq);
                
                toRemoveFNFrmAvailabe.add(flexNoteIdMap.get(flexNoteQuestion.Id));
                
                toRemoveFlexNoteIds.add(flexNoteQuestion.Id);
                system.debug('flex notes to be removed--'+toRemoveFNFrmAvailabe);
                
                 system.debug('flex notes to be removed--'+toRemoveFlexNoteIds);
            }
            showQuestionPopUp=false;
        }
        catch(exception e){
            system.debug('unable to complete insert Process due--'+e);
            ApexPages.addMessages(e);
            database.rollback(sp1);
            
        } 
        return null;
    }
    
     // all validation is done here  for flex note questions like question ,service code and other
    private boolean doValidationCheck(FlexNoteQuestion__c flexNoteQuest){
        
        // validation for checking object name ,service code and a question 
        if(flexNoteQuest.Object_Name__c==null){
            Apexpages.Message objNameMsg=new Apexpages.Message(apexpages.severity.Info,'Please Provide Object, Its Required.');
            ApexPages.addMessage(objNameMsg);
            return True;
        }
        if(flexNoteQuest.Name==null){
            Apexpages.Message serviceCodeMsg=new Apexpages.Message(apexpages.severity.Info,'Please Provide Service Code, Its Required.');
            ApexPages.addMessage(serviceCodeMsg);
            return True;
        }
       /* if(flexNoteQuest.Answer_Type__c==null){
            Apexpages.Message questionListMsg=new Apexpages.Message(apexpages.severity.Info,'Please Provide DataType, Its Required.');
            ApexPages.addMessage(questionListMsg);
            return True;
        }*/
        if(flexNoteQuest.Questions__c=='' || flexNoteQuest.Questions__c==null){
            Apexpages.Message questionListMsg=new Apexpages.Message(apexpages.severity.Info,'Please Provide Flex Note Question, Its Required.');
            ApexPages.addMessage(questionListMsg);
            return True;
        }
        system.debug('flexnoteanwere--'+flexNoteQuest.AnswerValues__c);
        if((flexNoteQuest.Answer_Type__c=='Picklist' && (flexNoteQuest.AnswerValues__c=='' || flexNoteQuest.AnswerValues__c==null)) || (flexNoteQuest.Answer_Type__c=='MultiPicklist' && (flexNoteQuest.AnswerValues__c=='' || flexNoteQuest.AnswerValues__c==null))){
            Apexpages.Message questionListMsg=new Apexpages.Message(apexpages.severity.Info,'Please Provide Picklist Values, Its Required.');
            ApexPages.addMessage(questionListMsg);
            return True;
        } 
        /*
        if((flexNoteQuest.Answer_Type__c=='Date' && flexNoteQuest.AnswerValues__c==null) || (flexNoteQuest.Answer_Type__c=='MultiPicklist' && flexNoteQuest.AnswerValues__c==null)){
            Apexpages.Message questionListMsg=new Apexpages.Message(apexpages.severity.Info,'Please Provide 8/13/2014 12:18 AM Values, Its Required.');
            ApexPages.addMessage(questionListMsg);
            return True;
        }*/
        // CHECKING FOR VALID DATE FORMAT 
        
        return false;
    }
    
    // validating correct date time format
    private Boolean isValidDate(FlexNoteQuestion__c fnQuestion){
        /*if(fnQuestion.Answer_Type__c=='Date/Time' && fnQuestion.AnswerValues__c!=null){
            // valid format 
            Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d) ([0-1]?[0-9]|[2][0-3]):([0-5][0-9]) (AM|PM)');
            Matcher MyMatcher = MyPattern.matcher(fnQuestion.AnswerValues__c);
            if(!MyMatcher.matches()){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Info: Valid Date Time Format is mm/dd/yyyy hh:mm AM/PM.');
                ApexPages.addMessage(myMsg);
                return true;
            }
        }   
        if(fnQuestion.Answer_Type__c=='Date' && fnQuestion.AnswerValues__c!=null){
            // valid format 
                Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)');
                Matcher MyMatcher = MyPattern.matcher(fnQuestion.AnswerValues__c);
                if(!MyMatcher.matches()){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Info: Valid Date Format is mm/dd/yyyy.');
                    ApexPages.addMessage(myMsg);
                    return true;
                }
        }*/  
        return false;
    } 
   
   
    // invoked from cancel button
    public pageReference doCancelFlexNoteQuestion(){
        // setting to null
        showQuestionPopUp=false;
        return null;
    }
    public string dataTypeName{get;set;}
    public boolean conditionalRequired{get;set;}
    
    // used for making css required 
    public void doConditionalRequiredRender(){
        if((dataTypeName=='Picklist') || (dataTypeName=='MultiPicklist')){
            conditionalRequired=true;
        }
        else{
            conditionalRequired=false;
        }
    }
   
    // preparing map servicerequest type id and sRTypeJuridiction
    public void fetchSRTypeJuris(){
        for (ServiceRequestType_Jurisdiction__c s:[select id,name, SLA__c, Jurisdiction__r.Agency__c, ServiceRequestType__r.Id, ServiceRequestType__r.Name from ServiceRequestType_Jurisdiction__c]){
         sRTypeJurisMap.put(s.ServiceRequestType__r.Id,s);
        }  
    }   
    
    // creating sRType jurdication if not present
    private void doUpdateSRTypeJuris(Id sRTypeId ,Id jurId){
        if(sRTypeId!=null && jurId!=null){
            // contains jurisd and srtype
            ServiceRequestType_Jurisdiction__c sRJur=[select id,Jurisdiction__r.Agency__c,ServiceRequestType__c,Jurisdiction__c,Jurisdiction__r.Id,SLA__c from ServiceRequestType_Jurisdiction__c where ServiceRequestType__c=:sRTypeId And Jurisdiction__c=:jurId];
             
            if(sRJur==null)sRJur=new ServiceRequestType_Jurisdiction__c();
               
            sRJur.Jurisdiction__c=jurId;
            sRJur.ServiceRequestType__c=sRTypeId;
            sRJur.SLA__c=sRJur.SLA__c;
            upsert sRJur; 
        }   
     }        
     
 	 private string removeLineBreaks(string inText){
	   if (inText == null)
	       return null;
	   else
	       return inText.replaceAll('\r\n', '');
	 }
   
    
    
    // container for holding relation and question
    public class FlexNoteQuestionRelationWrapper{
        public FlexNoteQuestion__c flexNoteQuestion{get;set;}
        public ServiceRequestTypeFlexNote__c sRFlexNoteRelation{get;set;}
        
        public FlexNoteQuestionRelationWrapper(FlexNoteQuestion__c flexNoteQuestion,ServiceRequestTypeFlexNote__c sRFlexNoteRelation){
            this.flexNoteQuestion=flexNoteQuestion;
            this.sRFlexNoteRelation=sRFlexNoteRelation;
        }
    }
    
    
    
    // this container for holding all the data with together
    public class SRTFlexNoteQuestionRelationWrapper{
        public ServiceRequestType__c sRType{get;set;}
        public list<FlexNoteQuestionRelationWrapper>flexNoteRelationList{get;set;}
        public SRTFlexNoteQuestionRelationWrapper(ServiceRequestType__c sRType){
            this.sRType=sRType;
            this.flexNoteRelationList=new list<FlexNoteQuestionRelationWrapper>();
        }
    
    }
    
    /*-------Pagination for FlexNotes---------*/
    /**
     * Beginning
     * 
     * Go to the beginning of the service requests.
     * @author Darkis
     */
   public PageReference Beginning() { //user clicked beginning
      flexnote_list_counter = 0;
      return null;
   }
 
    /**
     * Previous
     * 
     * Go to the previous subset of the service requests.
     * @author Darkis
     */
   public PageReference Previous() { //user clicked previous button
      flexnote_list_counter -= flexnote_list_size;
      return null;
   }
 
    /**
     * Next
     * 
     * Go to the next subset of the service requests.
     * @author Darkis
     */
   public PageReference Next() { //user clicked next button
      flexnote_list_counter += flexnote_list_size;
      // Maximum SOQL offset is 2000. Ensure it never goes above this.
      if (flexnote_list_counter > 2000) {
        flexnote_list_counter = 2000;     
      } 
      return null;
   }
 
    /**
     * End
     * 
     * Go to the end of the service requests.
     * @author Darkis
     */
   public PageReference End() { //user clicked end
      flexnote_list_counter = flexnote_list_total_size - math.mod(flexnote_list_total_size, flexnote_list_size);
      // Maximum SOQL offset is 2000. Ensure it never goes above this.
      if (flexnote_list_counter > 2000) {
        flexnote_list_counter = 2000;     
      }
      return null;
   }
 
    /**
     * getDisablePrevious
     * 
     * Determine if the previous button should be enabled. 
     * @author Darkis
     */
   public Boolean getDisablePrevious() { 
      //this will disable the previous and beginning buttons
      if (flexnote_list_counter>0) return false; else return true;
   }
 
    /**
     * getDisableNext
     * 
     * Determine if the previous button should be enabled. 
     * @author Darkis
     */ 
   public Boolean getDisableNext() { //this will disable the next and end buttons
      if (flexnote_list_counter + flexnote_list_size < flexnote_list_total_size) return false; else return true;
   }
    
       /**
     * get
     * 
     * Get the page number the user is currently on.
     * @author Darkis
     */
   public Integer getPageNumber() {
      return flexnote_list_counter/flexnote_list_size + 1;
   }
 
    /**
     * getTotalPages
     * 
     * Get the total number of pages available.
     * @author Darkis
     */
   public Integer getTotalPages() {
     if (math.mod(flexnote_list_total_size, flexnote_list_size) > 0) {
       return flexnote_list_total_size/flexnote_list_size + 1;
     } else {
       return (flexnote_list_total_size/flexnote_list_size);
     }
   }
}