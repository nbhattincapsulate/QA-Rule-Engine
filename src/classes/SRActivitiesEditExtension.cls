public with sharing class SRActivitiesEditExtension{
    
    public List<SelectOption> outComeValues {get;set;}
    public Case service_request {get;set;}
    public ApexPages.StandardController controller {get;set;}
    
    public SRActivitiesEditExtension(ApexPages.StandardController controller) {
      this.controller = controller;
      outComeValues  = new List<SelectOption>();
        
      OUC_Activity__c activity = [Select Activity_Type__c,Case__c FROM OUC_Activity__c WHERE Id=:controller.getId()];
       
      if(activity.Case__c != null) {
        service_request = ServiceRequestsHelper.getRequest(activity.Case__c);                                                                 
      }
        
      List<Activity_Outcomes__c> outcomes= [Select Id,Name FROM Activity_Outcomes__c WHERE Activity_Type__c =:activity.Activity_Type__c];
      if(outcomes.size()>0){
        for(Activity_Outcomes__c ao:outcomes)
          outComeValues.add(new SelectOption(ao.Id,ao.Name));
      }                    
    }
    
    public PageReference save() {        
        // Save the new changes.
        try{
        	
		    if(this.controller.save() != null){
		      // Send user back to SR Activity details page.
		      PageReference newPage = New PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
		      newPage.setRedirect(true);
		      return newPage;
		    }
		    return null;

		  } catch (DMLException ex) {
		     ApexPages.addMessages(ex);
		     return null;
		  }
    }
}