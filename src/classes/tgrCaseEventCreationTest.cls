@isTest
public class tgrCaseEventCreationTest {

    public static testmethod void caseEventTest_trigger()
    {
        Case c = new Case(Subject ='Alley Repair',Address__c ='702 19TH STREET NE',FlexNotes__c ='test Batch',OwnerId='00Gt0000000MCx3EAG',CreatedDate =date.today(), Last_Update_Date__c= date.today());       
        insert c;
        Case c1 = [select id from Case where Subject = 'Alley Repair'];
        c1.FlexNotes__c ='TestEventCases';           
        update c1;
    }
}