public class Email_CaseBulkDateController {

  public String caseId { get; set; }

  public Email_CaseBulkDateController() {
    
  }

  public String getBulkScheduleDate() {
    System.debug('----> Case Id: ' + caseId);
    System.debug('----> Page Param: ' + ApexPages.currentPage().getParameters().get('parentId'));
    List<Case> caseToFetchFlexnotes = [Select Id, CaseNumber, (Select Id, Questions__c, Order__c, FlexNote_Question__c, Answer_Date_Time__c, Answer__c From FlexNotes__r) From Case Where Id = :caseId];

    if (caseToFetchFlexnotes != null && caseToFetchFlexnotes.size() == 1) {
      System.debug('----> caseToFetchFlexnotes: ' + caseToFetchFlexnotes);
      for (FlexNote__c fNote : caseToFetchFlexnotes.get(0).FlexNotes__r) {
        System.debug('----> Fnote: ' + fNote);
        if (fNote.Questions__c.containsIgnoreCase('BULK COLLECTION DATE')) {
          return fNote.Answer__c;
        }
      }
    }
    return '';
  }
}