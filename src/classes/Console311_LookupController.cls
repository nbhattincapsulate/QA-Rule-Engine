public class Console311_LookupController {

    public String sObjectName {get;set;}
    public String sObjectSortField {get;set;}
    public String formattedSortName {get;set;}
    public String queryStr {get;set;}
    public List<SObject> queryResults {get;set;}
    
    public Console311_LookupController() {
      sObjectName = ApexPages.currentPage().getParameters().get('sobject');
      sObjectSortField = ApexPages.currentPage().getParameters().get('sortfield');
      
      formattedSortName = sObjectSortField.replaceAll('_c', ' ');
      formattedSortName = formattedSortName.replaceAll('_', ' ');
      
      queryResults = new List<SObject>();
    }
    
    public PageReference query() { 
      try {
        String query = 'Select Id, ' + sObjectSortField + ' From ' + sObjectName + ' Where ' + sObjectSortField + ' Like \'' + queryStr + '%\' LIMIT 10000';
        queryResults = Database.query(query);
      } catch (Exception e) {
        System.debug('Error: ' + e.getMessage());
      }
      return null;  
    }
    
}