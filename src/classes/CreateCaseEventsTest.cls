@isTest 
private class  CreateCaseEventsTest{ 
    static testmethod void testCreateCaseEvent() {  
    // Create test records                                         
        Case c = new Case(Subject ='Alley Repair',Address__c ='702 19TH STREET NE',FlexNotes__c ='Test CreateCaseEvents',OwnerId='00Gt0000000MCx3EAG');                
        insert c;                            
         
        case c1  = new Case(Subject ='Alley Repair',Address__c ='702 19TH STREET NE',FlexNotes__c ='Test CreateCaseEvents',OwnerId='00Gt0000000MCx3EAG');
        insert c1;        
          
    } 
}