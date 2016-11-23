/**
 * Class containing tests for cloneServiceRequestHistory
*/


@isTest
public class CloneHistoryObjectsTest{
    private static contact con;
    private static case caserecord;
    private static FlexNoteQuestion__c Fquestion;
    private static FlexNote__c flexnote;
    private static String caseId;
    private static Id srhId;   
    
    
    private static list<Id>caseIdsList;
    private static list<FlexNote__c>fnList;
    private static list<FlexNoteQuestion__c>fnQList;
    
    private static void createData(){
      //insert contact
      con=new contact(LastName='martin',FirstName='ricky',Phone='1234567890',MobilePhone='1234567890',Email='martin@abc.com');//,Name='ricky martin');
      insert con;
      
      ServiceRequestType__c srType=new ServiceRequestType__c(Name='Test',Object__c='Case',Service_Name__c='Abandon on Private Vechicle');
      insert srType;
          
      //insert case
      caserecord=new case(Status='open',ContactId=con.Id,SRType__c=srType.Id);         
      insert caserecord;
          
      Fquestion=new FlexNoteQuestion__c(Name='FNQ-Code', Code__c='testcode',Answer_Type__c='MultiPicklist',Questions__c='Please identify the items for collection (refrigerator, household furniture, etc.)',
      AnswerValues__c='HOUSAPPL:Household Appliances (Doors off Refrigerators),FURNI001:Furniture,COMOACNA:Computer Monitors (Actual Computer not Accepted),CONDEBPR:Construction/Demolition Debris (Prohibited),INC:sample picks only'
      );
      insert Fquestion;
/*
      flexnote=new FlexNote__c(Name='testname',FlexNote_Question__c=Fquestion.id,Case__c=caserecord.id,Order__c=1,Answer__c='HOUSAPPL,FURNI001'
      ,Questions__c='Please identify the items for collection (refrigerator, household furniture, etc.)',CodeDescription__c='HOUSAPPL:Household Appliances (Doors off Refrigerators);FURNI001:Furniture;COMOACNA:Computer Monitors (Actual Computer not Accepted)'
      );
*/      
      flexnote=new FlexNote__c(FlexNote_Question__c=Fquestion.id,Case__c=caserecord.id,Order__c=1,Answer__c='HOUSAPPL,FURNI001'
      ,Questions__c='Please identify the items for collection (refrigerator, household furniture, etc.)',CodeDescription__c='HOUSAPPL:Household Appliances (Doors off Refrigerators);FURNI001:Furniture;COMOACNA:Computer Monitors (Actual Computer not Accepted)'
      );
      
      
      insert flexnote;    
      
      
      OUC_Activity__c oucActivity= new OUC_Activity__c(Case__c=caserecord.Id,Public__c='test');
      insert oucActivity;
      
      
      
      
      
      
      
      
      caseIdsList=new list<Id>{caserecord.Id};
      fnList=new list<FlexNote__c>{flexnote};
      fnQList=new list<FlexNoteQuestion__c>{Fquestion};
    }
    
    
    public static testmethod void cloneHistoryObjectTest(){
        createData();
        Test.startTest();
            CloneHistoryObjects.cloneServiceRequestHistory(caseIdsList);
        Test.stopTest();
    }
    
    public static testmethod void serviceRequestHelperTest(){
        createData();
        Test.startTest();
            //ServiceRequestsHelper.startFlexNoteProcess(fnList,fnQList);
        Test.stopTest();
    }
    
    
    
    
       
}