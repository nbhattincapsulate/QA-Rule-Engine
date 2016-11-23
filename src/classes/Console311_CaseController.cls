public class Console311_CaseController {

  public String errorMessage { get; set; }
  public String serviceType { get; set; }
  public Boolean isMapVisible { get; set; }
  public String addressQueryStr { get; set; }
  public String caseObjJson { get; set; }
  public Map<String, Double> requestMapCoords { get; set; }
  public String caseId { get; set; }
  public String caseNumber { get; set; }
  public Case caseToClone { get; set; }
  public String knowledgeKeyword { get; set; }
  public String serviceTypeName { get; set; }
    
  // TODO: Update DCMAR package to include the FULLBLOCK & BLOCKNAME fields in their model.
  public String mFullBlock { get; set; }
  public String mBlockName { get; set; }
    
  public Console311Settings__c config { get; set; }

  public List<ServiceRequestQuestionWrapper> serviceTypeQuestions { get; set; }
  public ContactCaseFlexNoteWrapper contactCaseFlexNote { get; set; }
  public Map<Date, BulkSchedule__c> bulkScheduleMap { get; set; }
  public List<Case> duplicateServiceRequests { get; set; }
  public IncapsulateDCM.findLocation2Response srAddress { get; set; }

  private Map<Id, FlexNoteQuestion__c> flexNoteIdMap { get; set; }
  private Map<String, String> QuestionAnswerMap;
  private Map<String, String> nameDecodeValueMap { get; set; }
  private Map<String, List<Decode_Object__c>> picklistNameDecodeMap { get; set; }
  private final String bulkscheduleTypeId { get; set; }

  public Console311_CaseController() {
    isMapVisible = false;
    requestMapCoords = new Map<String, Double> ();
    bulkScheduleMap = new Map<Date, BulkSchedule__c> ();
    flexNoteIdMap = new map<Id, FlexNoteQuestion__c> ();
    nameDecodeValueMap = new Map<string, string> ();
    picklistNameDecodeMap = new Map<String, List<Decode_Object__c>> ();
    serviceTypeQuestions = new List<ServiceRequestQuestionWrapper> ();
    duplicateServiceRequests = new List<Case> ();
    QuestionAnswerMap = new map<string, string> ();
    contactCaseFlexNote = new ContactCaseFlexNoteWrapper(new Contact(), new ServiceRequestType__c(), new Case(), new list<FlexNote__c> ());

    config = Console311Settings__c.getValues('Knowledge Enabled');
    System.debug('----> Config: ' + config);

    // Get the bulk collection id for comparriosn later to ensure if current type is BC.  
    List<ServiceRequestType__c> tempSRT = [Select Id, Name, Service_Name__c, External_Name__c From ServiceRequestType__c Where Service_Name__c = 'Residential Bulk Collection' OR External_Name__c = 'Residential Bulk Collection'];
    for (ServiceRequestType__c srt : tempSRT) {
      if (srt.Service_Name__c.equalsIgnoreCase('Residential Bulk Collection') || srt.External_Name__c.equalsIgnoreCase('Residential Bulk Collection')) {
        bulkScheduleTypeId = srt.Id;
        break;
      }
    }

    // Clone Process
    String caseIdToClone = Apexpages.currentpage().getparameters().get('clone');

    if (caseIdToClone != null) {
      // Get the existing case.
      caseToClone = [
                     Select
                     Id,
                     CaseNumber,
                     AgencyCode__c,
                     SLA__c,
                     SRType__c,
                     ParentId,
                     Status,
                     Origin,
                     Ward__c,
                     Description,
                     Service_Request_Name__c,
                     Address__c,
                     Zipcode__c,
                     Contact.Name, Contact.Email, Contact.Phone, Contact.FirstName, Contact.LastName, Contact.Id, ContactId, Contact.MailingStreet, Contact.MailingState, Contact.MailingCity, Contact.MailingPostalCode,
      (Select Id, Questions__c, Order__c, FlexNote_Question__c, Answer_Date_Time__c, Answer__c From FlexNotes__r)
                     From Case
                     Where Id = :caseIdToClone
                    ];
      // Get the location data.
      addressQueryStr = caseToClone.Address__c;
      getAddressAutocompleteActionFunc();
      // Get the flexnotes and their data. 
      serviceType = caseToClone.SRType__c;
      // Set question answers.
      QuestionAnswerMap = retrieveQuestionAnswerMap(caseToClone.FlexNotes__r);
      retrieveFlexNoteQuestions();
      // Check for duplicates to show. There should always be one, the case being cloned. 
      checkForDuplicateServiceRequests();
      isMapVisible = true;
    }
  }
  
  // TODO: Remove this function once DC MAR updates have been processed for BLOCKNAME & FULLBLOCK.
  public void setBlockAddressInformation() {
    this.mBlockName = Apexpages.currentPage().getParameters().get('blockName');
    this.mFullBlock = Apexpages.currentPage().getParameters().get('fullBlock');
      
    System.debug('----> this.mBlockName: ' + this.mBlockName);
    System.debug('----> this.mFullBlock: ' + this.mFullBlock);
  }
    
  private void fetchNamePickListValues() {
    for (Decode_Object__c dItem :[Select d.Value__c, d.Name, d.Type__c, d.Code__c, d.Active__c, d.Id From Decode_Object__c d where Active__c = true]) {
      nameDecodeValueMap.put(dItem.name, dItem.value__c);
      if (picklistNameDecodeMap.containsKey(dItem.Name)) {
        picklistNameDecodeMap.get(dItem.Name).add(dItem);
      } else {
        picklistNameDecodeMap.put(dItem.Name, new list<Decode_Object__c> { dItem });
      }
    }
  }

  public String getShortAddress() {
    if (srAddress != null) {
      return srAddress.returnDataset.Table1[0].FULLADDRESS;
    }
    return '';
  }

  /**
   *  getServiceRequestItems
   * 
   * This function will get all the service request types.
   * @author Darkis
   */
  public List<ServiceRequestType__c> getServiceRequestItems() {
    List<SelectOption> tempOptions = new List<SelectOption> ();
    Datetime deadline = Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));

    List<ServiceRequestType__c> serviceTypes = [
                                                Select
                                                Id,
                                                Name,
                                                SLA__c,
                                                Object__c,
                                                Agency__c,
                                                SLAType__c,
                                                Service_Name__c,
                                                External_Name__c,
                                                Description__c,
                                                LongExternalDescription__c,
                                                ContactStatus__c,
                                                ServiceLocationRequired__c 
                                                From ServiceRequestType__c
                                                Where
    (Start_Date__c <= :Date.today() OR Start_Date__c = null)
                                                AND
    (Stop_Date__c >= :Date.today() OR Stop_Date__c = null)
                                                Order By Service_Name__c ASC
                                               ];

    return serviceTypes;
  }

  /**
   * getServiceRequestNames
   * 
   * This function will return all available service request names in string format.
   * @author Darkis
   */
  public String getServiceRequestNames() {
    List<String> tempStrList = new List<String> ();

    List<ServiceRequestType__c> serviceTypes = [
                                                Select Id, Service_Name__c, External_Name__c From ServiceRequestType__c
                                                Where
    (Start_Date__c <= :Date.today() OR Start_Date__c = null)
                                                AND
    (Stop_Date__c >= :Date.today() OR Stop_Date__c = null)
                                                Order By Service_Name__c ASC
                                               ];

    for (ServiceRequestType__c type : serviceTypes) {
      tempStrList.add(type.External_Name__c != null ? type.External_Name__c : type.Service_Name__c);
    }

    return JSON.serialize(tempStrList);
  }

  // Get all the status options from the picklist.  
  public List<SelectOption> getStatusOptions() {
    return Console311_Util.getPicklistValues(new Case(), 'Status');
  }
  // Get all the origin options.  
  public List<SelectOption> getOriginOptions() {
    return Console311_Util.getPicklistValues(new Case(), 'Origin');
  }
  // Get all the origin options.  
  public List<SelectOption> getStateOptions() {
    //return Console311_Util.getPicklistValues(new Contact(), 'MailingStateCode');    
    return Console311_Util.getStatesByCountry('US');
  }
  // Allow the map to be rendered.
  public PageReference rerenderMap() {
    isMapVisible = true;
    System.debug(requestMapCoords);
    return null;
  }
  /**
   * getAddressAutocomplete
   * 
   * This function will retrieve the auto complete date using the address string passed and the MAR component.
   * @author Darkis
   * @param String addr The address the user is searching for.
   */
  @RemoteAction
  public static IncapsulateDCM.findLocation2Response getAddressAutocomplete(String addr) {
    IncapsulateDCM.findLocation2Response addrResponse = IncapsulateDCM.DCAtlasWebservice.findLocation2(addr);
    return addrResponse;
  }
  /**
   * getAddressAutocompleteActionFunc
   * 
   * This function will do another MAR service check on the address provided to the controller through an ActionFunction.
   *   It is used primairly for saving the state of the selected address in the controller.
   * @author Darkis
   * @param String addressQueryStr The address string from the auto complete.
   */
  public PageReference getAddressAutocompleteActionFunc() {
    requestMapCoords = new Map<String, Double> ();
    IncapsulateDCM.DcMarLocation addressInformation;
    if (!Test.isRunningTest()) {
      srAddress = IncapsulateDCM.DCAtlasWebservice.findLocation2(addressQueryStr);
        System.debug('----> Address Information for [' + addressQueryStr + ']: ');
        System.debug(srAddress);
      addressInformation = srAddress.returnDataset.Table1[0];
    } else {
      IncapsulateDCM.DcMarDataset tempSet = new IncapsulateDCM.DcMarDataset();
      tempSet.Table1 = new List<IncapsulateDCM.DcMarLocation> { getAddressTestData(addressInformation) };

      srAddress = new IncapsulateDCM.findLocation2Response();
      srAddress.UNIT = null;
      srAddress.UNITNUMBER = null;
      srAddress.details = '<STRONG>Normalized:</STRONG> 1400 M STREET NW</br>';
      srAddress.processTime = '0 seconds and 0 milliseconds';
      srAddress.returnCodes = null;
      srAddress.returnDataset = tempSet;
      addressInformation = getAddressTestData(addressInformation);
    }
    System.debug('----> Full Address Location Data: ' + addressInformation);
    requestMapCoords.put('latitude', addressInformation.LATITUDE);
    requestMapCoords.put('longitude', addressInformation.LONGITUDE);
    System.debug(requestMapCoords);
    checkForDuplicateServiceRequests();
    return null;
  }

  public IncapsulateDCM.findLocation2Response getLocation2ResponseTestData() {
    IncapsulateDCM.findLocation2Response locationWrap = new IncapsulateDCM.findLocation2Response();
    return locationWrap;
  }

  public IncapsulateDCM.DcMarLocation getAddressTestData(IncapsulateDCM.DcMarLocation addressInformation) {
    addressInformation = new IncapsulateDCM.DcMarLocation();
    addressInformation.ADDRESS_ID = 240254.0;
    addressInformation.ADDRNUM = 1400.0;
    addressInformation.ADDRNUMSUFFIX = null;
    addressInformation.ALIASNAME = null;
    addressInformation.ANC = 'ANC 2F';
    addressInformation.ANC_2002 = 'ANC 2F';
    addressInformation.ANC_2012 = 'ANC 2F';
    addressInformation.CENSUS_TRACT = '010100';
    addressInformation.CITY = 'WASHINGTON';
    addressInformation.ConfidenceLevel = 100.0;
    addressInformation.FOCUS_IMPROVEMENT_AREA = 'NA';
    addressInformation.FULLADDRESS = '1400 M STREET NW';
    addressInformation.FULLINTERSECTION = null;
    addressInformation.FULLSTREET1DISPLAY = null;
    addressInformation.FULLSTREET2DISPLAY = null;
    addressInformation.HAS_ALIAS = 'Y';
    addressInformation.HAS_CONDO_UNIT = 'N';
    addressInformation.HAS_RES_UNIT = 'N';
    addressInformation.HAS_SSL = 'Y';
    addressInformation.IMAGEDIR = '20040904';
    addressInformation.IMAGENAME = 'E4092602.jpg';
    addressInformation.IMAGEURL = 'http://citizenatlas.dc.gov/mobilevideo';
    addressInformation.INTERSECTIONID = null;
    addressInformation.LATITUDE = 38.90531614;
    addressInformation.LONGITUDE = - 77.0334361;
    addressInformation.MARID = 240254.0;
    addressInformation.NATIONALGRID = '18S UJ 23679 08235';
    addressInformation.NBHD_ACTION = null;
    addressInformation.POLDIST = 'Police District - Second District';
    addressInformation.PSA = 'Police Service Area 207';
    addressInformation.QUADRANT = 'NW';
    addressInformation.REFX = null;
    addressInformation.REFY = null;
    addressInformation.RES_TYPE = 'NON RESIDENTIAL';
    addressInformation.ROADWAYSEGID = 36829.0;
    addressInformation.ROC = 'NA';
    addressInformation.SMD = 'SMD 2F05';
    addressInformation.SMD_2002 = 'SMD 2F03';
    addressInformation.SMD_2012 = 'SMD 2F05';
    addressInformation.SSL = '0214    0860';
    addressInformation.ST1NAME = null;
    addressInformation.ST1QUAD = null;
    addressInformation.ST1TYPE = null;
    addressInformation.ST2NAME = null;
    addressInformation.ST2QUAD = null;
    addressInformation.ST2TYPE = null;
    addressInformation.STATE = 'DC';
    addressInformation.STATUS = 'ACTIVE';
    addressInformation.STNAME = 'M';
    addressInformation.STREET1ID = null;
    addressInformation.STREET2ID = null;
    addressInformation.STREETVIEWURL = 'http://maps.google.com/maps?z=16&layer=c&cbll=38.90531614,-77.0334361&cbp=11,169.579318983063,,0,2.090';
    addressInformation.STREET_TYPE = 'STREET';
    addressInformation.VOTE_PRCNCT = 'Precinct 17';
    addressInformation.WARD = 'Ward 2';
    addressInformation.WARD_2002 = 'Ward 2';
    addressInformation.WARD_2012 = 'Ward 2';
    addressInformation.XCOORD = 397099.84;
    addressInformation.YCOORD = 137495.93;
    addressInformation.ZIPCODE = '20005.0';
    return addressInformation;
  }

  /**
   * checkForDuplicateServiceRequests
   *
   * This function will check for duplicate service requests based on the type and location.
   * @author Darkis
   */
  public void checkForDuplicateServiceRequests() {
    if (serviceType != null) {
      List<ServiceRequestType__c> typeList = [Select Id, Service_Name__c From ServiceRequestType__c Where Id = :serviceType];
      if (typeList.size() > 0) {
        List<Case> tempDuplicateSRList = ServiceRequestsHelper.getDuplicateServiceRequests(
                                                                                           null,
                                                                                           typeList[0].Service_Name__c,
                                                                                           requestMapCoords.get('longitude'),
                                                                                           requestMapCoords.get('latitude')
        );

        if (tempDuplicateSRList != null) {
          System.debug('---> Duplicates found: ' + tempDuplicateSRList);
          duplicateServiceRequests = tempDuplicateSRList;
        }
      }
    }
  }
  /**
   * getIsBulkCollectionAddressSet
   * 
   * This function will verify if the current type is indeed a bulk collection and the address has been initilized.
   *   Bulk collections require the location before proceeding with their flex notes to find the scheduled date for collection.
   * @author Darkis
   */
  public Boolean getIsBulkCollectionAddressSet() {
    System.debug('----> SRAddress: ' + srAddress);
    if (String.isBlank(serviceType) || (serviceType.equalsIgnoreCase(bulkscheduleTypeId) && srAddress == null)) {
      return false;
    }
    return true;
  }

  /*---------------TODO: Move/Clean/Trim logic below this line---------------------*/

  /**
   * retrieveFlexNoteQuestions
   * 
   * This function will get all the flex notes for a specified service request type and place them in a 
   *   readable format for the visualforce page.
   * @author Darkis
   */
  public PageReference retrieveFlexNoteQuestions() {
    serviceTypeQuestions = new List<ServiceRequestQuestionWrapper> ();

    try {
      // If the current service type is Bulk Collection then ensure that the address is set before showing additional information section.  
      if (serviceType.equalsIgnoreCase(bulkscheduleTypeId) && !getIsBulkCollectionAddressSet()) {
        return null;
      }

      if (!String.isBlank(serviceType)) {
        Set<Id> flexNoteQuestionIds = new Set<Id> ();
        Map<Id, ServiceRequestTypeFlexNote__c> questionRelationMap = new Map<Id, ServiceRequestTypeFlexNote__c> ();
        // Fetch the flex note question mapping to the service requests.
        fetchFlexNoteQuestionMap();
        fetchNamePickListValues();
        // Get all the service request type flex notes.
        for (ServiceRequestTypeFlexNote__c srFlexNote :[Select Service_Request_Type__c, Order__c, IsReadOnly__c, DisplaySortOrder__c, IsRequiredQuestion__c, FlexNote_Question__r.QuestionAlias__c, FlexNote_Question__c, isRequired__c From ServiceRequestTypeFlexNote__c Where Service_Request_Type__c = :serviceType Order By DisplaySortOrder__c ASC]) {
          flexNoteQuestionIds.add(srFlexNote.FlexNote_Question__c);
          questionRelationMap.put(srFlexNote.FlexNote_Question__c, srFlexNote);
        }

        List<QuestionAnswerWrapper> tempFlexNotesList = new List<QuestionAnswerWrapper> ();
        for (Id tempflexNoteQuest : flexNoteQuestionIds) {
          System.debug('----> Question Map: ' + questionRelationMap.get(tempflexNoteQuest));
          QuestionAnswerWrapper qA = new QuestionAnswerWrapper(flexNoteIdMap.get(tempflexNoteQuest), questionRelationMap.get(tempflexNoteQuest));

          // if edit mode enabled append answers
          if (caseToClone != null) {
            if (QuestionAnswerMap != null) {
              if (QuestionAnswerMap.size() > 0) {
                if (flexNoteIdMap != null) {
                  if (flexNoteIdMap.size() > 0) {
                    if (QuestionAnswerMap.get(flexNoteIdMap.get(tempflexNoteQuest).Questions__c) != null) {
                      string tempAns = (QuestionAnswerMap.get(flexNoteIdMap.get(tempflexNoteQuest).Questions__c));
                      System.debug('----> tempAns: ' + tempAns);
                      if (tempAns != null) {
                        qA.answer.Answer__c = tempAns; //2209
                      }
                    }
                  }
                }
              }
            }
          } // end if 

          if (flexNoteIdMap != null) {
            System.debug('----> Step 1');
            if (flexNoteIdMap.size() > 0) {
              System.debug('----> Step 2');
              if (flexNoteIdMap.get(tempflexNoteQuest) != null) {
                System.debug('----> Step 3');
                if (flexNoteIdMap.get(tempflexNoteQuest).Answer_Type__c != null) {
                  System.debug('----> Step 4: Answer_Type__c != null');
                  // fetching picklist values from decode obj or from flexnotequestion 
                  if (flexNoteIdMap.get(tempflexNoteQuest).Answer_Type__c == 'Picklist') {
                      System.debug('----> FlexNote Type: Picklist');
                      System.debug('----> flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c: ' + flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c);
                    // Converting string to picklist and adding to questionAnswerwrapper list ,based on type
                    if (flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c != null) {
                      string picklistOptions = nameDecodeValueMap.get(flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c);
                      System.debug('----> picklistOptions: ' + picklistOptions);
                      list<Decode_Object__c> decodeList = picklistNameDecodeMap.get(flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c);
                      System.debug('----> decodeList: ' + decodeList);  
                      if (decodeList == null || decodeList.isEmpty()) {
                        picklistOptions = flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c;
                        qA.questionPicklistValues = retrievePicklistValues(picklistOptions); //0409
                      } else {
                        qA.questionPicklistValues = retrievePicklistValues(decodeList); //0409
                      }
                    }
                  }
                  // fetching multipicklist values from decode or flexnotequestion 
                  if (flexNoteIdMap.get(tempflexNoteQuest).Answer_Type__c == 'MultiPicklist') {
                      System.debug('----> FlexNote Type: MultiPicklist');
                    if (flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c != null) {
                      list<Decode_Object__c> decodeList = picklistNameDecodeMap.get(flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c);

                      if (decodeList == null || decodeList.isEmpty()) {
                        qA.questionMultiPicklistValueList = retriveMultiPickListSelectOption(flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c);
                      } else {
                        qA.questionMultiPicklistValueList = retriveMultiPickListSelectOption(decodeList);
                      }
                    }
                    // If there are multi-picklist answers then add them and ensure they are flagged.
                    if (qA.answer.Answer__c != null) {
                      List<String> answerList = convertStringToAnswerList(qA.answer.Answer__c);
                      // If the answer list is not null and isn't empty.
                      if (answerList != null && !answerList.isEmpty()) {
                        List<String> ansList = new list<string> ();

                        for (string ansItem : answerList) {
                          for (QuestionMultiPickListWrapper qAnswers : qA.questionMultiPicklistValueList) {
                            if (ansItem == qAnswers.flexNoteSelectItem.getValue()) {
                              System.debug('----> QuestionMultiPickListWrapper: ' + qAnswers);
                              ansList.add(ansItem);
                              qAnswers.selectedMultipicklist = ansList;
                              qAnswers.isSelectedQuestion = true;
                            }
                          }
                        }
                      }
                    }
                  }

                  // ADDING DEFAULT VALUES
                  if (flexNoteIdMap.get(tempflexNoteQuest).Answer_Type__c == 'Text') {
                    System.debug('----> FlexNote Type: Text');
                    if (flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c != null) {
                      if (qA.answer.Answer__c == null) {
                        qA.answer.Answer__c = flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c;
                        System.debug('----> Default values: ' + qA.answer.Answer__c);
                      }
                    }
                  }

                  if (flexNoteIdMap.get(tempflexNoteQuest).Answer_Type__c == 'Text') {
                    System.debug('----> FlexNote Type: Text');
                    if (flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c != null && srAddress != null) {
                      System.debug('----> qA.answer.Answer__c: ' + qA.answer.Answer__c);
                      if (qA.answer.Answer__c == '{!value}') {
                        // Check the case for an existing bulk schedule date. 
                        BulkSchedule__c bS = fetchBulkScheduleDetails(srAddress.returnDataset.Table1[0].WARD, 'DailyLimit');
                        if (bS != null) {
                          qA.answer.Answer__c = string.valueOf(bS.ScheduleDate__c.format());
                          if (bS.ScheduleDate__c != null) {
                            if (!bulkScheduleMap.containsKey(bS.ScheduleDate__c)) {
                              bulkScheduleMap.put(bS.ScheduleDate__c, bS);
                              system.debug('----> BulkScheduleMap: ' + bulkScheduleMap);
                            }
                          }
                        } else {
                          qA.answer.Answer__c = 'No dates available';
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          tempFlexNotesList.add(qA);
          system.debug('questionanswer-->' + tempFlexNotesList);
        }

        for (ServiceRequestType__c temp :[Select i.Object__c, i.Name, i.Id From ServiceRequestType__c i where Id = :serviceType]) {
          ServiceRequestQuestionWrapper sRQW = new ServiceRequestQuestionWrapper(temp, tempFlexNotesList);
          serviceTypeQuestions.add(sRQW);
        }

        for (ServiceRequestQuestionWrapper srqw : serviceTypeQuestions) {
          for (QuestionAnswerWrapper srw : srqw.questionAnswerList) {
            System.debug('----> QuestionAnswerWrapper');
            System.debug(srw);
            System.debug('----> QAW => ' + srw.flexNoteQuestion.Questions__c);
          }
        }
      }
    } catch(Exception e) {
      System.debug('Error: ' + e.getMessage());
    }
    return null;
  }

  // creating map of flexnotequestion id and flexnotequestion        
  private void fetchFlexNoteQuestionMap() {
    for (FlexNoteQuestion__c flexQuestion :[select id, name, AnswerValues__c, QuestionAlias__c, Answer_Type__c, Questions__c, Required__c from FlexNoteQuestion__c]) {
      flexNoteIdMap.put(flexQuestion.id, flexQuestion);
    }
  }

  // 0810 retrieve picklist values from decode object
  private list<SelectOption> retrievePicklistValues(list<Decode_Object__c> decodeList) {
    List<SelectOption> picklistOptions = new List<SelectOption> ();
    List<SelectOption> defaultpicklistOption = new List<SelectOption> ();
    for (Decode_Object__c dItems : decodeList) {
      if (dItems.Code__c != null && dItems.Value__c != null)
      picklistOptions.add(new selectOption(dItems.Code__c, dItems.Value__c));
    }
    // adding default Option
    defaultpicklistOption.add(new SelectOption('', '--None--'));
    defaultpicklistOption.addAll(picklistOptions);
    return defaultpicklistOption;
  }

  // converting comma seperated string into picklist values 
  private list<SelectOption> retrievePicklistValues(string commaSeperatedString) {
    List<SelectOption> Options = new List<SelectOption> ();

    List<SelectOption> Options1 = new List<SelectOption> ();

    if (commaSeperatedString == null) return null;
    system.debug('commaSeperatedString---' + commaSeperatedString);
    // spliting comma seperated string 

    if (commaSeperatedString.contains(',')) {
      list<string> picklistValues = commaSeperatedString.split(',');
      for (Integer p = 0; p < picklistValues.size(); p++) {
        if (picklistValues[p].contains(':')) {
          Options1.add(new SelectOption(picklistValues[p].split(':') [0], picklistValues[p].split(':') [1]));
        }
        else {
          Options1.add(new SelectOption(picklistValues[p], picklistValues[p]));
        }
      }
    }
    else {
      Options1.add(new SelectOption(commaSeperatedString, commaSeperatedString));
    }
    // adding default Option
    Options.add(new SelectOption('', '--None--'));
    Options.addAll(Options1);
    system.debug('Options--->' + Options);
    return Options;
  }

  // converting comma seperated string into Multi picklist values 
  private list<QuestionMultiPickListWrapper> retriveMultiPickListSelectOption(string commaSeperatedString) {
    list<QuestionMultiPickListWrapper> Options = new list<QuestionMultiPickListWrapper> ();
    if (commaSeperatedString == null) return null;
    if (commaSeperatedString.contains(',')) {
      // spliting comma seperated string 
      list<string> picklistValues = commaSeperatedString.split(',');
      for (Integer k = 0; k < picklistValues.size(); k++) {
        if (picklistValues[k].contains(':')) {
          Options.add(new QuestionMultiPickListWrapper(new SelectOption(picklistValues[k].split(':') [0], picklistValues[k].split(':') [1])));
        } else {
          Options.add(new QuestionMultiPickListWrapper(new SelectOption(picklistValues[k], picklistValues[k])));
        }
      }
    }
    else {
      Options.add(new QuestionMultiPickListWrapper(new SelectOption(commaSeperatedString, commaSeperatedString)));
    }
    return Options;
  }

  private list<QuestionMultiPickListWrapper> retriveMultiPickListSelectOption(list<Decode_Object__c> decodeList) {
    List<QuestionMultiPickListWrapper> picklistOptions = new List<QuestionMultiPickListWrapper> ();
    for (Decode_Object__c dItems : decodeList) {
      if (dItems.Code__c != null && dItems.Value__c != null)
      picklistOptions.add(new QuestionMultiPickListWrapper(new selectOption(dItems.Code__c, dItems.Value__c)));
    }
    return picklistOptions;
  }

  // convert string into list of string   
  private list<string> convertStringToAnswerList(string answerStr) {
    if (answerStr == null) return null;

    list<string> aswerStrList = new list<string> ();
    if (answerStr.contains(',')) {
      list<string> tempAnswerStrList = answerStr.split(',');
      system.debug('splited string --' + tempAnswerStrList);
      aswerStrList.addAll(tempAnswerStrList);
    }
    else {
      system.debug('non splited string --' + answerStr);
      aswerStrList.add(answerStr);
    }

    if (aswerStrList.isEmpty()) return null;

    return aswerStrList;
  }

  private BulkSchedule__c fetchBulkScheduleDetails(String ward, String DailyLimit) {
    String scheduleDate;

    if (!String.isBlank(ward)) {
      SObject sobj = ServiceRequestsHelper.getFlexNoteDefault(ward, DailyLimit);

      if (sobj != null) {
        BulkSchedule__c bS = (BulkSchedule__c) sobj;
        scheduleDate = String.valueOf(bS.ScheduleDate__c.format());
        System.debug('----> BULK SCHEDULE: ' + bS);
        return bS;
      }
    }
    return null;
  }

  public PageReference storeJson() {
    caseObjJson = Apexpages.currentPage().getParameters().get('caseObjJson');
    this.setBlockAddressInformation(); 
    return null;
  }
    
  public Boolean getIsBulkCollectionType() {
    if (String.isNotBlank(serviceType) && serviceType.equalsIgnoreCase(bulkscheduleTypeId)) {
      return true;    
    }        
    return false;
  }

  /**
   * Save
   * 
   * This function will accept a json object for the case and it's flex notes. It will then save the entry and send the user to the view page.
   * @author Darkis
   */
  public PageReference save() {
    System.debug('----> Save: Processing...'); 

    if (!String.isBlank(caseObjJson)) {
      Case tempSnowCase = new Case();
      ServiceRequestWrapper srw = new ServiceRequestWrapper();

      try {
        srw = (ServiceRequestWrapper) JSON.deserialize(caseObjJson, ServiceRequestWrapper.class);
      } catch(Exception e) {
        System.debug('----> Error occured parsing JSON: ' + e.getMessage());
        return null;
      }
      System.debug('----> Save: serviceType => ' + serviceType);
      List<ServiceRequestType__c> srtList = [Select Id, Service_Name__c, ContactStatus__c, ServiceLocationRequired__c From ServiceRequestType__c Where Id = :serviceType Limit 1];
      ServiceRequestType__c srt = srtList.size() > 0 ? srtList[0] : null;
        
      if (srt == null) {
        errorMessage = 'Cannot save request. Service request type requested is not found.';
        return null;      
      }   
        
      Boolean isContactReq = isContactRequiredToCreateCase(srt.ContactStatus__c, srw.contact);

      // Ensure the Case object is not null.
      if (srw.c != null && srw.flexnotes != null && isContactReq != null) {
        if (srAddress != null && srAddress.returnDataset.Table1[0] != null && srAddress.returnDataset.Table1[0].LATITUDE != null && srAddress.returnDataset.Table1[0].LONGITUDE != null) {
          if (!Test.isRunningTest()) {
            tempSnowCase.GeoLocation__Latitude__s = Decimal.valueOf(srAddress.returnDataset.Table1[0].LATITUDE);
            tempSnowCase.GeoLocation__Longitude__s = Decimal.valueOf(srAddress.returnDataset.Table1[0].LONGITUDE);
            tempSnowCase = SnowController.retrieveSnowInformation(tempSnowCase);
            System.debug('-----> Snow Case: ' + tempSnowCase);
          }
        }

        // Set a save point for the DB.
        SavePoint savepoint = Database.setSavePoint();

        try {
          // Validate the flexnote data.
          if (validateFlexnoteData(srw.flexnotes)) {
            // If the contact is required then ensure all data is present. 
            if (isContactReq) {
              if (String.isBlank(srw.contact.FirstName)) {
                errorMessage = 'Cannot save request. Contact first name must be completed.';
                return null;
              }

              if (String.isBlank(srw.contact.LastName)) {
                errorMessage = 'Cannot save request. Contact last name must be completed.';
                return null;
              }

              if (String.isBlank(srw.contact.Email)) {
                errorMessage = 'Cannot save request. Contact email must be completed.';
                return null;
              }
            }

            // If data is provided for the contact then verify there are no duplicates and upsert it.
            if (!String.isBlank(srw.contact.LastName) && !String.isBlank(srw.contact.Email)) {
              System.debug('----> [Contact]: Processing...');
              // If an existing id already exists. 
              if (srw.contact.Id != null) {
                srw.contact = doContactUpsert(srw.contact, null);
              } else {
                // Check for a duplicate entry.
                List<Contact> duplicateCon = [Select Id, FirstName, LastName, Email From Contact Where Email = :srw.contact.Email ORDER BY CreatedDate DESC Limit 1];
                // If there is no duplicate then create an account.
                if (duplicateCon == null || duplicateCon.size() == 0) {
                  srw.contact = doContactUpsert(
                                                srw.contact,
                                                ServiceRequestsHelper.createPersonalAccount(new Map<String, String> { 'lastname' => srw.contact.LastName, 'firstname' => srw.contact.FirstName })
                  );
                } else {
                  srw.contact.Id = duplicateCon[0].Id;
                  srw.contact = doContactUpsert(srw.contact, null);
                }
              }
              System.debug(srw.contact);
              System.debug('----> [Contact]: Completed');
            }
            System.debug('-----> Contact Id: ' + srw.contact.Id);
            // Case Processing
            System.debug('----> [Case]: Processing...');
            Case caseObj = retrieveCaseDetails(srw.contact, srw.c, srt);
            // So long as the snow case is available then set the two snow portions. 
            if (tempSnowCase != null && tempSnowCase.SnowRoute__c != null && tempSnowCase.SnowZone__c != null) {
              caseObj.SnowRoute__c = tempSnowCase.SnowRoute__c;
              caseObj.SnowZone__c = tempSnowCase.SnowZone__c;
            }
            // Ensure the case object returned from processing did not have an error.
            if (caseObj != null) {
              // Ensure Address Validation if required.
              if (srt.ServiceLocationRequired__c != null && srt.ServiceLocationRequired__c) {
                System.debug('----> [Case] Service Location is required. Verifying present addess...');
                if (caseObj.Address__c == null) {
                  System.debug('----> No address found. Rolling back changes...');
                  Database.rollback(savepoint);
                  errorMessage = 'Service Request unable to be saved. Please verify that all address information is present and try again.';  
                  return null;
                }
              }
              // Assign the case source.
              caseObj.Case_Source__c = 'Agent';
              // Assigning case to default active assignment rule
              Database.DMLOptions dmo = new Database.DMLOptions();
              dmo.assignmentRuleHeader.useDefaultRule = true;
              caseObj.setOptions(dmo);
              System.debug('----> Case To Insert: ' + caseObj);
              upsert(caseObj);
              System.debug('----> [Case]: Completed');

              // FlexNote Processing.
              System.debug('----> [FlexNote__c]: Processing...');
              for (FlexNote__c note : srw.flexnotes) {
                note.Case__c = caseObj.Id;
              }

              if (srw.flexnotes != null && !srw.flexnotes.isEmpty()) {
                upsert(srw.flexnotes);

                if (srt != null && srt.Id == bulkscheduleTypeId) {
                  upsertSRBulkSchedule(caseObj);
                }
                System.debug('----> [FlexNote__c]: Completed');

                try {
                  System.debug('----> [Console311_CaseController] Attempting to send new email for Bulk Collections...');
                  // Send creation email if Bulk Collection type.
                  if (srt != null && srt.Id == bulkscheduleTypeId) {
                    System.debug('----> [Console311_CaseController] Sending email to Contact to inform of Bulk Case Creation...');
                    WorkflowProcessUtility.sendTemplatedEmail(new List<String> (), new List<String> (), 'SR_HTML_Creation_Confirm_Bulk_Collection', caseObj.ContactId, caseObj.Id, null, false, null);
                  }
                } catch(Exception e) {
                  System.debug('----> [Console311_CaseController] Attempt to send email failed. No creations email sent to User.');
                }

                caseId = caseObj.Id;
                try {
                  List<Case> caseName = [Select Service_Request_Number__c From Case Where Id = :caseObj.Id];
                  caseNumber = caseName.get(0).Service_Request_Number__c;
                } catch(Exception e) {
                  System.debug('----> Unable to get case number for Id: ' + caseObj.Id);
                  caseNumber = '';
                }
              }
            }
          }
        } catch(Exception e) {
          System.debug('----> Error: ' + e.getMessage());
          Database.rollback(savepoint);
          errorMessage = 'An error has occured saving your request. Please try again.';
        }
      }
      System.debug('---> Wrapper: ' + srw);
    }
    System.debug('----> Save: End');
    return null;
  }

  /**
   * retrieveCaseDetails
   *
   * @author Darkis
   * @description This function will ensure that all remaining case date is now added.
   * @param con Contact The contact made by the user.
   * @param caseRecord Case The active case object with the users entries.
   * @param srt ServiceRequestType__c The type for the request. 
   * @return Case
   */
  private Case retrieveCaseDetails(Contact con, Case caseRecord, ServiceRequestType__c srt) {
    try {
      // Set the contact id on the case if available.
      if (con != null && con.Id != null) {
        caseRecord.contactId = con.Id;
      }
      // Add Service Type ID to the case.
      if (serviceType != null) {
        caseRecord.SRType__c = srt.Id;
      }
      // Set the service name for the type.
      if (srt.Service_Name__c != null) {
        caseRecord.Subject = srt.Service_Name__c;
      }
      // Get the jurisdication for the case.
      if (getSRJurisdication(srt.Id) != null) {
        caseRecord.SRType_Jurisdiction__c = getSRJurisdication(srt.Id).Id;
      }
      // Address Section
      if (srAddress != null) {
        IncapsulateDCM.DcMarLocation addressInformation = srAddress.returnDataset.Table1[0];
        // Set the Address__c       
        if (!String.isBlank(addressInformation.FULLADDRESS) && !String.isBlank(addressInformation.CITY) && !String.isBlank(addressInformation.STATE) && !String.isBlank(addressInformation.ZIPCODE)) {
          caseRecord.Address__c = addressInformation.FULLADDRESS + ',' + addressInformation.CITY + ',' + addressInformation.STATE + ',USA,' + String.valueOf(Integer.valueOf(addressInformation.ZIPCODE));
        } else if (String.isNotBlank(this.mBlockName) && String.isNotBlank(this.mFullBlock)) {
          caseRecord.Address__c = this.mBlockName;  
        }
        // Longitude and Latitude     
        if (!String.isBlank(String.valueOf(addressInformation.LATITUDE))) caseRecord.GeoLocation__Latitude__s = addressInformation.LATITUDE;
        if (!String.isBlank(String.valueOf(addressInformation.LONGITUDE))) caseRecord.GeoLocation__Longitude__s = addressInformation.LONGITUDE;
        // Address Id
        if (!String.isBlank(String.valueOf(addressInformation.ADDRESS_ID))) caseRecord.AddressID__c = String.valueOf(Integer.valueOf(addressInformation.ADDRESS_ID));
        // RoadwaySegId
        if (!String.isBlank(String.valueOf(addressInformation.ROADWAYSEGID))) caseRecord.RoadwaySegId__c = String.valueOf(Integer.valueOf(addressInformation.ROADWAYSEGID));
        // Intersection Address
        if (!String.isBlank(addressInformation.FULLINTERSECTION)) caseRecord.Address__c = addressInformation.FULLINTERSECTION;
        // Address Alias
        if (!String.isBlank(addressInformation.ALIASNAME)) {
          if (addressInformation.ALIASNAME.length() > 28) {
            caseRecord.AliasName__c = addressInformation.ALIASNAME.substring(0, 28); // added due to alias 30 length
          } else {
            caseRecord.AliasName__c = addressInformation.ALIASNAME;
          }
        }
        // Intersection Data
        if (!String.isBlank(String.valueOf(addressInformation.intersectionId))) caseRecord.IntersectionId__c = String.valueOf(Integer.valueOf(addressInformation.intersectionId));
        if (!String.isBlank(addressInformation.quadrant)) caseRecord.Quadrant__c = addressInformation.quadrant;
        if (!String.isBlank(String.valueOf(addressInformation.XCOORD))) caseRecord.XCOORD__c = String.valueOf(addressInformation.XCOORD);
        if (!String.isBlank(String.valueOf(addressInformation.YCOORD))) caseRecord.YCOORD__c = String.valueOf(addressInformation.YCOORD);
        if (!String.isBlank(addressInformation.ANC)) caseRecord.ANC__c = addressInformation.ANC;
        if (!String.isBlank(addressInformation.PSA)) caseRecord.PSA__c = addressInformation.PSA;
        if (!String.isBlank(addressInformation.WARD)) caseRecord.Ward__c = addressInformation.WARD;
        if (!String.isBlank(addressInformation.SMD)) caseRecord.SMD__c = addressInformation.SMD;
        if (!String.isBlank(addressInformation.POLDIST)) caseRecord.POlDistrict__c = addressInformation.POLDIST;

        // TODO -- Verify with John that these are still returning/stored in the new MAR service.
        //if(!addressInformation.CLUSTER.equals(''))caseRecord.Cluster__c =addressInformation.CLUSTER;
        
        // @Bhaskar N:11/10/2016:Uncommented below if statement to execute FULL Block Address Type per JIRA User story
        // @Darkis 11/15/2016 Line recommented due to incompatibility with the DCMAR package. Block address' are not currently supported. 
        /*
        if(!addressInformation.FULLBLOCK.equals('') && !addressInformation.BLOCKNAME.equals('')){
          caseRecord.Address__c = addressInformation.BLOCKNAME+','+addressInformation.CITY+','+addressInformation.STATE +',USA,'+addressInformation.ZIPCODE;
        }
		*/

        //if(!addressInformation.FULLBLOCK.equals(''))caseRecord.FullBlock__c =addressInformation.FULLBLOCK;
        //if(!addressInformation.BLOCKNAME.equals(''))caseRecord.BlockName__c =addressInformation.BLOCKNAME;
      }

      System.debug('----> [Console311_CaseCtrl:Save] duplicateServiceRequests: ' + duplicateServiceRequests.size());
      if (duplicateServiceRequests != null && duplicateServiceRequests.size() > 0) {
        for (Case duplicateC : duplicateServiceRequests) {
          System.debug('----> [Console311_CaseCtrl:Save] Checking for parent case of duplicate...');
          if (duplicateC.Status.equalsIgnoreCase('Open')) {
            System.debug('----> [Console311_CaseCtrl] Found parent case of current duplicate. Setting parent id for duplicate...');
            caseRecord.ParentId = duplicateC.Id;
          }
        }
      }
    } catch(exception e) {
      System.debug('An error has occured processing the case data: ' + e.getMessage());
      throw new CustomException(e); // custom Exception message added
      return null;
    }
    return caseRecord;
  }

  /**
   * upsertSRBulkSchedule
   *
   * @author Darkis
   * @description This function will upsert any bulk schedule SR's with the correct schedule date. 
   * @param caseRrd 
   */
  private void upsertSRBulkSchedule(Case caseRrd) {
    List<ServiceRequestBulkSchedule__c> serviceBulkScheduleToUpsert = new List<ServiceRequestBulkSchedule__c> ();
    for (Date bSItem : bulkScheduleMap.keySet()) {
      if (isValidBulkScheduleDate(bSItem, caseRrd.Ward__c)) return;

      ServiceRequestBulkSchedule__c sRBS = new ServiceRequestBulkSchedule__c();
      sRBS.BulkSchedule__c = bulkScheduleMap.get(bSItem).Id;
      sRBS.ServiceRequest__c = caseRrd.Id;
      sRBS.SRBulkScheduleExtId__c = sRBS.BulkSchedule__c + '-' + sRBS.ServiceRequest__c;
      sRBS.Status__c = 'Open';
      serviceBulkScheduleToUpsert.add(sRBS);
    }

    try {
      if (!serviceBulkScheduleToUpsert.isEmpty()) upsert serviceBulkScheduleToUpsert SRBulkScheduleExtId__c;
    } catch(exception e) {
      system.debug('unable to complete Process of Upsert of servicerequestbulkschedule due--' + e);
      throw new CustomException(e); // custom Exception message added
    }
  }

  /**
   * isValidBulkScheduleDate
   *
   * @author Darkis
   * @description This function will determine the given schedule date and ward have a valid bulk schedule date. 
   * @param scheduleDate The prepared scheduled date for processing.
   * @param Ward The designated ward. 
   * @return Boolean 
   */
  private Boolean isValidBulkScheduleDate(Date scheduleDate, String Ward) {
    for (BulkSchedule__c bs :[Select id, Name, ServiceRequestBulkScheduleCount__c, ScheduleDate__c, Ward__c from BulkSchedule__c where ScheduleDate__c = :scheduleDate Order By ScheduleDate__c ASC limit 1]) {
      if (bs.Ward__c.contains(Ward)) {
        if (bs.ServiceRequestBulkScheduleCount__c > = OUCServiceRequestConfig__c.getValues('DailyLimit').BulkScheduleDailyStopLimit__c) {
          throw new CustomException('DailyStopLimit for bulk schedule has been crossed');
          return true;
        }
      }
    }
    return false;
  }

  /**
   * isContactRequiredToCreateCase
   *
   * @author Darkis
   * @description This function will verify that for the specified type if a contact is required or not.
   * @param contactStatus String The validation string for if a contact is necessary.
   * @param con Contact The contact object to save.
   * @return Boolean 
   */
  private Boolean isContactRequiredToCreateCase(String contactStatus, Contact con) {
    Boolean isContactReq = false;
    try {
      if (contactStatus == 'Required (LN, FN, EM)') {
        isContactReq = (con == null ? null : true);
      } else {
        if (!String.isBlank(con.LastName) || !String.isBlank(con.firstName) || !String.isBlank(con.phone) || !String.isBlank(con.email)) {
          isContactReq = true;
        }
      }
    } catch(exception e) {
      system.debug('----> Unable to complete process for contact validation: ' + e.getMessage());
      throw new CustomException(e); // custom Exception message added
    }
    return isContactReq;
  }

  /**
   * validateFlexnoteData
   *
   * @author Darkis
   * @description This function will validate the date fields of the flexnotes along with ensuring all required questions have answers.
   * @param flexNotes List<FlexNote__c> List of the flexnotes to save.
   * @return Boolean 
   */
  private Boolean validateFlexnoteData(List<FlexNote__c> flexNotes) {
    for (ServiceRequestQuestionWrapper srqw : serviceTypeQuestions) {
      for (QuestionAnswerWrapper qaWrap : srqw.questionAnswerList) {
        FlexNote__c currentAnswer;
        // Loop through the obtained flexnote results. Get the associated QA wrapper and validate the contents. 
        for (FlexNote__c fNote : flexnotes) {
          String comparableStr = qaWrap.flexNoteQuestion.Questions__c.replaceAll('(\\s+)', ' ');
          if (comparableStr.equalsIgnoreCase(fNote.Questions__c)) {
            currentAnswer = fNote;
            break;
          }
        } // End: Flexnote loop.
        // If the answer is required then ensure it isn't blank.
        if ((qaWrap.relationQuestion.isRequired__c && currentAnswer == null) || (qaWrap.relationQuestion.isRequired__c && String.isBlank(currentAnswer.Answer__c))) {
          return false;
        }
        // Validate date/time fields.
        if (qaWrap.flexNoteQuestion.Answer_Type__c == 'Date/Time' && !String.isBlank(currentAnswer.Answer__c)) {
          Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d) ([0-1]?[0-9]|[2][0-3]):([0-5][0-9]) (AM|PM)');
          Matcher MyMatcher = MyPattern.matcher(currentAnswer.Answer__c);

          if (!MyMatcher.matches()) {
            return false;
          }
        }
        // Validate the date field.
        if (qaWrap.flexNoteQuestion.Answer_Type__c == 'Date' && !String.isBlank(currentAnswer.Answer__c)) {
          Pattern datePattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)');
          Matcher dateMatcher = datePattern.matcher(currentAnswer.Answer__c);

          if (!dateMatcher.matches()) {
            return false;
          }
        }
        // If the current type is bulk collection verify that the answer is not the default {!Value}.
        if (qaWrap.flexNoteQuestion.Answer_Type__c == 'Text' && serviceType.equalsIgnoreCase(bulkscheduleTypeId) && !String.isBlank(currentAnswer.Answer__c) && currentAnswer.Answer__c.equalsIgnoreCase('{!Value}')) {
          return false;
        }
      }
    }
    return true;
  }

  public PageReference rerenderKnowledgePanel() {
    System.debug('----> knowledgeKeyword: ' + knowledgeKeyword);
    System.debug('----> ApexPages.CurrentPage().getParameters().get("knowledgeKeyword")' + ApexPages.CurrentPage().getParameters().get('knowledgeKeyword'));

    return null;
  }
    
  @RemoteAction
  public static List<Contact> getContactDetails(String id) {
    return [Select Id, FirstName, LastName, Phone, Email, MailingStreet, MailingCity, MailingState, MailingStateCode, MailingCountry, MailingPostalCode From Contact Where Id = :id];        
  }

  private ServiceRequestType_Jurisdiction__c getSRJurisdication(string serviceTypeId) {
    list<ServiceRequestType_Jurisdiction__c> serviceTypeJuridication = [select id, name, SLA__c, Jurisdiction__r.Id, Jurisdiction__r.Agency__c, ServiceRequestType__r.Id, ServiceRequestType__r.Name from ServiceRequestType_Jurisdiction__c where ServiceRequestType__r.Id = :serviceTypeId Limit 1];

    if (serviceTypeJuridication.isEmpty()) return null;
    return serviceTypeJuridication[0];
  }

  /**
   * doContactUpsert
   *
   * @description This function will upsert a provided contact object. 
   * @param contactToBeUpsert The contact to be updated/inserted.
   * @param acc An optional account to tie to the contact.
   * @return contact 
   */
  private contact doContactUpsert(Contact contactToBeUpsert, Account acc) {
    if (contactToBeUpsert != null) {
      if (acc != null) {
        contactToBeUpsert.AccountId = acc.Id;
      }
      upsert(contactToBeUpsert);
    }
    return contactToBeUpsert;
  }

  private Map<String, String> retrieveQuestionAnswerMap(List<FlexNote__c> tempFlexNoteList) {
    Map<String, String> flexNoteQuestionMap = new Map<String, String> ();
    if (tempFlexNoteList.isEmpty()) return null;
    for (Integer j = 0; j < (tempFlexNoteList).size(); j++) {
      flexNoteQuestionMap.put(tempFlexNoteList[j].Questions__c, tempFlexNoteList[j].Answer__c);
    }
    return flexNoteQuestionMap;
  }

  private class ServiceRequestWrapper {
    public Case c { get; set; }
    public Contact contact { get; set; }
    public List<FlexNote__c> flexnotes { get; set; }

    public ServiceRequestWrapper() {

    }
  }
}