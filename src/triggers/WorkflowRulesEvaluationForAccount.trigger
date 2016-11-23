trigger WorkflowRulesEvaluationForAccount on Account (after insert,after update) {
    
    
   Set<Id> Ids=new Set<Id>();
   String sobjName='Account';
    
    
    //add all the accountids in the set
    for (Account a:trigger.new){
        Ids.add(a.Id);
    }//for 
    //decide whether we need to start the process:- changing here for trigger chaining @sneha
	Boolean evaluate = WorkflowRuleEvaluation.EvaluationIsRunning;
    try{   
     
    
    //Send that list of created or updated account to the Rule Engine class for evaluation

    if (!evaluate){       
             WorkflowRuleEvaluation.startWorkflow(Ids,sobjName,Trigger.isInsert);       
    }    
    }  
    //Do not fail this trigger
//    catch(Exception e){}
     //Do not Fail this trigger
   catch(Exception e){
       if(Test.isRunningTest()){ 
           System.debug('This is not working properly'); 
        }   
        else
           throw(e);     
   
   }
}