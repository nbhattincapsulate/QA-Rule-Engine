public with sharing class APIValidations {

  /*
    This class will contain all the validations that needs to be applied
    ---- Add all the custom validations here ---
   */


  public static Boolean isValidJuridiction(String jId) {
    //List<Jurisdiction__c> juri = [select id from Jurisdiction__c where Name=:jId];

    string validJurisdiction = 'dc.gov';
    if (jId.equalsIgnoreCase(validJurisdiction) || String.IsBlank(jId)) 
     	return true;
    else
    	return false;
  }

  public static APIKeyResponse validateKey(String key) {

    List<Open311ApiKeyConfig__c> keyConfig = [Select Id, Name, ApiKey__c, Available_SR_Types_For_GET__c, Available_SR_Types_For_POST__c, Available_SR_Types_For_PUT__c, isCommentsRequired__c, Private__c, Lock_FlexNotes__c, Lock_Activities__c, Usage_Limit_Allocation__c, Usage_Limit_Used__c, Usage_Limit_Reset_Date__c FROM Open311ApiKeyConfig__c WHERE ApiKey__c = :key];

    Open311ApiKeyConfig__c validKey;

    if (keyConfig.size() > 0) {
      for (Open311ApiKeyConfig__c k : keyConfig) {
        if (key.equals(k.ApiKey__c)) {
          validKey = k;
          break;
        }
      }
    }

    APIKeyResponse response = new APIKeyResponse();
    response.isValid = false;
    response.apiKey = key;
    if (keyConfig.size() > 0 && validKey != null) {
      response.isValid = true;
      response.name = keyConfig[0].Name;
      response.isPublic = !keyConfig[0].Private__c;
      response.isPrivate = keyConfig[0].Private__c;
      response.flexNotesLocked = keyConfig[0].Lock_FlexNotes__c;
      response.activitiesLocked = keyConfig[0].Lock_Activities__c;
      response.isCommentsRequired = keyConfig[0].isCommentsRequired__c;
      response.usageLimit = keyConfig[0].Usage_Limit_Allocation__c;
      response.usageLimitUsed = keyConfig[0].Usage_Limit_Used__c;
      response.usageLimitResetDate = keyConfig[0].Usage_Limit_Reset_Date__c;
      APIValidations.setupAvailableSRTypes(keyConfig[0].Available_SR_Types_For_GET__c, response.availableSRTypesToQueryForGET);
      APIValidations.setupAvailableSRTypes(keyConfig[0].Available_SR_Types_For_POST__c, response.availableSRTypesToQueryForPOST);
      APIValidations.setupAvailableSRTypes(keyConfig[0].Available_SR_Types_For_PUT__c, response.availableSRTypesToQueryForPUT);
    }
    return response;
  }
    
  public static void setupAvailableSRTypes(String availableTypesStr, Set<String> querySet) {  
    if (String.isNotBlank(availableTypesStr)) {
      // If the field is a CSV of types.
      if (availableTypesStr.contains(',')) {
        List<String> allowedTypesToQueryList = availableTypesStr.split(',');
        // Loop through the available types to create an allowed mapping.
        for (String srType : allowedTypesToQueryList) {
          querySet.add(srType);
        }
      } else {
        // If only one type exists.
        querySet.add(availableTypesStr);
      }
    }    
  }

  public class APIKeyResponse {
    public Boolean isValid { get; set; }
    public Boolean isPublic { get; set; }
    public Boolean isPrivate { get; set; }
    public Boolean flexNotesLocked { get; set; }
    public Boolean activitiesLocked { get; set; }
    public String apiKey { get; set; }
    public String name { get; set; }
    public Boolean isCommentsRequired { get; set; }
    public Decimal usageLimit { get; set; }
    public Decimal usageLimitUsed { get; set; }
    public Date usageLimitResetDate { get; set; }
    public Set<String> availableSRTypesToQueryForGET { get; set; }
    public Set<String> availableSRTypesToQueryForPOST { get; set; }
    public Set<String> availableSRTypesToQueryForPUT { get; set; }
    public String httpMethod { get; set; }

    public APIKeyResponse() {
      isValid = false;
      isPublic = false;
      isPrivate = false;
      flexNotesLocked = false;
      activitiesLocked = false;
      isCommentsRequired = false;
      usageLimit = 0;
      usageLimitUsed = 0;
      availableSRTypesToQueryForGET = new Set<String>();
      availableSRTypesToQueryForPOST = new Set<String>();
      availableSRTypesToQueryForPUT = new Set<String>();
      httpMethod = '';
    }

    public Set<String> getSRTypesToQueryForHttpMethod(String httpMethod) {
      if (httpMethod.equalsIgnoreCase('get')) {
        return availableSRTypesToQueryForGET;
      } else if (httpMethod.equalsIgnoreCase('post')) {
        return availableSRTypesToQueryForPOST;
      } else if (httpMethod.equalsIgnoreCase('put')) {
        return availableSRTypesToQueryForPUT;
      }
      return new Set<String>();
    }
  }


}