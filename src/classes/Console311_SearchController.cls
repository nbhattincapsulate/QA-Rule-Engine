public class Console311_SearchController {


  public String searchString { get; set; }
  public Map<String, SobjectsWrapper> serachResults { get; set; }
  public String resultsExist { get; set; }
  public String errorMsg { get; set; }
  public Boolean prepopulated { get; set; }

  public Console311_SearchController() {
    String queryParam = Apexpages.currentpage().getparameters().get('query');
    prepopulated = false;

    if (!String.isBlank(queryParam)) {
      searchString =queryParam;
      prepopulated = true;
      doSearch();
    }
  }

  public List<String> getObjectList() {
    Console311Settings__c myCS = Console311Settings__c.getValues('ObjectsToSearch');
    String objects = myCS.Value__c;
    List<String> objectList = objects.split(';');
    System.debug('objectList ' + objectList);
    return objectList;

  }

  public String getDataTableSettings() {
    Map<String, Console311DatatableSettings__c> dataTableCS = Console311DatatableSettings__c.getAll();
    String jsonMsg = JSON.serialize(dataTableCS);
    System.debug('jsonMsg: ' + jsonMsg);
    return jsonMsg;

  }

  public Boolean getDataTableEnabled() {
    Console311Settings__c myCS = Console311Settings__c.getValues('EnableDataTable');
    String dataTableFlag = myCS.Value__c;
    System.debug('Datatable Enabled ' + dataTableFlag);
    return Boolean.valueOf(dataTableFlag);

  }

  public void doSearch() {
    resultsExist = 'No';
    errorMsg = '';
    serachResults = new Map<String, SobjectsWrapper> ();

    List<List<sObject>> searchList = null;
    try {
      System.debug('searchString: ' + searchString);
      String searchQuery = 'FIND \'' + string.escapesingleQuotes(searchString) + '*\' IN ALL FIELDS RETURNING ';

      Map<String, Console311Settings__c> searchCS = Console311Settings__c.getAll();
      String objectsToSearch = searchCS.get('ObjectsToSearch').value__c;
      String fieldSetName = searchCS.get('FieldSetName').value__c;
      Integer limitRows = Integer.valueOf(searchCS.get('Limit').value__c);

      System.debug('objectsToSearch : ' + objectsToSearch);
      System.debug('fieldSetName : ' + fieldSetName);
      System.debug('limitRows : ' + limitRows);

      List<String> objectList = objectsToSearch.split(';');
      System.debug('objectList : ' + objectList);

      for (String objectName : objectList) {
        searchQuery += ' ' + objectName + ' (';
        List<Schema.FieldSetMember> fieldSetMemberList = Console311_Util.readFieldSet(fieldSetName, objectName);
        String fieldList = '';

        for (Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
        {
          fieldList += fieldSetMemberObj.getFieldPath() + ',';
        }
        fieldList = fieldList.removeEnd(',');
        searchQuery += fieldList + ') ,';
      }
      searchQuery = searchQuery.removeEnd(',');
      If (limitRows != 0) searchQuery += ' LIMIT ' + limitRows;
      System.debug('Final searchQuery : ' + searchQuery);

      searchList = search.query(searchQuery);
      for (Integer index = 0; index < objectList.size(); index++) {
        SobjectsWrapper wrapper = new SobjectsWrapper();
        wrapper.records = searchList[index];
        serachResults.put(objectList[index], wrapper);
        if (searchList[index].size() > 0) resultsExist = 'Yes';
      }
      System.debug('serachResults Map size : ' + serachResults.size());

    }
    catch(Exception e) {
      System.debug('Exception : ' + e);
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
      resultsExist = '';
      errorMsg = e.getMessage();
      //return null;
    }

    // return serachResults;
  }

  public class SobjectsWrapper {
    public List<SObject> records { get; set; }
    public Integer size { get { return records.size(); } set; }

  }
}