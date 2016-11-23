@isTest
public class ServiceRequestsHelperTest {
  
  public static testMethod void testHandleDuplicateClosures() {
    TestHelper.createData();
        
    List<Case> parentCaseList = [Select Id, ContactId, SRType__c From Case Where Status = 'Open' Limit 1];
    List<ServiceRequestType__c> srTypeList = [Select Id From ServiceRequestType__c Where Name = 'DMV19' Limit 1];
        
    if (parentCaseList.size() == 1 && srTypeList.size() == 1) {
      Case parentCase = parentCaseList.get(0); 
      ServiceRequestType__c srType = srTypeList.get(0);  
        
      srType.DuplicateDetectionMethod__c = 'Standard';
      srType.DuplicateRadius__c = 1;
      srType.Duplicate_Threshold_Period__c = 55;
        
      parentCase.GeoLocation__Latitude__s = 38.933;
      parentCase.GeoLocation__Longitude__s = -76.963;
            
      Case dupCase1 = new Case(
        ParentId = parentCase.Id,
        Status = 'Duplicate (Opened)',
        SRType__c = srType.Id,
        ContactId = parentCase.ContactId,
        GeoLocation__Latitude__s = 38.933,
        GeoLocation__Longitude__s = -76.963
      );
        
       Case dupCase2 = new Case(
        ParentId = parentCase.Id,
        Status = 'Duplicate (Opened)',
        SRType__c = srType.Id,
        ContactId = parentCase.ContactId,
        GeoLocation__Latitude__s = 38.933,
        GeoLocation__Longitude__s = -76.963
      );
      
      Test.startTest();  
      update srType;
         
      List<Case> tempCaseList = new List<Case>();
      tempCaseList.add(parentCase);
      tempCaseList.add(dupCase1);
      tempCaseList.add(dupCase2);
      upsert tempCaseList;
      
      // Manually update the case to closed to trigger a duplicate check.
      parentCase.Status = 'Closed';
      update parentCase;
        
      Test.stopTest();
    }
  }
}