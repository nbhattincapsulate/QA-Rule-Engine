public with sharing class HelperPaginationCls {
    /*  
    *   HelperPaginationCls Component is Utility Class for Pagination  
    *   Replace Methods Description here
    *   CreatedBy:D M
    *   Copyright ©   All rights reserved.
    */ 
    
    /* Custom Pagination*/
    private string soqlQuery;
    private string objectName;
    private integer pageSize;
    private integer offsetNum;
    private integer recordsCount;
    private list<sObject>recordList;
    private Boolean hasNext;
    private Boolean hasPrevious; 
    private Integer pageNumber;
    // constructor
    public HelperPaginationCls(string soqlString,string objectName,integer pageSize){
        this.objectName=objectName;
        this.soqlQuery =soqlString;
        recordList=new list<sObject>();
        if(null==pageSize || 0==pageSize)pageSize=4;
        this.pageSize=pageSize;
        
        offsetNum=0;
        recordsCount = 0;
        pageNumber = 1;
        hasNext = false;
        hasPrevious = false;
        
        try{
            getRecordCount();
        }catch(QueryException e){
        // no records found
            recordsCount = 0;
        }
        
    }
    private string getSoqlQuery(string tempSoqlStr,string objectNameStr){
        // select id,name from object where 
        integer objectIndex=objectNameStr.lastIndexOf(objectNameStr);
        string tempStr=tempSoqlStr.substring(0, objectIndex);
        system.debug('objectIndex--'+objectIndex);
        
        return tempStr;
    }
    
    
    // retreiveing  records based 
    public list<sObject>getRecords(){
        
        if(recordsCount == 0) return new List<Sobject>();
        String soqlString = this.soqlQuery + ' LIMIT ' + pageSize;
        if(offsetNum > 0)
        soqlString = soqlString + ' OFFSET ' + offsetNum;          
        
        recordList = Database.query(soqlString);

        return recordList;
    }
    

    public Integer getRecordCount(){
        String soqlString = 'SELECT count() ' + this.soqlQuery.subString(this.soqlQuery.lastIndexOfIgnoreCase('from ' + objectName));
        if(soqlString.toLowerCase().contains('order by'))
            soqlString = soqlString.substring(0, soqlString.ToLowerCase().indexOf('order by'));
        try{
            recordsCount = Database.countQuery(soqlString + ' LIMIT 50000');
        }catch(Exception e){
            recordsCount = 0;
        }
    
        return recordsCount; 
    }
    
    public list<sobject> nextPage(){
        offsetNum = offsetNum + pageSize; 
        if(pageNumber < getTotalPages())
            pageNumber++;
        return getRecords();
    }
    
    public list<sobject> previousPage(){
        offsetNum = offsetNum - pageSize;
        if(pageNumber > 1)
            pageNumber--;
        return getRecords();
    }
    
    public Boolean hasNextPage(){
        if(offsetNum + recordList.size() >= recordsCount)  return false;
        return true;    
    }
    
    public Boolean hasPreviousPage(){    
        if(offsetNum == 0) return false;
        return true;
    }
    
    public Integer getCurrentPage(){
        return pageNumber;  
    }
    
    public Integer getTotalPages(){
        return (math.mod(recordsCount, pageSize) > 0) ? Integer.valueOf(Math.floor(recordsCount/pageSize)) + 1 : recordsCount/pageSize;
    }
    
    public List<Sobject> getFirstPage(){
        pageNumber = 1;
        offsetNum = 0;
        return getRecords();
    }
    
    public List<Sobject> getLastPage(){
        offsetNum = (getTotalPages()-1) * pageSize;
        pageNumber = getTotalPages();
        return getRecords();
    }
    
    public String getQueryString(){ return this.soqlQuery; }

    public Integer getPageSize(){ return this.pageSize; }
    
    // need to remove once testing done 
    /*
    //public integer pageRows;
    
    public ApexPages.StandardSetController con;
    
    public ApexPages.StandardSetController getCon(string queryStr){
        if(queryStr==null)return null;
        if (con==null){
            con=new ApexPages.StandardSetController(Database.getQueryLocator(queryStr));
            //con.setPageSize(pageRows);
        }
        system.debug('list of records-->'+con);
        return con;
    }
    
    public boolean hasNext(){
        return con.getHasNext();
    }
    
    public boolean hasPrevious(){
        return con.getHasPrevious();
    }
    
    public void firstPage(){
        con.first();
    }
    
    public void lastPage(){
        con.last();
    }
    
    public void nextPage(){
        con.next();
    }
    
    public void previousPage(){
        con.previous();
    }
    
    public integer getPageNum(){
        return con.getPageNumber();
    }
    
    public integer getTotalPageSize(){
        return con.getPageSize();
    }
        
    public void setPageNum(integer pageRows){
        con.setPageSize(pageRows);
    }

    */
    
    
    
    
}