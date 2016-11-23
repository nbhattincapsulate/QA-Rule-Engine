public class QuestionAnswerWrapper {
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