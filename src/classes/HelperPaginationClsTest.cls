@isTest
public class HelperPaginationClsTest {
  
  public static testMethod void testPagination(){
    string queryStr='select id,name,Object__c,Service_Name__c from ServiceRequestType__c ORDER BY Service_Name__c';
    string objectName='ServiceRequestType__c';
    integer noOfRows=10;
    HelperPaginationCls hp=new HelperPaginationCls(queryStr,objectName,noOfRows);
    
    list<sObject>recordList=hp.getRecords();
    integer currentPageNo=hp.getCurrentPage();
    
    integer totalSize=hp.getTotalPages();
    
    list<sObject>firstPageList=hp.getFirstPage();
     
    hp.getQueryString();
    integer pageSizeNo=hp.getPageSize();
    
    boolean hasNextPage=hp.hasNextPage();
    
    boolean hasPreviousPage=hp.hasPreviousPage();
    
    //boolean hasLastPage=hp.getLastPage(); 
    
    list<sObject>lastPageList=hp.getLastPage();
    
    list<sObject>nextPageList=hp.nextPage();
    
    list<sObject>previousPageList=hp.previousPage();
  }
  /*
  public static testMethod Void testNegativeValuesInPagination(){
    string queryStr='select id,name,Object__c,Service_Name__c from ServiceRequestType__c ORDER BY Service_Name__c';
    string objectName='ServiceRequestType__c';
    integer noOfRows=10;
    HelperPaginationCls hp=new HelperPaginationCls(queryStr,objectName,noOfRows);
  }*/
}