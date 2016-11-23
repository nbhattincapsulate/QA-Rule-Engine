public with sharing class WorkflowRuleUtils {

  public static Map<String, Map<String, Schema.sObjectField>> objectByFieldSchemaMap;

  /*
   * @description : Sort the select options by its label  
   * @return List<SelectOption>  sorted selected options by its label
   */
  public static List<selectOption> selectOptionSortByLabel(List<selectOption> selectOptionsToSort) {
    if (selectOptionsToSort == null || selectOptionsToSort.size() <= 1) {
      return selectOptionsToSort;
    }
    List<SelectOption> lessSelectOption = new List<SelectOption> ();
    List<SelectOption> greaterSelectOption = new List<SelectOption> ();
    integer pivot = selectOptionsToSort.size() / 2;

    //save the pivot and remove it from the selectOption list
    SelectOption pivotValue = selectOptionsToSort[pivot];
    selectOptionsToSort.remove(pivot);
    for (selectOption SO : selectOptionsToSort) {
      if (SO.getLabel() <= pivotValue.getLabel()) {
        lessSelectOption.add(SO);
      } else if (SO.getLabel() > pivotValue.getLabel()) {
        greaterSelectOption.add(SO);
      }
    }
    List<selectOption> sortedSelectOptions = new List<selectOption> ();
    sortedSelectOptions.addAll(selectOptionSortByLabel(lessSelectOption));
    sortedSelectOptions.add(pivotValue);
    sortedSelectOptions.addAll(selectOptionSortByLabel(greaterSelectOption));
    return SortedSelectOptions;
  }

  /*
   * @description : return child object list
   * @return List<SelectOption>  sorted selected options by its label
   */
  public static List<SelectOption> populateChildObjects(String objType) {
    /**
     * Get list of child objects of object on which rule is defined
     **/
    List<SelectOption> objOptions = new List<SelectOption> ();
    Schema.DescribeSObjectResult objinfo = null;
    Map<String, Schema.SObjectType> mapObj = Schema.getGlobalDescribe();
    Schema.SObjectType sobj = mapObj.get(objType);
    objinfo = sobj.GetDescribe();

    List<Schema.ChildRelationship> listChild = sobj.getDescribe().getChildRelationships();
    /*
      building a name is a format objName~relationshipName
      as there could be more than one lookup to same object
     */
    objOptions.add(new SelectOption(objInfo.getName(), objInfo.getLabel()));

    for (Schema.ChildRelationship child : listChild) {
      Schema.DescribeSObjectResult descRes = child.getChildSObject().getDescribe();
      if (child.getRelationshipName() != null) {
        objOptions.add(new SelectOption(descRes.getName() + '~' + child.getRelationshipName(), descRes.getLabel()));
      }
    }
    return objOptions;
  }

  /*
   * @description : return valid operator list for a given field type
   * @return List<SelectOption>
   */
  public static List<SelectOption> populateOperators(DisplayType fieldtype) {
    List<SelectOption> options = new List<SelectOption> ();

    if (fieldType != Schema.DisplayType.anyType && fieldType != Schema.DisplayType.base64 && fieldType != Schema.DisplayType.EncryptedString && fieldType != Schema.DisplayType.Id)
    {
      options.add(new selectOption('Equals', 'Equals'));
      options.add(new selectOption('Not Equal To', 'Not Equal To'));
      //options.add(new selectOption('Is Null','Is Null'));
      //options.add(new selectOption('Is Not Null','Is Not Null'));

      if (fieldType != Schema.DisplayType.String && fieldType != Schema.DisplayType.Email && fieldType != Schema.DisplayType.Boolean && fieldType != Schema.DisplayType.Picklist && fieldType != Schema.DisplayType.Reference && fieldType != Schema.DisplayType.TextArea) {
        //boolean can't use the below, but the others can
        options.add(new selectOption('Greater Than', 'Greater Than'));
        options.add(new selectOption('Less Than', 'Less Than'));
        options.add(new selectOption('Greater Or Equal', 'Greater or Equal'));
        options.add(new selectOption('Less Or Equal', 'Less or Equal'));
        //options.add(new selectOption('Between','Between'));
        //options.add(new selectOption('Not Between','Not Between'));
      }

      if (fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.Email || fieldType == Schema.DisplayType.Reference || fieldType == Schema.DisplayType.ComboBox || fieldType == Schema.DisplayType.Picklist || fieldType == Schema.DisplayType.email || fieldType == Schema.DisplayType.Phone || fieldType == Schema.DisplayType.url || fieldType == Schema.DisplayType.TextArea) { //if 4
        //these opOption are for string type fields
        options.add(new selectOption('Contains', 'Contains'));
        options.add(new selectOption('Does Not Contain', 'Does Not Contain'));
        options.add(new selectOption('Starts With', 'Starts With'));
        options.add(new selectOption('Ends With', 'Ends With'));
        options.add(new selectOption('Does Not Start With', 'Does Not Start With'));
        options.add(new selectOption('Does Not End With', 'Does Not End With'));
        //options.add(new selectOption('Includes','Includes')); 
        //options.add(new selectOption('Excludes','Excludes')); 


        if (fieldType == Schema.DisplayType.Phone) {
          options.add(new selectOption('Greater Than', 'Greater Than'));
          options.add(new selectOption('Greater Or Equal', 'Greater or Equal'));
        }

      }

    } //end outer if

    return options;
  }


  public static list<SelectOption> populatePicklistValues(sObjectType objtyp, String fld)
  {
    list<SelectOption> opt = new list<SelectOption> ();

    Schema.DescribeSObjectResult objDescrib = objTyp.getDescribe();
    map<String, Schema.SObjectField> fieldMaps = objDescrib.fields.getMap();
    list<Schema.PicklistEntry> values = fieldMaps.get(fld).getDescribe().getPickListValues();
    for (Schema.PicklistEntry a : values)
    {
      opt.add(new SelectOption(a.getLabel(), a.getValue()));
    }
    return opt;
  }

  /*
   * @description : Create a map of object to its field schema  
   * @return Map<String, Map<String, Schema.sObjectField>> map of object to its field schema  
   */
  public static Map<String, Map<String, Schema.sObjectField>> getSchemaMap(String objectName) {
    if (objectByFieldSchemaMap == null) objectByFieldSchemaMap = new Map<String, Map<String, Schema.sObjectField>> ();
    if (objectByFieldSchemaMap.containsKey(objectName)) return objectByFieldSchemaMap;

    // Creta a map
    Map<String, Schema.sObjectField> mapFieldSchema = new Map<String, Schema.sObjectField> ();

    // Create a map 
    for (Schema.sObjectField objField : Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().values()) {
      mapFieldSchema.put(objField.getDescribe().getName().toLowerCase(), objField);
    }

    // Put the field schema to map schema
    objectByFieldSchemaMap.put(objectName, mapFieldSchema);
    return objectByFieldSchemaMap;
  }


  /*
   * @description : Create a select option(s) from the field schema for an sobject
   * @return List<SelectOption> List of fields for an object 
   */
  public static List<SelectOption> getFields(Map<String, Schema.sObjectField> mapFieldSchema) {
    List<SelectOption> options = new List<SelectOption> ();

    // Get all the objects in the org 
    for (Schema.sObjectField objField : mapFieldSchema.values()) {
      options.add(new SelectOption(objField.getDescribe().getName().toLowerCase(), objField.getDescribe().getLabel()));
    }
    return selectOptionSortByLabel(options);
  }

  /*
   * @description : Method used to convert string to Integer 
   * @return Integer converted Integer value 
   */
  public static Integer convertStringToInteger(String stringValue) {
    return Integer.valueOf(stringValue);
  }

  /*
   * @description : Method used to convert string to Double 
   * @return Double converted Double value 
   */
  public static Double convertStringToDouble(String stringValue) {
    return Double.valueOf(stringValue);
  }

  /*
   * @description : Method used to convert string to Boolean 
   * @return Boolean converted Boolean value 
   */
  public static Boolean convertStringToBoolean(String stringValue) {
    return Boolean.valueOf(stringValue);
  }

  /*
   * @description : Method used to convert string to Date 
   * @return Date converted Date value 
   */
  public static Date convertStringToDate(String stringValue) {
    return Date.valueOf(stringValue);
  }

  /*
   * @description : Method used to convert string to DateTime
   * @return DateTime converted DateTime value 
   */
  public static DateTime convertStringToDateTime(String stringValue) {
    return DateTime.valueOfGMT(stringValue);
  }

  // Return a 2D String array with headers on first row
  public static List<List<String>> parseCSV(String contents) {

    System.debug('## parseCSV called with contents = ' + contents);
    // Determine if it is split by newLine(\n) or return carriage(\r) or a \r\nn
    Boolean hasNewLine = false;
    Boolean hasCarrReturn = false;

    //First check for a \r\n char
    if (contents.contains('\r\n')) {
      System.debug('## Contains at least one \'\\r\\n\' character');
      hasNewLine = true;
      hasCarrReturn = false;
    }
    else {
      //If not then check for either a /r or /n
      if (contents.contains('\n')) {
        System.debug('## Contains at least one newline character');
        hasNewLine = true;
      }
      if (contents.contains('\r')) {
        System.debug('## Contains at least one carriage return character');
        hasCarrReturn = true;
      }
    }

    List<List<String>> allFields = new List<List<String>> ();
    if (hasNewLine && hasCarrReturn) {
      addError('The file contains both newline and carriage returns');
    }
    else {

      String splitBy = '\n';
      if (hasCarrReturn) {
        splitBy = '\r';
      }

      // replace instances where a double quote begins a field containing a comma
      // in this case you get a double quote followed by a doubled double quote
      // do this for beginning and end of a field
      contents = contents.replaceAll(',"""', ',"DBLQT').replaceall('""",', 'DBLQT",');
      // now replace all remaining double quotes - we do this so that we can reconstruct
      // fields with commas inside assuming they begin and end with a double quote
      contents = contents.replaceAll('""', 'DBLQT');
      // we are not attempting to handle fields with a newline inside of them
      // so, split on newline to get the spreadsheet rows
      List<String> lines = new List<String> ();
      try {
        lines = contents.split(splitBy);
      } catch(System.ListException e) {
        System.debug('## Limits exceeded?' + e.getMessage());
      }
      System.debug('## About to check ' + lines.size() + ' lines...');
      Integer num = 0;

      for (String line : lines) {
        System.debug('## Parsing line: ' + line);
        // Deal with lines where 
        //if (line.replaceAll(',','').trim().length() == 0) continue; 


        // TODO: Deal with lines where all fields empty. Currently splits into an empty array.

        List<String> fields = line.split(',', - 1);
        List<String> cleanFields = new List<String> ();
        String compositeField;
        Boolean makeCompositeField = false;
        System.debug('## About to read ' + fields.size() + ' fields...');
        for (String field : fields) {
          // Trim off any leading or ending whitespace. This is necessary as sometimes Windows will attach some for no reason.
          field = field.trim();

          if (field.startsWith('"') && field.endsWith('"')) {
            //System.debug('----> Field has 2 double quotes.');
            cleanFields.add(field.replaceAll('DBLQT', '"'));
          } else if (field.startsWith('"')) {
            //System.debug('----> Field STARTS with a double quote.');
            makeCompositeField = true;
            compositeField = field;
          } else if (field.endsWith('"')) {
            //System.debug('----> Field ENDS with a double quote.');
            compositeField += ',' + field;
            cleanFields.add(compositeField.replaceAll('DBLQT', '"'));
            makeCompositeField = false;
          } else if (makeCompositeField) {
            //System.debug('----> Field HAD started with a double quote but has not ended yet.');
            compositeField += ',' + field;
          } else {
            cleanFields.add(field.replaceAll('DBLQT', '"'));
          }
        }

        // Remove double quotes (if present) from start and end of each field
        List<String> noQuoteFields = new List<String> ();
        for (String field : cleanFields) {
          if (field.startsWith('"') && field.endsWith('"')) {
            field = field.substring(1, field.length() - 1);
          }
          noQuoteFields.add(field);
        }
        allFields.add(noQuoteFields);
      }
    }

    // Remove any rows before header row so that header row is first row:
    Integer headerRow = - 1;
    for (Integer i = 0; (i < allFields.size() && headerRow == - 1); i++) {
      // Determine if all fields in this row are non-blank:
      List<String> row = allFields.get(i);
      Boolean isHeaderRow = true;

      for (String field : row) {
        if (field == '') { // field is blank
          isHeaderRow = false;
        }
      }

      if (isHeaderRow) {
        headerRow = i;
      }
    }
    System.debug('## headerRow ' + headerRow);

    for (Integer i = 0; i < headerRow; i++) {
      allFields.remove(0);
    }

    System.debug('## About to return ' + allFields.size() + ' lines...');
    return allFields;
  }

  public static void addError(String error) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
	}
}