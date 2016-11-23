/**
 *  ServiceReportsController
 * 
 *  This controller contains all the logic required to generate reports and present data based on Service Requests.
 *  @author Darkis
 */

public class ServiceReportsController {
  private static final String ALL_MODE = '';
  private static final String OPEN_ONLY_MODE = 'Open';
  private static final String CLOSED_ONLY_MODE = 'Closed';
  private static final Integer list_size = Integer.valueOf(SR_Reports_Config__c.getInstance('Version_1').List_Size__c);
  private static final Integer MAX_REPORTS = Integer.valueOf(SR_Reports_Config__c.getInstance('Version_1').Report_Limit__c);

  public String svgSortImage { get; set; }
  public String activeServicingAgency { get; set; }
  public String lastActiveServiceType { get; set; }  
  public String mode { get; set; }
  public String sortColumnName { get; set; }
  public String oldSortColumnName { get; set; }
  public String sortColumnDirection { get; set; }  
  public String currentDatetime;
  public String daterangeFrom { get; set; }
  public String daterangeTo { get; set; }
  public String daterangeComplete { get; set; }
  public String selectedStatus { get; set; }
  public String selectedType { get; set; }
  public String selectedWard { get; set; }
  public String selectedOwner { get; set; }
  public String selectedSnowZone { get; set; }
  public String selectedSnowRoute { get; set; }
  public String caseClosureComment { get; set; }
    
  public Boolean checkAllEnabled { get; set; }
  public Boolean limitReached { get; set; }
  public Boolean isSelectedCases { get; set; }
    
  public Set<Id> selectedCaseIds { get; set; }
  public Set<String> selectedStatusesSet { get; set; }
    
  public List<Case> selectedCases { get; set; }
  public List<SelectOption> statusOptions { get; set; }
  public List<SelectOption> serviceReportTypes { get; set; }
  public List<SelectOption> wardPicklistOptions { get; set; }
  public List<SelectOption> ownerPicklistOptions { get; set; }
  public List<SelectOption> agencyPicklistOptions { get; set; }
  public List<SelectOption> snowZonePicklistOptions { get; set; }
  public List<SelectOption> snowRoutePicklistOptions { get; set; }
  public List<CaseWrapper> allCasesList { get; set; }
  public List<SelectOption> selectedStatusesOptions { get; set; }
    
  public Map<Id, CaseWrapper> allCases { get; set; }
  public Map<Id, CaseWrapper> allCasesSelected { get; set; }
  public Map<Id, Map<String, String>> caseDatetimes { get; set; }
  public Map<Id, List<FlexNote__c>> caseFlexNotes { get; set; }
  public Map<Id, List<OUC_Activity__c>> caseActivities { get; set; }
  public Map<Id, Map<String, String>> caseActivitiesExtras { get; set; }
  public Map<Id, List<CaseComment>> caseComments { get; set; }

  public Integer displayMaxReports { get; set; }
  public Integer total_size;
  private Integer counter = 0; //keeps track of the offset

  public ServiceReportsController() {
    // Set defaults.
    mode = ALL_MODE;
    sortColumnName = 'CreatedDate';
    oldSortColumnName = 'CreatedDate';
    sortColumnDirection = 'DESC';
    svgSortImage = 'arrowdown';
    displayMaxReports = MAX_REPORTS;
    activeServicingAgency = 'DPW';

    try {
      // Split the current URL to check the tab page name.
      List<String> urlSplit = (ApexPages.currentPage().getUrl()).split('/');

      Boolean loopComplete = false;
      // Loop through the split url.
      for (String part : urlSplit) {
        // If the part is not blank and isn't informing us it's an Apex page.
        if (!String.isBlank(part) && !part.equalsIgnoreCase('apex') && part.contains('?')) {
          // If the Tab/Page name is 'ServiceReports_Fems then switch the servicing agency.
          List<String> pageNameList = part.split('\\?');
          // Loop through the page name and params to compare the name of the page. 
          for (String namePart : pageNameList) {
            // If the name of the page is Fems then we want to switch the agency.
            if (namePart.equalsIgnoreCase('ServiceReports_Fems')) {
              loopComplete = true;
              activeServicingAgency = 'FEMS';
              break;
            }
          }
        }
        // If the string was found then break the loop.  
        if (loopComplete) {
          break;
        }
      }
    } catch(Exception e) {
      System.debug('-----> Error parsing url for Servicing Agency. Defaulting to "DPW"');
    }

    total_size = [Select count() From Case Where Servicing_Agency__c = :activeServicingAgency];
    setupPicklists();
    allCasesSelected = new Map<Id, CaseWrapper> ();
    checkAllEnabled = false;
    isSelectedCases = false;

    // Maximum SOQL offset is 2000. Ensure it never goes above this.
    if (total_size > 2000) {
      total_size = 2000;
    }
    // Get all the cases.
    allCases = getServiceRequests();
    // Inialize the selectedCaseIds.
    selectedCaseIds = new Set<Id> ();
    selectedCases = new List<Case> ();
  }

  /**
   * setupPicklists
   * 
   * This function will setup the necessary filter picklists with the required data.
   * @author Darkis
   */
  public void setupPicklists() {
    if (lastActiveServiceType == null || lastActiveServiceType != activeServicingAgency) {
        lastActiveServiceType = activeServicingAgency;
        // Initialize the selectedStatuses container.
        selectedStatusesOptions = new List<SelectOption> ();
        // Initialize the selection options.
        statusOptions = new List<SelectOption> ();
        //statusOptions.add(new SelectOption('', 'All Requests'));
        serviceReportTypes = new List<SelectOption> ();
        serviceReportTypes.add(new SelectOption('', 'All Service Types'));
        wardPicklistOptions = new List<SelectOption> ();
        wardPicklistOptions.add(new SelectOption('', 'All Wards'));
        ownerPicklistOptions = new List<SelectOption> ();
        ownerPicklistOptions.add(new SelectOption('', 'All Owners'));
        agencyPicklistOptions = new List<SelectOption> ();
        snowZonePicklistOptions = new List<SelectOption> ();
        snowZonePicklistOptions.add(new SelectOption('', 'All Snow Zones'));
        snowRoutePicklistOptions = new List<SelectOption> ();
        snowRoutePicklistOptions.add(new SelectOption('', 'All Snow Areas'));
    
        List<AggregateResult> results;
        List<Case> resultsCaseVer = new List<Case>();
    
        // Get all the SRType's for activeServicingAgency cases to add to the picklist.
        results = [Select SRType__r.Id, SRType__r.Service_Name__c From Case Where Servicing_Agency__c = :activeServicingAgency Group By SRType__r.Service_Name__c, SRType__r.Id Order By SRType__r.Service_Name__c ASC];
        // Loop through the results and set the select options for the picklist.
        for (AggregateResult ar : results) {
          serviceReportTypes.add(new SelectOption((String) ar.get('Id'), (String) ar.get('Service_Name__c')));
        }
          
        Map<String, Set<String>> aggUniqueMapping = new Map<String, Set<String>>();  
        aggUniqueMapping.put('Status', new Set<String>());
        aggUniqueMapping.put('Ward__c', new Set<String>());
        aggUniqueMapping.put('Id', new Set<String>());
        aggUniqueMapping.put('SnowZone__c', new Set<String>());
        aggUniqueMapping.put('SnowRoute__c', new Set<String>());
          
        // Special map for Selects with different label vs value.
        Map<String, Map<String, String>> aggUniqueOwnerMapping = new Map<String, Map<String,String>>();
        aggUniqueOwnerMapping.put('Owners', new Map<String,String>());
    
        // Get all the wards for activeServicingAgency cases to add to the picklist.
        results = [Select Status, Ward__c, Owner.Id, Owner.Name, SnowZone__c, SnowRoute__c From Case Where Servicing_Agency__c = :activeServicingAgency Group By Status, Ward__c, Owner.Id, Owner.Name, SnowZone__c, SnowRoute__c];
        // Loop through the results and set the select options for the picklist.
        for (AggregateResult ar : results) {
            
          if (ar.get('Status') != null && !aggUniqueMapping.get('Status').contains((String) ar.get('Status'))) {
            aggUniqueMapping.get('Status').add((String) ar.get('Status'));
          }
            
          if (ar.get('Ward__c') != null && !aggUniqueMapping.get('Ward__c').contains((String) ar.get('Ward__c'))) {
            aggUniqueMapping.get('Ward__c').add((String) ar.get('Ward__c'));
          }
            
          if (ar.get('Id') != null && ar.get('Name') != null && !aggUniqueMapping.get('Id').contains((String) ar.get('Id'))) {
            (aggUniqueOwnerMapping.get('Owners')).put((String) ar.get('Name'), (String) ar.get('Id'));
          }
            
          if (ar.get('SnowZone__c') != null && !aggUniqueMapping.get('SnowZone__c').contains((String) ar.get('SnowZone__c'))) {
            aggUniqueMapping.get('SnowZone__c').add((String) ar.get('SnowZone__c'));
          }
            
          if (ar.get('SnowRoute__c') != null && !aggUniqueMapping.get('SnowRoute__c').contains((String) ar.get('SnowRoute__c'))) {
            aggUniqueMapping.get('SnowRoute__c').add((String) ar.get('SnowRoute__c'));
          }
        } 
         
        for (String key : aggUniqueMapping.keySet()) {
          // Convert set to list.
          Boolean listSorted = false;
          List<String> listToSort = new List<String>(aggUniqueMapping.get(key));
          // If the key is a snow then convert Int's to Strings.
          if (key.containsIgnoreCase('snow')) {
            try {
              // Convert the string list into an Integer list for sorting.  
              List<Integer> snowListToSort = new List<Integer>();
              List<String> newListToSort = new List<String>();  
              // Loop through the string list and convert it to an Int list.
              for (String snowProp : listToSort) {
                snowListToSort.add(Integer.valueOf(snowProp));       
              }
              // Sort the integer list.  
              snowListToSort.sort();
              // Loop through and convert back to strings.  
              for (Integer snowPropInt : snowListToSort) {
                newListToSort.add(String.valueOf(snowPropInt));
              }
              // Set the sorted list.  
              listToSort = newListToSort;
              listSorted = true;
            } catch (Exception e) {
              System.debug('-----> Unable to convert list from String to Integer. Sending unsorted String list instead...');
            }
          }
          // If the list has not been pre-sorted then sort it.
          if (!listSorted) {
            listToSort.sort(); 
          }
          // Loop through the sorted list and create the select options. Ensure to remove all null values.
          for (String val : listToSort) {
            if (String.isNotBlank(val) && !val.equalsIgnoreCase('null')) {
              if (key.equalsIgnoreCase('Status')) {
                statusOptions.add(new SelectOption(val, val));
              } else if (key.equalsIgnoreCase('Ward__c')) {
                wardPicklistOptions.add(new SelectOption(val, val));  
              } else if (key.equalsIgnoreCase('SnowZone__c')) {
                snowZonePicklistOptions.add(new SelectOption(val, val));  
              } else if (key.equalsIgnoreCase('SnowRoute__c')) {
                snowRoutePicklistOptions.add(new SelectOption(val, val));  
              } 
            }
          }
        }
        // Sort the owner information.
        for (String key : aggUniqueOwnerMapping.keySet()) {
          try {
            // Obtain the owner name keys.
            Map<String, String> ownerMap = aggUniqueOwnerMapping.get(key);
            // Create a list of the names and sort them.
            List<String> ownerNameListToSort = new List<String>(ownerMap.keySet());
            ownerNameListToSort.sort();  
            // Create the picklist options with the sorted names and their corresponding Ids. 
            for (String name : ownerNameListToSort) {
              ownerPicklistOptions.add(new SelectOption(ownerMap.get(name), name));
            }
          } catch (Exception e) {
            System.debug('-----> Unable to sort owner list.');
          }
        }
        
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
        // Remove srTypes from memory.
        srTypes.clear();
        results.clear();
    } 
  }

  /**
   * getServiceRequests
   * 
   * This function will get all the service requests for the page based on a given criteria. 
   * @author Darkis
   */
  public Map<Id, CaseWrapper> getServiceRequests() {
    try {
      Map<Id, CaseWrapper> casesWrapped = new Map<Id, CaseWrapper> ();
      allCasesList = new List<CaseWrapper> ();

      String query = 'Select Id, Service_Request_Number__c, Service_Request_Name__c, SR_Status__c, CreatedDate, Owner.Name, Address__c, Last_Update_Date__c, Ward__c, SnowZone__c, SnowRoute__c From Case';
      query = extendQueryWithFilters(query);
      // Add ORDER BY.
      query += ' ORDER BY ' + sortColumnName + ' ' + sortColumnDirection + ' NULLS LAST';
      // LIMIT and OrderBy Clause
      query += ' LIMIT :list_size OFFSET :counter';

      Case[] cases = Database.query(query);

      Integer uncheckedCounter = 0;

      for (Case c : cases) {
        CaseWrapper cw = new CaseWrapper(c, (selectedCaseIds != null && selectedCaseIds.contains(c.Id)) ? true : false);
        // If the checkbox is not checked then increment the unchecked counter.  
        if (!cw.checked) {
          uncheckedCounter++;
        }
        casesWrapped.put(c.Id, cw);
        allCasesList.add(cw);
      }

      if (uncheckedCounter == 0) {
        checkAllEnabled = true;
      }

      return casesWrapped;
    } catch(QueryException e) {
      ApexPages.addMessages(e);
      return null;
    }
  }

  /**
   * serviceRequestChecked
   * 
   * This function is triggered when a single checkbox for a SR is clicked.
   * @author Darkis
   */
  public void serviceRequestChecked() {
    limitReached = false;
    checkAllEnabled = false;
    Id caseId = Apexpages.currentPage().getParameters().get('caseId');
    checkForSelectedCases(caseId, false);
  }

  /**
   * serviceRequestCheckAll
   * 
   * This function will be triggered when the check all checkbox is selected. It will ensure all boxes are checked on the current page.
   * @author Darkis
   */
  public void serviceRequestCheckAll() {
    for (CaseWrapper cw : allCases.values()) {
      if (checkAllEnabled && !cw.checked) {
        checkForSelectedCases(cw.c.Id, true);
      } else if (!checkAllEnabled && cw.checked) {
        checkForSelectedCases(cw.c.Id, false);
      }
    }
  }

  /**
   * checkForSelectedCases
   * 
   * Check for the current case ID in the selected lists and either add or remove it from the generate list.
   * @author Darkis
   * @param caseId String The ID for the current case selected on the page.
   * @param isCheckAll Boolean This will be set to true if the user selected to have all the current checkboxes selected.
   */
  private void checkForSelectedCases(String caseId, Boolean isCheckAll) {
    Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.WARNING, 'Only ' + MAX_REPORTS + ' items can be selected at once. Please remove one before attempting to add another.');
    // If the case has already been selected but isn't in the check all method. 
    if (selectedCaseIds.contains(caseId) && !isCheckAll) {
      selectedCaseIds.remove(caseId);

      if (allCasesSelected.containsKey(caseId)) {
        allCasesSelected.keySet().remove(caseId);
      }

      if (allCases.containsKey(caseId)) {
        allCases.get(caseId).checked = false;
      }
    } else if (selectedCaseIds.size() >= MAX_REPORTS) {
      limitReached = true;
      selectedCaseIds.add(caseId);
      allCasesSelected.put(caseId, new CaseWrapper(
                                                   [Select Id, Service_Request_Number__c, Service_Request_Name__c, SR_Status__c, CreatedDate, Owner.Name, Address__c, Last_Update_Date__c, Ward__c From Case Where Id = : caseId],
                                                   true
      ));

      if (allCases.containsKey(caseId)) {
        allCases.get(caseId).checked = true;
      }

      ApexPages.addMessage(msg);
    } else if (selectedCaseIds.size() < MAX_REPORTS) {
      selectedCaseIds.add(caseId);
      allCasesSelected.put(caseId, new CaseWrapper(
                                                   [Select Id, Service_Request_Number__c, Service_Request_Name__c, SR_Status__c, CreatedDate, Owner.Name, Address__c, Last_Update_Date__c, Ward__c From Case Where Id = : caseId],
                                                   true
      ));

      if (allCases.containsKey(caseId)) {
        allCases.get(caseId).checked = true;
      }
    }
    // If there are more one case selected then show it. 
    isSelectedCases = allCasesSelected.size() > 0 ? true : false;
    System.debug('----> Cases Selected Available: ' + isSelectedCases);
  }

  /**
   * closeSelectedCases
   *
   * @description This function will close all selected cases so long as they are not already closed. 
   * @author Darkis
   * @created 12 Feb 2016
   */
  public PageReference closeSelectedCases() {
    if (selectedCaseIds.size() > 0 && String.isNotBlank(caseClosureComment)) {
      ServiceReportsController.processClosingCasesFuture(selectedCaseIds, caseClosureComment);
    }
    selectedCaseIds = new Set<Id> ();
    allCasesSelected = new Map<Id, CaseWrapper> ();
    reset();
    return null;
  }

  @future
  private static void processClosingCasesFuture(Set<Id> caseIdsToProcess, String caseClosureComment) {
    // Get all the Selected Cases status'.
    List<Case> selectedCases = [Select Id, Status, SR_Status__c From Case Where Id IN :caseIdsToProcess];
    // Loop through the cases.
    for (Case c : selectedCases) {
      // If the case selected is not already closed then close it.
      if (c.Status != 'Closed' || c.Status != 'Duplicate (Closed)' || c.Status != 'Closed - Incomplete Information' || c.Status != 'Voided') {
        // Check for duplicates to ensure they are closed with the Duplicate (Closed) option.
        if (c.SR_Status__c.containsIgnoreCase('duplicate')) {
          c.Status = 'Duplicate (Closed)';
        } else {
          c.Status = 'Closed';
        }
        c.Case_Closure_Comment__c = caseClosureComment;
      }
    }
    // Update the list.
    update selectedCases;
  }

  /**
   * generate
   * 
   * This function will get all the needed cases and generate the reports based on the selected cases. 
   * @author Darkis
   */
  public PageReference generate() {
    caseDatetimes = new Map<Id, Map<String, String>> ();
    caseFlexNotes = new Map<Id, List<FlexNote__c>> ();
    caseActivities = new Map<Id, List<OUC_Activity__c>> ();
    caseActivitiesExtras = new Map<Id, Map<String, String>> ();
    caseComments = new Map<Id, List<CaseComment>> ();

    if (selectedCaseIds.size() > 0) {
      selectedCases = [
                       Select
                       Id,
                       Origin,
                       Description,
                       Service_Request_Number__c,
                       Service_Request_Name__c,
                       SR_Status__c,
                       CreatedDate,
                       CreatedBy__c,
                       Contact.MailingStreet,
                       Contact.MailingCity,
                       Contact.MailingStateCode,
                       Contact.MailingCountryCode,
                       Contact.MailingPostalCode,
                       Contact.Name,
                       Contact.Email,
                       Contact.Phone,
                       Address__c,
                       Priority,
                       Last_Update_Date__c,
                       Expected_Resolution_Date__c,
                       Ward__c,
                       SnowZone__c,
                       SnowRoute__c,
                       SRType_Jurisdiction__r.Jurisdiction__r.Servicing_Agency_Expanded__c
                       From Case Where Id IN :selectedCaseIds
                      ];

      List<FlexNote__c> selectedCaseFlexNotes = [Select Name, FlexNote_Question__r.Questions__c, Case__c, Order__c, Answer__c, Questions__c From FlexNote__c Where Case__c IN :selectedCaseIds];
      List<OUC_Activity__c> selectedCaseActivities = [Select Task_Short_Name__c, Owner.Name, Due_Date__c, Completion_Date__c, Final_Outcome_Short__c, Case__c From OUC_Activity__c Where Case__c IN :selectedCaseIds];

      Integer counter = 0;
      String caseId = null;
      List<FlexNote__c> caseNotes = new List<FlexNote__c> ();
      for (FlexNote__c fNote : selectedCaseFlexNotes) {
        System.debug('-----> FlexNote__c[' + counter + '].Case__c: ' + fNote.Case__c);
        if ((caseId != null && fNote.Case__c != caseId) || ((counter + 1) == selectedCaseFlexNotes.size())) {
          caseFlexNotes.put(caseId, caseNotes);
          caseNotes = new List<FlexNote__c> ();
        }
        caseNotes.add(fNote);
        caseId = fNote.Case__c;
        counter++;
      }

      counter = 0;
      caseId = null;
      List<OUC_Activity__c> caseAct = new List<OUC_Activity__c> ();
      for (OUC_Activity__c act : selectedCaseActivities) {
        if ((caseId != null && act.Case__c != caseId) || ((counter + 1) == selectedCaseActivities.size())) {
          caseActivities.put(caseId, caseAct);
          caseAct = new List<OUC_Activity__c> ();
        }
        caseAct.add(act);
        caseId = String.valueOf(act.Case__c);
        counter++;
      }
      sanatizeCaseMappings();

      counter = 0;
      caseId = null;
      List<CaseComment> allCaseCommentsFromIds = [Select Id, ParentId, CommentBody From CaseComment Where ParentId IN :selectedCaseIds];
      List<CaseComment> caseCommentList = new List<CaseComment> ();
      for (CaseComment comment : allCaseCommentsFromIds) {
        if ((caseId != null && comment.ParentId != caseId) || ((counter + 1) == allCaseCommentsFromIds.size())) {
          caseComments.put(caseId, caseCommentList);
          caseCommentList = new List<CaseComment> ();
        }
        caseCommentList.add(comment);
        caseId = String.valueOf(comment.ParentId);
        counter++;
      }

      for (Case c : selectedCases) {
        String address = '';

        if (c.Contact.MailingStreet != null) {
          address += c.Contact.MailingStreet;
        }

        if (c.Contact.MailingCity != null) {
          address += (address != null ? ', ' : '') + c.Contact.MailingCity;
        }

        if (c.Contact.MailingStateCode != null) {
          address += (address != null ? ', ' : '') + c.Contact.MailingStateCode;
        }

        if (c.Contact.MailingPostalCode != null) {
          address += (address != null ? ', ' : '') + c.Contact.MailingPostalCode;
        }

        String currentCaseComment = ' ';
        if (caseComments != null && caseComments.containsKey(c.Id)) {
          List<CaseComment> tempCC = caseComments.get(c.Id);

          if (tempCC.size() > 0) {
            currentCaseComment = tempCC.get(0).CommentBody;
          }
        }

        caseDatetimes.put(c.Id, new Map<String, String> {
                          'Status_Date' => getTimeZoneValue(c.Last_Update_Date__c),
                          'Created_Date' => getTimeZoneValue(c.CreatedDate),
                          'Overdue_On' => getTimeZoneValue(c.Expected_Resolution_Date__c),
                          'Comments' => currentCaseComment,
                          'Mailing_Address' => address
                          });

        if (caseActivities.get(c.Id) != null) {
          // Get the activities list for the current case.
          List<OUC_Activity__c> oucList = caseActivities.get(c.Id);
          // Loop through the activities and fix the dates.  
          for (OUC_Activity__c ouc : oucList) {
            caseActivitiesExtras.put(ouc.Id, new Map<String, String> {
                                     'Due_Date__c' => getTimeZoneValue(ouc.Due_Date__c),
                                     'Completed_Date__c' => getTimeZoneValue(ouc.Completion_Date__c)
                                     });
          }
        }
      }
      currentDatetime = getCurrentDatetime();
      PageReference pageRef = new PageReference('/apex/ServiceReportPDF');
      pageRef.setRedirect(false);
      return pageRef;
    }
    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'You must select at least 1 service request to generate reports.'));
    return null;
  }

  /**
   * sanatizeCaseMappings
   * 
   * This function will sanatize the flex note and activities mappings if there are any cases without them.
   * @author Darkis
   */
  private void sanatizeCaseMappings() {
    for (Id caseId : selectedCaseIds) {
      if (!caseFlexNotes.containsKey(caseId)) {
        caseFlexNotes.put(caseId, new List<FlexNote__c> ());
      }

      if (!caseActivities.containsKey(caseId)) {
        caseActivities.put(caseId, new List<OUC_Activity__c> ());
      }
    }
  }

  /**
   * Beginning
   * 
   * Go to the beginning of the service requests.
   * @author Darkis
   */
  public PageReference Beginning() { //user clicked beginning
    counter = 0;
    limitReached = false;
    checkAllEnabled = false;
    allCases = getServiceRequests();
    return null;
  }

  /**
   * Previous
   * 
   * Go to the previous subset of the service requests.
   * @author Darkis
   */
  public PageReference Previous() { //user clicked previous button
    counter -= list_size;
    limitReached = false;
    checkAllEnabled = false;
    allCases = getServiceRequests();
    return null;
  }

  /**
   * Next
   * 
   * Go to the next subset of the service requests.
   * @author Darkis
   */
  public PageReference Next() { //user clicked next button
    counter += list_size;
    // Maximum SOQL offset is 2000. Ensure it never goes above this.
    if (counter > 2000) {
      counter = 2000;
    }
    limitReached = false;
    checkAllEnabled = false;
    allCases = getServiceRequests();
    return null;
  }

  /**
   * End
   * 
   * Go to the end of the service requests.
   * @author Darkis
   */
  public PageReference End() { //user clicked end
    counter = total_size - math.mod(total_size, list_size);
    // Maximum SOQL offset is 2000. Ensure it never goes above this.
    if (counter > 2000) {
      counter = 2000;
    }
    limitReached = false;
    checkAllEnabled = false;
    allCases = getServiceRequests();
    return null;
  }

  /**
   * getDisablePrevious
   * 
   * Determine if the previous button should be enabled. 
   * @author Darkis
   */
  public Boolean getDisablePrevious() {
    //this will disable the previous and beginning buttons
    if (counter > 0) return false; else return true;
  }

  /**
   * getDisableNext
   * 
   * Determine if the previous button should be enabled. 
   * @author Darkis
   */
  public Boolean getDisableNext() { //this will disable the next and end buttons
    if (counter + list_size < total_size) return false; else return true;
  }

  /**
   * getTotal_size()
   * 
   * Get the total size of the service requests available.
   * @author Darkis
   */
  public Integer getTotal_size() {
    return total_size;
  }

  /**
   * get
   * 
   * Get the page number the user is currently on.
   * @author Darkis
   */
  public Integer getPageNumber() {
    return counter / list_size + 1;
  }

  /**
   * getTotalPages
   * 
   * Get the total number of pages available.
   * @author Darkis
   */
  public Integer getTotalPages() {
    if (math.mod(total_size, list_size) > 0) {
      return total_size / list_size + 1;
    } else {
      return(total_size / list_size);
    }
  }

  /**
   * getCurrentDatetime
   * 
   * Get the current datetime object in the correct timezone.
   * @author Darkis
   */
  public String getCurrentDatetime() {
    Datetime today = Datetime.now();
    return today.format('MMM d, yyyy - h:mm:ss aaa');
  }

  public String getTimeZoneValue(Datetime dt) {
    if (dt != null) {
      String localeFormatDT = dt.format('MMM dd, yyyy h:mm:ss a');
      return localeFormatDT;
    }
    return ' ';
  }

  public integer getCounter() {
    return counter;
  }

  public PageReference allRequests() {
    mode = ALL_MODE;
    reset();
    return null;
  }

  public PageReference openRequestsOnly() {
    mode = OPEN_ONLY_MODE;
    reset();
    return null;
  }

  public PageReference closedRequestsOnly() {
    mode = CLOSED_ONLY_MODE;
    reset();
    return null;
  }

  /**
   * toggleSortOrder
   * 
   * Toggle the sort order based on the selected header value. If the sort is to be based on date then sort desc first. 
   * @author Darkis
   */
  public PageReference toggleSortOrder() {
    // If this is a new column then reset to DESC sort order 
    if (sortColumnName == oldSortColumnName) {
      sortColumnDirection = (sortColumnDirection == 'DESC' ? 'ASC' : 'DESC');
      svgSortImage = (sortColumnDirection == 'DESC' ? 'arrowup' : 'arrowdown');
    } else {
      oldSortColumnName = sortColumnName;
      // If the column is Last Update Date then sort by newest first. 
      sortColumnDirection = (sortColumnName != 'Last_Update_Date__c' ? 'ASC' : 'DESC');
      svgSortImage = (sortColumnName != 'Last_Update_Date__c' ? 'arrowup' : 'arrowdown');
    }
    reset();
    return null;
  }

  public PageReference picklistChanged() {
    selectedStatusesSet = new Set<String> ();
    // Copy the picklist answers into a viable string for the query.
    Boolean first = true;
    Integer counter = 1;
    for (SelectOption so : selectedStatusesOptions) {
      /*if (!first && counter != selectedStatusesOptions.size()) {
        selectedStatus += ', ';
        }
        selectedStatus += so.getValue();
        first = false;
        counter++;*/
      selectedStatusesSet.add(so.getValue());
    }
    System.debug('----> Selected Statuses: ' + selectedStatusesSet);

    reset();
    return null;
  }

  /**
   * reset
   * 
   * This function will reset the table and it's currently selected cases. The cases will remain in the overall selected 
   *   container to ensure if navigation goes back the right cases are reselected.
   * @author Darkis
   */
  public void reset() {
    //selectedCaseIds = new Set<Id>();  
    selectedCases = new List<Case> ();
    String query = 'Select count() From Case';
    query = extendQueryWithFilters(query);
    total_size = Database.countQuery(query);
    setupPicklists();

    // Maximum SOQL offset is 2000. Ensure it never goes above this.
    if (total_size > 2000) {
      total_size = 2000;
    }

    Beginning();
  }

  public void clearDates() {
    daterangeFrom = null;
    daterangeTo = null;
    daterangeComplete = null;
    reset();
  }

  /**
   * extendQueryWithFilters
   * 
   * This function will accept a query string and append all known filters.
   * @author Darkis
   */
  public String extendQueryWithFilters(String query) {
    // WHERE Clause
    query += ' Where Servicing_Agency__c = :activeServicingAgency';
    // Service Request Status Filter
    if (selectedStatusesSet != null && selectedStatusesSet.size() > 0) {
      query += ' AND SR_Status__c IN :selectedStatusesSet';
    }
    // Service Request Type Filter   
    if (selectedType != null && !String.isEmpty(selectedType)) {
      query += ' AND SRType__c = :selectedType';
    }
    // Ward Filter   
    if (selectedWard != null && !String.isEmpty(selectedWard)) {
      query += ' AND Ward__c = :selectedWard';
    }
    // Owner Filter
    if (selectedOwner != null && !String.isEmpty(selectedOwner)) {
      query += ' AND Owner.Id = :selectedOwner';
    }
    // Snow Zone Filter
    if (selectedSnowZone != null && !String.isEmpty(selectedSnowZone)) {
      query += ' AND SnowZone__c = :selectedSnowZone';
    }
    // Snow Route Filter
    if (selectedSnowRoute != null && !String.isEmpty(selectedSnowRoute)) {
      query += ' AND SnowRoute__c = :selectedSnowRoute';
    }
    // Add date range if available.
    if (daterangeFrom != null && !String.isEmpty(daterangeFrom) && daterangeTo != null && !String.isEmpty(daterangeTo)) {
      try {
        String monthStr = '';
        String dayStr = '';
        DateTime fromDateTimeObj = DateTime.valueOf(daterangeFrom + ':00');
        DateTime toDateTimeObj = DateTime.valueOf(daterangeTo + ':00');

        // Convert and build the date string manually since we need it in GMT.
        Date tempFromDate = fromDateTimeObj.dateGMT();
        monthStr = tempFromDate.month() < 10 ? '0' + String.valueOf(tempFromDate.month()) : String.valueOf(tempFromDate.month());
        dayStr = tempFromDate.day() < 10 ? '0' + String.valueOf(tempFromDate.day()) : String.valueOf(tempFromDate.day());
        String fromDate = tempFromDate.year() + '-' + monthStr + '-' + dayStr;
        // Build the TO date out of the GMT date.
        Date tempToDate = toDateTimeObj.dateGMT();
        monthStr = tempToDate.month() < 10 ? '0' + String.valueOf(tempToDate.month()) : String.valueOf(tempToDate.month());
        dayStr = tempToDate.day() < 10 ? '0' + String.valueOf(tempToDate.day()) : String.valueOf(tempToDate.day());
        String toDate = tempToDate.year() + '-' + monthStr + '-' + dayStr;

        query += ' AND CreatedDate > ' + fromDate + 'T' + fromDateTimeObj.time() + ' AND CreatedDate < ' + toDate + 'T' + toDateTimeObj.time();
      } catch(Exception e) {
        System.debug('Error: ' + e.getMessage());
      }
    }

    // Add date range if available using NEW Complete variable.
    if (daterangeComplete != null && !String.isEmpty(daterangeComplete)) {
      try {
        String[] toFromDateTimeSplitArr = daterangeComplete.split(' ~ ');

        if (toFromDateTimeSplitArr != null) {
          String monthStr = '';
          String dayStr = '';
          DateTime fromDateTimeObj = DateTime.valueOf(toFromDateTimeSplitArr[0] + ':00');
          DateTime toDateTimeObj = DateTime.valueOf(toFromDateTimeSplitArr[1] + ':00');
          // Convert and build the date string manually since we need it in GMT.
          Date tempFromDate = fromDateTimeObj.dateGMT();
          monthStr = tempFromDate.month() < 10 ? '0' + String.valueOf(tempFromDate.month()) : String.valueOf(tempFromDate.month());
          dayStr = tempFromDate.day() < 10 ? '0' + String.valueOf(tempFromDate.day()) : String.valueOf(tempFromDate.day());
          String fromDate = tempFromDate.year() + '-' + monthStr + '-' + dayStr;
          // Build the TO date out of the GMT date.
          Date tempToDate = toDateTimeObj.dateGMT();
          monthStr = tempToDate.month() < 10 ? '0' + String.valueOf(tempToDate.month()) : String.valueOf(tempToDate.month());
          dayStr = tempToDate.day() < 10 ? '0' + String.valueOf(tempToDate.day()) : String.valueOf(tempToDate.day());
          String toDate = tempToDate.year() + '-' + monthStr + '-' + dayStr;

          query += ' AND CreatedDate > ' + fromDate + 'T' + fromDateTimeObj.timeGMT() + ' AND CreatedDate < ' + toDate + 'T' + toDateTimeObj.timeGMT();
        }
      } catch(Exception e) {
        System.debug('Error: ' + e.getMessage());
      }
    }
    System.debug('---> query: ' + query);
    return query;
  }

  /**
   * CaseWrapper
   * 
   * This is an inner class to wrap the cases with their respective checkbox.
   * @author Darkis
   */
  private class CaseWrapper {
    public Boolean checked { get; set; }
    public Case c { get; set; }

    public CaseWrapper(Case c, Boolean checked) {
      this.c = c;
      this.checked = checked;
    }
  }
  // TODO: REMOVE THIS FUNCTION ONCE TASK IS COMPLETE.
  public void convertAttachmentsPrivatePublic() {
    User portalUser = [Select Id, Name From User Where Name = 'Portal Site Guest User'];
    System.debug('----> Portal User: ' + portalUser);
    List<Attachment> portalPrivateAttachments = [Select Id, Name, isPrivate From Attachment Where isPrivate = true AND OwnerId = :portalUser.Id];
    System.debug('----> portalPrivateAttachments: ' + portalPrivateAttachments);
    for (Attachment a : portalPrivateAttachments) {
      a.isPrivate = false;
    }
    update portalPrivateAttachments;
  }
}