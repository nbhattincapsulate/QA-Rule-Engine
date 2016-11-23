public with sharing class FlexNoteQuestionAdminCntrl {
    /*  
    *   FlexNoteQuestionAdminCntrl Component Referred By FlexNoteQuestionAdminPge  
    *   Replace Methods Description here
    *   CreatedBy:D M                
    *   Copyright ?   All rights reserved.
    */     
                  
    // holds current flexnote question used to edit create 
    public FlexNoteQuestion__c flexNoteQuestion{get;set;}
    
    // holds flexnote question id passed as param   
    public string flexNoteQuestionId{get;set;}
    // Determines whether to show popup or not 
    public boolean showPopUp{get;set;}
    // determines mode create or edit
    public boolean isEditMode{get;set;}
    
    public list<FlexNoteQuestion__c>FlexNotesQuestionsList{get;set;}
    //public ApexPages.StandardSetController setCont{get;set;}
    
    HelperPaginationCls hPClass;
    
    private integer tempRowsToDisplay;
    
    private string isInvokedFrmSRType;
    private string isEditSRType;
    private Id sRTypeId;
    
    public list<string>alphaList{get;set;}
    public string filterStr{get;set;}
    
    // if no records then make tis to true
    public boolean isMsgRender{get;set;}
    // constructor
    public FlexNoteQuestionAdminCntrl(){
        tempRowsToDisplay=20;
        //Select f.Questions__c, f.Object_Name__c, f.Name, f.Code__c From FlexNoteQuestion__c f
        hPClass=new HelperPaginationCls('select id,Questions__c,Object_Name__c,Name,Answer_Type__c from FlexNoteQuestion__c ORDER BY CreatedDate DESC','FlexNoteQuestion__c',tempRowsToDisplay);
        FlexNotesQuestionsList=hPClass.getRecords();
        
         alphaList = new list<String> {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
        
        // if invoked from service request type for adding question
        isInvokedFrmSRType=Apexpages.currentPage().getParameters().get('isInvokedFrmSRType');
        isEditSRType=ApexPages.currentPage().getParameters().get('isEditSRType');
        sRTypeId=ApexPages.currentPage().getParameters().get('sRTypeId');
        if(isInvokedFrmSRType=='True'){
            doCreateFlexNoteQuestion();
        }
    }
    
/*Pagination Methods*/
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
        FlexNotesQuestionsList=hPClass.getFirstPage();
    }
    
    public void lastPage(){
        FlexNotesQuestionsList=hPClass.getLastPage();
    }
    
    public void nextPage(){
        FlexNotesQuestionsList=hPClass.nextPage();
    }
    
    public void previousPage(){
        FlexNotesQuestionsList=hPClass.previousPage(); 
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
    
    /*End Pagination Methods*/
    
    // invoked from create button   
    public pageReference doCreateFlexNoteQuestion(){
        flexNoteQuestion=new FlexNoteQuestion__c(Object_Name__c='Case'); 
        isEditMode=false;
        showPopUp=true;
        
        return null;
    }
    
    // invoked from edit button 
    public pageReference doEditFlexNoteQuestion(){
        if(flexNoteQuestionId==null)return null;
        FlexNoteQuestion__c tempflexNoteQuestion=[select id,Name,Questions__c,Answer_Type__c,AnswerValues__c,Hint_Text__c,List__c,
        Access_Classification__c,Start_Date__c,Stop_Date__c,Object_Name__c from FlexNoteQuestion__c where id=:flexNoteQuestionId];
        if (tempflexNoteQuestion==null)return null;
        flexNoteQuestion=tempflexNoteQuestion;
        // clearing flexNoteQuestionId 
        flexNoteQuestionId=null;
        isEditMode=true;
        showPopUp=true;
        return null;
    }
    
    // invoked from delete button
    public pageReference doDeleteFlexNoteQuestion(){
        if(flexNoteQuestionId==null)return null;
        FlexNoteQuestion__c tempflexNoteQuestion=[select id,Questions__c from FlexNoteQuestion__c where id=:flexNoteQuestionId];
        if (tempflexNoteQuestion==null)return null;
        try{
            delete(tempflexNoteQuestion);
            // reinitilize set controller
            //setCont=initPageSetController();
        }
        catch(exception e){
            system.debug('unable to complete delete due to -'+e);
        }
        // clearing flexNoteQuestionId 
        flexNoteQuestionId=null;
        // reinitization done again need to check this point later
        FlexNotesQuestionsList=hPClass.getRecords();
        return null;
    }   
    
    // invoked from save button
    public pageReference doSaveFlexNoteQuestion(){
        
        // validation check point
        if(doValidationCheck(flexNoteQuestion))return null;
        if(isValidDate(flexNoteQuestion))return null;
        savepoint sp1=database.setSavepoint();
        try{
        	if(flexNoteQuestion.AnswerValues__c!='' || flexNoteQuestion.AnswerValues__c!=null)flexNoteQuestion.AnswerValues__c=removeLineBreaks(flexNoteQuestion.AnswerValues__c);
        	
            if(flexNoteQuestion!=null){
                insert (flexNoteQuestion);
            }
            // if invoked from servicerequest type page 
            if(isInvokedFrmSRType=='True'){
                pageReference sRTypePge=Page.ServiceRequestAdminPge;
                sRTypePge.getParameters().put('isInvokedFrmFNQuestion','True');
                sRTypePge.getParameters().put('isEdit',isEditSRType);
                sRTypePge.getParameters().put('sRTypeId',sRTypeId);
                
                return sRTypePge;
            }
            isEditMode=null;
            showPopUp=false;
        }
        catch(exception e){
            system.debug('unable to complete insert Process due--'+e);
            ApexPages.addMessages(e);
            database.rollback(sp1);
        } 
        // reinitizalize need to check this point
        FlexNotesQuestionsList=hPClass.getRecords(); 
        return null;
    }
    
    // invoked from cancel button
    public pageReference doCancelFlexNoteQuestion(){
        // setting to null
        isEditMode=null;
        showPopUp=false;
        flexNoteQuestionId=null;
        
        // if invoked from servicerequest type page 
        
            if(isInvokedFrmSRType=='True'){
                pageReference sRTypePge=Page.ServiceRequestAdminPge;
                sRTypePge.getParameters().put('isEdit',isEditSRType);
                sRTypePge.getParameters().put('sRTypeId',sRTypeId);
                sRTypePge.getParameters().put('isInvokedFrmFNQuestion','True');
                return sRTypePge;
            }
        return null;
    }
    
    // invoked from update button
    public pageReference doUpdateFlexNoteQuestion(){
        // validation check point
        if(doValidationCheck(flexNoteQuestion))return null;
        if(isValidDate(flexNoteQuestion))return null;
        savepoint sp=database.setSavepoint();
        try{
        	if(flexNoteQuestion.AnswerValues__c!='' || flexNoteQuestion.AnswerValues__c!=null)flexNoteQuestion.AnswerValues__c=removeLineBreaks(flexNoteQuestion.AnswerValues__c);
        	
            if(flexNoteQuestion!=null){
                Update (flexNoteQuestion);
            }
            isEditMode=null;
            showPopUp=false;
        }
        catch(exception e){
            system.debug('unable to complete Update Process due--'+e);
            ApexPages.addMessages(e);
            database.rollback(sp);
        }
        // reinitialisze need to check this point later 
        FlexNotesQuestionsList=hPClass.getRecords();
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
        if((flexNoteQuest.Answer_Type__c=='Date' && flexNoteQuest.Answer_Values__c==null) || (flexNoteQuest.Answer_Type__c=='MultiPicklist' && flexNoteQuest.Answer_Values__c==null)){
            Apexpages.Message questionListMsg=new Apexpages.Message(apexpages.severity.Info,'Please Provide 8/13/2014 12:18 AM Values, Its Required.');
            ApexPages.addMessage(questionListMsg);
            return True;
        }*/
        // CHECKING FOR VALID DATE FORMAT 
        
        return false;
    }
    
    // validating correct date time format
    private Boolean isValidDate(FlexNoteQuestion__c fnQuestion){
       /* if(fnQuestion.Answer_Type__c=='Date/Time' && fnQuestion.AnswerValues__c!=null){
            // valid format 
                Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d) ([0-1]?[0-9]|[2][0-3]):([0-5][0-9]) (AM|PM)');
                Matcher MyMatcher = MyPattern.matcher(fnQuestion.AnswerValues__c);
                if(!MyMatcher.matches()){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Error: Valid Date Time Format is mm/dd/yyyy hh:mm AM/PM.');
                    ApexPages.addMessage(myMsg);
                    return true;
                }
        }  // commented on 0210
        if(fnQuestion.Answer_Type__c=='Date' && fnQuestion.AnswerValues__c!=null){
            // valid format 
                Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)');
                Matcher MyMatcher = MyPattern.matcher(fnQuestion.AnswerValues__c);
                if(!MyMatcher.matches()){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Error: Valid Date Format is mm/dd/yyyy.');
                    ApexPages.addMessage(myMsg);
                    return true;
                }
        }*/
        return false;
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
    
	public void doSearchByAlphabet(){
        system.debug('filterString ---->'+filterStr);
        if(filterStr==null)return ;
         //String queryStr='select id,Question__c,Name from FlexNoteQuestion__c ';
         String queryStr='select id,Questions__c,Object_Name__c,Name,Answer_Type__c from FlexNoteQuestion__c';
         queryStr+=' Where Name Like \''+string.escapesingleQuotes(filterStr)+ '%\' ORDER BY Name';
         hPClass=new HelperPaginationCls(queryStr,'FlexNoteQuestion__c',20);
         System.debug('results--->'+hPClass.getRecords());
         FlexNotesQuestionsList=hPClass.getRecords();
         
         if(FlexNotesQuestionsList.isEmpty()){
            Apexpages.Message Msg=new Apexpages.Message(apexpages.severity.Info,'There are No Records.');
            ApexPages.addMessage(Msg);
         }
    }
    
    
 	 private string removeLineBreaks(string inText){
	   if (inText == null)
	       return null;
	   else
	       return inText.replaceAll('\r\n', '');
	 }
    
    
    
    
        /*
    public ApexPages.StandardSetController setCont {
        get {
              if (setCont == null) setCont = initPageSetController();
              return setCont;
          }
        set;
    }
    
    private ApexPages.StandardSetController initPageSetController(){
        ApexPages.StandardSetController temSetContrl=hPClass.getCon('select id,Question__c,Name from FlexNoteQuestion__c');
        hPClass.setPageNum(tempRowsToDisplay);
        return temSetContrl;
    }
    
    
    // retrieving questions
    public list<FlexNoteQuestion__c>getFlexNotesQuestions(){
        list<FlexNoteQuestion__c>FlexNotesQuestionsList=new list<FlexNoteQuestion__c>();
        try{    
            for(FlexNoteQuestion__c questionItem: (list<FlexNoteQuestion__c>)hPClass.getRecords()){
                tempQuestionsList.add(questionItem);
            }
        }
        catch(exception e){
            system.debug('unable to complete Process of Query-->'+e);
        }   
        
        if (tempQuestionsList.isEmpty())return null;
        return tempQuestionsList;
    }

    /*public integer totalPages{
        get{
            decimal totalValue=decimal.valueof(TotalNumber/ setCont.getPageSize());
            return math.round(totalValue);
        }
        set;
    }
    */
}