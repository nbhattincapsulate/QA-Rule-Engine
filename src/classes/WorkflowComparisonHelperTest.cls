@IsTest
public class WorkflowComparisonHelperTest {

	   //updated by SH
     static testmethod void testStringComparsionMethod(){
             Boolean result ;       
             Test.startTest();
                 
                 result= WorkflowComparisonHelper.isValid('test','test', 'equals');                    
                 system.assertEquals(true, result); 
                 
                 result= WorkflowComparisonHelper.isValid('test','test', 'not equal to');                      
                 system.assertEquals(false, result);
                 
                 result= WorkflowComparisonHelper.isValid('test','es', 'Contains');                    
                 system.assertEquals(true, result); 
                 
                 result= WorkflowComparisonHelper.isValid('dummy','es', 'Does Not Contain');                   
                 system.assertEquals(true, result); 
                 
                 result= WorkflowComparisonHelper.isValid('dummy','du', 'Starts With');                    
                 system.assertEquals(true, result); 
                 
                 result= WorkflowComparisonHelper.isValid('dummy','my', 'Ends With');                  
                 system.assertEquals(true, result); 
                 
                 result= WorkflowComparisonHelper.isValid('dummy','[a-z]+', 'Regular Expression');                 
                 system.assertEquals(true, result);     
                 
                 result= WorkflowComparisonHelper.isValid('dummy2','dummy2', 'includes');                   
                 system.assertEquals(true, result); 
                 
                 result= WorkflowComparisonHelper.isValid('dummy2','dummy2', 'excludes');                  
                 system.assertEquals(false, result);    
                
                
             Test.stopTest();   
        }
        
        static testmethod void testNumberComparsionMethod(){
             Boolean result ;       
             Test.startTest();
                 
                 result= WorkflowComparisonHelper.isValid(10.0,10.0, 'equals',null);                  
                 system.assertEquals(true, result); 
                 
                 result= WorkflowComparisonHelper.isValid(10.0,10.0, 'not equal to',null);                        
                 system.assertEquals(false, result);
                 
                 result= WorkflowComparisonHelper.isValid(14.0,10.0, 'Greater Than',null);                    
                 system.assertEquals(true, result); 
                 
                 result= WorkflowComparisonHelper.isValid(10.0,14.0, 'Less Than',null);                   
                 system.assertEquals(true, result);
                 
                 result= WorkflowComparisonHelper.isValid(15.0,14.0, 'Greater or Equal',null);                    
                 system.assertEquals(true, result); 
                
                 result= WorkflowComparisonHelper.isValid(14.0,14.0, 'Less or Equal',null);                   
                 system.assertEquals(true, result); 
                 
                 WorkflowRuleCriteria__c c = new WorkflowRuleCriteria__c();
                 c.Maximum_Value__c='100';
                 c.Minimum_Value__c='50';
                 
                 result= WorkflowComparisonHelper.isValid(60.0,14.0, 'between',c);                    
                 system.assertEquals(true, result); 
                 
             Test.stopTest();   
        }
        
        static testmethod void testDateComparsionMethod(){
             Boolean result ;
             
             Date d = date.today();
             
                    
             Test.startTest();           
                 result= WorkflowComparisonHelper.isValid(d,d, 'equals',null);                   
                 system.assertEquals(true, result); 
                 
                 result= WorkflowComparisonHelper.isValid(d,d, 'not equal to',null);                     
                 system.assertEquals(false, result);
                 
                 result= WorkflowComparisonHelper.isValid(d,date.parse('12/27/2009'), 'Greater Than',null);                  
                 system.assertEquals(true, result); 
                 
                 result= WorkflowComparisonHelper.isValid(d,date.parse('12/27/2009'), 'Less Than',null);                 
                 system.assertEquals(false, result);
                 
                 result= WorkflowComparisonHelper.isValid(d,date.parse('12/27/2009'), 'Greater or Equal',null);                  
                 system.assertEquals(true, result); 
                
                 result= WorkflowComparisonHelper.isValid(d,date.parse('12/27/2009'), 'Less or Equal',null);                 
                 system.assertEquals(false, result);
                 
                 
                 WorkflowRuleCriteria__c c = new WorkflowRuleCriteria__c();
                 c.Maximum_Value__c='12/27/2019';
                 c.Minimum_Value__c='12/27/2009';
                 
                 result= WorkflowComparisonHelper.isValid(d,d, 'between',c);                 
                 system.assertEquals(true, result); 
                 
                  result= WorkflowComparisonHelper.isValid(d,d, 'Not Between',c);                 
                 system.assertEquals(false, result); 
                        
             Test.stopTest();    
         }
         
         static testmethod void testDateTimeComparsionMethod(){
             Boolean result ;
             
             Contact a = new Contact(LastName='test');
             insert a;
             
             a =[Select Id,CreatedDate FROM Contact WHERE Id =:a.Id];
             
            // Datetime d = Datetime.valueOf(string.valueof(a.get('CreatedDate')));
             Datetime d  = DateTime.parse('10/15/2012 11:46 AM');  
             Datetime dt = DateTime.parse('10/15/2011 11:46 AM'); 
                    
             Test.startTest();           
                 result= WorkflowComparisonHelper.isValid(d,d, 'equals',null);                   
                 system.assertEquals(true, result); 
                 
                 result= WorkflowComparisonHelper.isValid(d,d, 'not equal to',null);                     
                 system.assertEquals(false, result);
                 
                 result= WorkflowComparisonHelper.isValid(d,dt, 'Greater Than',null);                    
                 system.assertEquals(true, result); 
                 
                 result= WorkflowComparisonHelper.isValid(d,dt, 'Less Than',null);                   
                 system.assertEquals(false, result);
                 
                 result= WorkflowComparisonHelper.isValid(d,dt, 'Greater or Equal',null);                    
                 system.assertEquals(true, result); 
                
                 result= WorkflowComparisonHelper.isValid(d,dt, 'Less or Equal',null);                   
                 system.assertEquals(false, result);
                 
                 
                 WorkflowRuleCriteria__c c = new WorkflowRuleCriteria__c();
                 c.Maximum_Value__c='10/14/2019 11:46 AM';
                 c.Minimum_Value__c='10/14/2009 11:46 AM';
                 
                 result= WorkflowComparisonHelper.isValid(d,dt, 'between',c);
                 system.assertEquals(true, result); 
                 
                  result= WorkflowComparisonHelper.isValid(d,dt, 'not between',c);
                 system.assertEquals(false, result); 
                        
             Test.stopTest();    
         }

}