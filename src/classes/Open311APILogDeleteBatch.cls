global class Open311APILogDeleteBatch implements Database.Batchable<sObject>{
    global final String Query;
    global Open311APILogDeleteBatch(String q){
        Query=q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<Open311_API_Log__c> scope){
        delete scope;
    }

    global void finish(Database.BatchableContext BC){}
}