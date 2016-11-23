@isTest
public class Open311_SecurityDetailsExtensionTest {
  
  public static testMethod void testOpen311_SecurityDetailsExtension() { 
    TestHelper.createData();

    List<Open311ApiKeyConfig__c> config = [Select Id, Available_SR_Types_For_GET__c, Available_SR_Types_For_PUT__c, Available_SR_Types_For_POST__c From Open311ApiKeyConfig__c Limit 1];

    if (config != null && config.size() == 1) {
      Open311_SecurityDetailsExtension ext = new Open311_SecurityDetailsExtension(new ApexPages.StandardController(config.get(0))); 
      System.assertEquals(0, ext.SRTypeOptionsByHttpMethodMap.get('get').get('selectedTypes').options.size());

      config.get(0).Available_SR_Types_For_GET__c = 'DMV19,';
      upsert config;

      List<ServiceRequestType__c> typeList = [Select Id, Allow_Citizen_Web_Intake__c From ServiceRequestType__c Where Name = 'DMV19'];

      if (typeList.size() > 0) {
        typeList.get(0).Allow_Citizen_Web_Intake__c = true;
        update typeList;

        ext = new Open311_SecurityDetailsExtension(new ApexPages.StandardController(config.get(0))); 
        ext.requestedHttpType = 'get';
        ext.picklistChanged();
      }
    }
  }
}