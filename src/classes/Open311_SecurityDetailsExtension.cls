public class Open311_SecurityDetailsExtension {
  // Private Level Variables.
  private ApexPages.StandardController ctrl { get; set; }
  // Extension Variables.  
  public Open311ApiKeyConfig__c configObj { get; set; }
  // General Variables.
  public String requestedHttpType { get; set; }
  public List<SelectOption> SRTypeOptions { get; set; }
  public final List<String> httpMethodsAvailable { get; set; }
  public Map<String, Map<String, OptionsList>> SRTypeOptionsByHttpMethodMap { get; set; }
  public Boolean objNeedsUpdating { get; set; }

  // Constructor
  public Open311_SecurityDetailsExtension(ApexPages.StandardController ctrl) {
    this.ctrl = ctrl;
    this.configObj = (Open311ApiKeyConfig__c) ctrl.getRecord();
    this.SRTypeOptions = new List<SelectOption> ();
    this.SRTypeOptionsByHttpMethodMap = new Map<String, Map<String, OptionsList>> ();
    this.httpMethodsAvailable = new List<String> { 'get', 'post', 'put' };
    // Collect all the service types from the Object.  
    List<ServiceRequestType__c> serviceTypesList = [Select Id, Name, Service_Name__c From ServiceRequestType__c ORDER BY Service_Name__c ASC];
    Map<String, String> serviceTypeCodeToFullname = new Map<String, String> ();
    // Place all the types into a select option list for the widget.
    for (ServiceRequestType__c type : serviceTypesList) {
      SRTypeOptions.add(new SelectOption(type.Name, type.Service_Name__c));
      serviceTypeCodeToFullname.put(type.Name, type.Service_Name__c);
    }
    // Set a mapping for each of the http methods with a base set of all types AND a selected list.
    for (String method : httpMethodsAvailable) {
      List<SelectOption> methodDefaultOptions = new List<SelectOption> ();
      // Create the default mapping for available and selected types.
      Map<String, OptionsList> tempDefaultMap = new Map<String, OptionsList> ();
      // Create a default wrapper for the full options list.
      OptionsList tempOptWrapper = new OptionsList();
      // Get the exisiting string list of types.
      String tempStringList = String.valueOf(configObj.get('Available_SR_Types_For_' + method + '__c'));
      System.debug('----> Exisiting Type List for [' + method + ']: ' + tempStringList);
      // If the exisiting list is not empty.
      if (String.isNotBlank(tempStringList)) {
        // Split it and create an options list.
        List<String> tempTypeList = tempStringList.split(',');
        OptionsList optList = new OptionsList();
        Set<String> exisitingTypeSet = new Set<String> ();
        String currentAvailableTypeCodeListStr = '';
        // Loop through the types and populate the list.  
        for (String type : tempTypeList) {
          System.debug('----> [Open311_SecurityDetailsExtension] tempTypeList => type: ' + type);
          if (serviceTypeCodeToFullname.containsKey(type)) {
            optList.push(new SelectOption(type, serviceTypeCodeToFullname.get(type)));
            exisitingTypeSet.add(type);
            // Add the type into a list of usable types.
            currentAvailableTypeCodeListStr += type + ',';
          }
        }
        System.debug('----> [Open311_SecurityDetailsExtension] currentAvailableTypeCodeListStr: ' + currentAvailableTypeCodeListStr);
        System.debug('----> [Open311_SecurityDetailsExtension] tempStringList: ' + tempStringList);
        // If the usable types provided are the same as the list on the object, meaning none have been removed from switching their flag, then update the object field.
        if (!currentAvailableTypeCodeListStr.equalsIgnoreCase(tempStringList)) {
          System.debug('----> [Open311_SecurityDetailsExtension] Two lists are NOT the same. Update the field for the method to match.');
          configObj.put('Available_SR_Types_For_' + method + '__c', currentAvailableTypeCodeListStr);
          objNeedsUpdating = true;
        }

        // Loop through the default options and determine if all are necessary.
        for (SelectOption defaultOpt : SRTypeOptions) {
          if (!exisitingTypeSet.contains(defaultOpt.getValue())) {
            tempOptWrapper.push(defaultOpt);
          }
        }
        // Set the lists to the mapping.
        tempDefaultMap.put('availableTypes', tempOptWrapper);
        tempDefaultMap.put('selectedTypes', optList);
      } else {
        // Push the default list of types.
        tempOptWrapper.pushList(SRTypeOptions);
        // Add the lists to the mapping.
        tempDefaultMap.put('availableTypes', tempOptWrapper);
        tempDefaultMap.put('selectedTypes', new OptionsList());
      }
      // Add the new default map to the method type.
      SRTypeOptionsByHttpMethodMap.put(method, tempDefaultMap);
    }
  }

  public PageReference updateConfigReference() {
    ctrl.save();
    return null;
  }

  /**
   * picklistChanged
   * 
   * @description This function will collect and store all the new values placed into a methods restricted service types.
   * @author Darkis
   * @param requestedHttpType String The type that needs to have this service type applied. 
   */
  public PageReference picklistChanged() {
    configObj = [Select Id, Available_SR_Types_For_GET__c, Available_SR_Types_For_PUT__c, Available_SR_Types_For_POST__c From Open311ApiKeyConfig__c Where Id = :ctrl.getId()];
    ctrl = new ApexPages.StandardController(configObj);

    String selectedTypesStr = '';
    List<SelectOption> tempOptions = SRTypeOptionsByHttpMethodMap.get(requestedHttpType).get('selectedTypes').options;
    // Loop through the selected types and build a CSV string out of the results based on the requested type.    
    System.debug('----> Map: ' + SRTypeOptionsByHttpMethodMap);
    System.debug('----> Map[GET]: ' + SRTypeOptionsByHttpMethodMap.get('get'));
    System.debug('----> Requested HTTP Type: ' + requestedHttpType);
    if (tempOptions != null) {
      for (SelectOption typeName : SRTypeOptionsByHttpMethodMap.get(requestedHttpType).get('selectedTypes').options) {
        selectedTypesStr += typeName.getValue() + ',';
      }
    }
    System.debug('----> Selected Types for [' + requestedHttpType + ']: ' + selectedTypesStr);
    configObj.put('Available_SR_Types_For_' + requestedHttpType.toUpperCase() + '__c', selectedTypesStr);
    // Set the SR Types on the object and save the record.
    ctrl.save();
    return null;
  }

  /**
   * OptionsList
   * 
   * @description This wrapper class is used to help store our list of options to pass into the multi select component.
   * @author Darkis
   */
  public class OptionsList {
    public List<SelectOption> options { get; set; }

    public OptionsList() {
      this.options = new List<SelectOption> ();
    }

    public void push(SelectOption opt) {
      this.options.add(opt);
    }

    public void pushList(List<SelectOption> listOfOpts) {
      this.options.addAll(listOfOpts);
    }
  }
}