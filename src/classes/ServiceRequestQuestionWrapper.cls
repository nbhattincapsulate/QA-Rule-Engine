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