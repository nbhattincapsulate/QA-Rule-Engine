public class QuestionMultiPickListWrapper {
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