public class ContactCaseFlexNoteWrapper {
    
  public contact selContact{get;set;}
  public case selCase{get;set;}
  public ServiceRequestType__c sRType{get;set;}
  public list<FlexNote__c>SelectedFlexNoteList{get;set;}
  public list<OUC_Activity_History__c>selOUCActivity{get;set;} //2809
    
  public ContactCaseFlexNoteWrapper(contact selContact,ServiceRequestType__c sRType,case selCase, list<FlexNote__c>SelectedFlexNoteList){
    this.selContact=selContact;
    this.selCase=selCase;
    this.sRType=sRType;
    this.SelectedFlexNoteList=SelectedFlexNoteList;
    //this.selActivityHistory=new list<ActivityHistory>();
    this.selOUCActivity=new list<OUC_Activity_History__c>();
  }
}