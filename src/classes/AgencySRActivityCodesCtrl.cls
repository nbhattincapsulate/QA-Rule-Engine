public class AgencySRActivityCodesCtrl {

  private final Integer TYPE_AGENCY = 0;
  private final Integer TYPE_SR = 1;

  public String activeServicingAgency { get; set; }
  public String selectedType { get; set; }

  public List<SelectOption> agencyPicklistOptions;
  public List<SelectOption> serviceReportTypes;
  public List<OUC_Activity__c> activitiesBySRType;

  public AgencySRActivityCodesCtrl() {
    
  }

  public List<SelectOption> getAgencyPicklistOptions() {
    if (agencyPicklistOptions == null) {
      agencyPicklistOptions = new List<SelectOption> ();
      agencyPicklistOptions.add(new SelectOption('', '-- Select an Agency --'));
      // Get all the servicing agencies. 
      List<Jurisdiction__c> types = [Select Id, Name, Agency__c From Jurisdiction__c];
      Set<String> srTypes = new Set<String> ();
      // Loop through the results and set the select options for the picklist.
      for (Jurisdiction__c srtype : types) {
        if (!srTypes.contains(srType.Agency__c) && srtype.Agency__c != null) {
          srTypes.add(srType.Agency__c);
          agencyPicklistOptions.add(new SelectOption(srtype.Agency__c, srtype.Agency__c));
        }
      }
      System.debug('');
    }
    return agencyPicklistOptions;
  }

  public List<SelectOption> getServiceRequestTypesForAgency() {
    serviceReportTypes.add(new SelectOption('', '-- Select a Service Request Type --'));
    List<AggregateResult> results;
    // Get all the SRType's for activeServicingAgency cases to add to the picklist.
    results = [Select SRType__r.Id, SRType__r.Service_Name__c From Case Where Servicing_Agency__c = :activeServicingAgency Group By SRType__r.Service_Name__c, SRType__r.Id];
    // Loop through the results and set the select options for the picklist.
    for (AggregateResult ar : results) {
      serviceReportTypes.add(new SelectOption((String) ar.get('Id'), (String) ar.get('Service_Name__c')));
    }
    return serviceReportTypes;
  }

  public List<OUC_Activity__c> getActivitysBySRType() {
    List<Case> lastClosedSRForType = [Select Id, SRType__c From Case Where SR_Status__c = 'Closed' AND Servicing_Agency__c = :activeServicingAgency AND SRType__c = :selectedType ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 1];
    System.debug('----> Query: Select Id, SRType__r.Service_Name__c From Case Where SR_Status__c = \'Closed\' AND Servicing_Agency__c = '+activeServicingAgency+' AND SRType__c = '+selectedType+' ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 1');
    System.debug('----> lastClosedSRForType: ' + lastClosedSRForType);

    if (lastClosedSRForType != null && lastClosedSRForType.size() == 1) {
      activitiesBySRType = [Select Id, Final_Task_Code__c, Final_Task_Short_Name__c	, Phone__c, Priority__c, Subject__c, Activity_Type__c From OUC_Activity__c Where Case__c = :lastClosedSRForType.get(0).Id];
    }
    System.debug('----> activitiesBySRType: ' + activitiesBySRType);
    return activitiesBySRType;
  }

  public PageReference picklistChanged() {
    // TODO: Add switch for Agency vs Type
    serviceReportTypes = new List<SelectOption>();
    activitiesBySRType = new List<OUC_Activity__c>();
    String actionType = ApexPages.currentPage().getParameters().get('actionType');

    try {
      Integer type = Integer.valueOf(actionType);

      if (type == TYPE_AGENCY) {
        selectedType = '';
      } else if (type == TYPE_SR) {

      }
    } catch (TypeException e) {
      System.debug('----> TypeException: The given string cannot be converted to an Integer');
    }
    return null;
  }
}