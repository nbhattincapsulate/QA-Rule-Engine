public class Console311_Util {

  public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
    Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
    Schema.SObjectType SObjectTypeObj = globalDescribeMap.get(ObjectName);
    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

    //system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));

    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

    //List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
    //system.debug('fieldSetMemberList ====>' + fieldSetMemberList);  
    return fieldSetObj.getFields(); 
  } 

   /**
   * getPicklistValues
   * 
   * This function will return a select option list of picklist values using a passed in object and field name.
   * @author Darkis
   * @param obj SObject The object to grab the picklist values from.
   * @param fld String The field name where the picklist values are stored in the object.
   * @return List<SelectOption> A list of select options for visualforce. 
   */  
  public static list<SelectOption> getPicklistValues(SObject obj, String fld){
    list<SelectOption> options = new list<SelectOption>();
    // Get the object type of the SObject.
    Schema.sObjectType objType = obj.getSObjectType(); 
    // Describe the SObject using its object type.
    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
    // Get a map of fields for the SObject
    map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
    // Get the list of picklist values for this field.
    list<Schema.PicklistEntry> values =
    fieldMap.get(fld).getDescribe().getPickListValues();
    // Add these values to the selectoption list.
    for (Schema.PicklistEntry a : values) { 
      options.add(new SelectOption(a.getLabel(), a.getValue())); 
    }
    return options;
  }
    
  /**
   * getStatesByCountry
   * 
   * This function will return a select option list of state values for a specified country.
   * @author Darkis
   * @param String countryCode The code for the country desired.
   * @return List<SelectOption> A list of select options for visualforce. 
   */  
  public static list<SelectOption> getStatesByCountry(String countryCode){
    list<SelectOption> options = new list<SelectOption>();
    // Get the object type of the SObject.
    Schema.sObjectType objType = Contact.getSObjectType(); 
    // Describe the SObject using its object type.
    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
    // Get a map of fields for the SObject
    map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
    // Get the list of picklist values for this field.
    list<Schema.PicklistEntry> values =
    fieldMap.get('MailingStateCode').getDescribe().getPickListValues();
    System.debug('----> State Codes');
    // Add these values to the selectoption list.
    for (Schema.PicklistEntry a : values) {
      System.debug('----> State: ' + a);
      options.add(new SelectOption(a.getLabel(), a.getValue())); 
    }
    return options;
  }
}