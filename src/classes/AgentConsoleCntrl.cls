/*  
 *   AgentConsoleCntrl Component Referred By AgentConsolePge  
 *   Replace Methods Description here
 *   CreatedBy:D M
 *   Copyright ?   All rights reserved.
*/

public with sharing class AgentConsoleCntrl {

  // holds search keywords like case number phone email and service request name
  public string selServicRequestNumber { get; set; }
  public string selContactPhone { get; set; }
  public string selServiceRequestType { get; set; }
  public string selContactEmail { get; set; }
  public string selServiceAddress { get; set; }
  public string copyServiceRequestType { get; set; }

  public Boolean isDuplicatesAvailable { get; set; }

  // holds case id
  public string selectedParamCaseId { get; set; }
  // initially its false ,it determines whether to include closed casess in search
  public boolean isClosedCases { get; set; }
  public boolean flexnotelabel { get; set; }

  private string contactQuery;
  // holds case list 
  public list<case> casesList { get; set; }
  // holds all details like case flexnotes servicerequest type
  public ContactCaseFlexNoteWrapper contactCaseFlexNote { get; set; }
  // holds validation address 
  public LocationWrapper locationData { get; set; }
  // holds suggestion address list
  public list<LocationWrapper> resultAddress { get; set; }
  // holds question and answer used in edit mode
  private map<string, string> QuestionAnswerMap;

  // determines whether edit mode or new mode
  private boolean isNewMode;
  private string priorServiceTypeName;
  private map<Id, FlexNoteQuestion__c> flexNoteIdMap = new map<Id, FlexNoteQuestion__c> ();

  private map<string, string> nameDecodeValueMap = new map<string, string> ();
  private map<string, list<Decode_Object__c>> picklistNameDecodeMap = new map<string, list<Decode_Object__c>> ();
  map<Date, BulkSchedule__c> bulkScheduleMap = new map<Date, BulkSchedule__c> ();
  set<ServiceRequestBulkSchedule__c> sRBS = new set<ServiceRequestBulkSchedule__c> ();
  public list<FlexNote__c> clonedFlexNote = new list<FlexNote__c> ();

  public boolean isSearchSectionEnabled { get; set; }
  // holds potential duplicate servicerequests
  public list<case> duplicateSRList { get; set; }
  // determines whether clone button show or hide
  public boolean isCloneBtn { get; set; }
  public boolean isCloneBtn1 { get; set; }

  public boolean isCloned { get; set; }

  public boolean isErrorMsg { get { system.debug('isErrorMsg---->' + isErrorMsg); return isErrorMsg; } set; }
  public boolean isErrorMsgSr { get { system.debug('isErrorMsgSr---->' + isErrorMsgSr); return isErrorMsgSr; } set; }

  public List<SelectOption> wardPicklistOptions { get; set; }

  // not used below two need to remove 
  //public string selectedServiceRequestType1{get;set;}
  //map<string,OUC_Activity_History__c>caseActivityHistoryMap=new map<string,OUC_Activity_History__c>();
  //ServiceRequestDuplicateDetection sRDuplicateDetection=new ServiceRequestDuplicateDetection();
  //private map<string,ServiceRequestType__c>sRTIdMap=new map<string,ServiceRequestType__c>();
  //public list<ServiceRequestType__c>sRTypeList=new list<ServiceRequestType__c>();
  //map<Id,Contact>ContactIdMap=new map<Id,Contact>();
  //private map<Id,ServiceRequestType_Jurisdiction__c>sRTypeJurisMap=new map<Id,ServiceRequestType_Jurisdiction__c>();
  //map<Id,Jurisdiction__c>jurisIdMap=new map<Id,Jurisdiction__c>();
  //private map<Id,ServiceRequestType_Jurisdiction__c>juriSRTypeJuriMap=new map<Id,ServiceRequestType_Jurisdiction__c>();
  //private map<string,Id>serviceCodeSRTypeId=new map<string,Id>();
  //map<Id,ServiceRequestType__c>sRTypeIdMap=new map<Id,ServiceRequestType__c>();
  public AgentConsoleCntrl() {
    // include closes cases attribute
    //isClosedCases=false;
    isClosedCases = true;
    // initially clone button hide
    isCloneBtn = false;
    isCloneBtn1 = false;
    isCloned = false;

    isErrorMsg = false;
    isErrorMsgSr = false;

    flexnotelabel = false;

    isDuplicatesAvailable = false;

    contact con = new contact();
    ServiceRequestType__c tempSerivceRequestType = new ServiceRequestType__c();
    Case tempCase = new Case();
    list<FlexNote__c> tempFlexNotesList = new list<FlexNote__c> ();
    contactCaseFlexNote = new ContactCaseFlexNoteWrapper(con, tempSerivceRequestType, tempCase, tempFlexNotesList);

    List<AggregateResult> results;
    wardPicklistOptions = new List<SelectOption> ();
    wardPicklistOptions.add(new SelectOption('', ''));
    //TODO: 
    // Get all the wards for DPW cases to add to the picklist.
    //results = [Select Ward__c From Case Group By Ward__c];
    // Loop through the results and set the select options for the picklist.
    /*for(AggregateResult ward : results) {
      if ((String) ward.get('Ward__c') != null && !((String) ward.get('Ward__c')).isNumeric()) {
      wardPicklistOptions.add(new SelectOption((String) ward.get('Ward__c'), (String) ward.get('Ward__c')));
      }
      }*/
    wardPicklistOptions.add(new SelectOption('Ward 1', 'Ward 1'));
    wardPicklistOptions.add(new SelectOption('Ward 2', 'Ward 2'));
    wardPicklistOptions.add(new SelectOption('Ward 3', 'Ward 3'));
    wardPicklistOptions.add(new SelectOption('Ward 4', 'Ward 4'));
    wardPicklistOptions.add(new SelectOption('Ward 5', 'Ward 5'));
    wardPicklistOptions.add(new SelectOption('Ward 6', 'Ward 6'));
    wardPicklistOptions.add(new SelectOption('Ward 7', 'Ward 7'));
    wardPicklistOptions.add(new SelectOption('Ward 8', 'Ward 8'));

    QuestionAnswerMap = new map<string, string> (); // added to get the questionAnswer
    serviceRequestQuestionWrapList = new list<ServiceRequestQuestionWrapper> ();
    // initially declaring default values like city,country ,state
    locationData = new LocationWrapper();
    locationData.city = 'WASHINGTON';
    locationData.state = 'DC';
    locationData.Country = 'USA';

    // fetching flexnote questions
    fetchFlexNoteQuestionMap();
    // fetching name and picklist valuess
    fetchNamePickListValues();
    // determines Mode whether edit or new (here initially its in new mode when page load)
    isNewMode = true;

    // enabled to get invoked from portal  
    string caseRecordId = ApexPages.currentPage().getParameters().get('Id');
    if (caseRecordId != null) {
      selectedParamCaseId = caseRecordId;
      doRetreieveContactCasesFlexNotes();
    }

    // fetching serviceType Map
    //fetchSRTypeIdMap();

  }

  // fetching servicerequesttype jurisdiction based on service type id
  private ServiceRequestType_Jurisdiction__c getSRJurisdication(string serviceTypeId) {
    list<ServiceRequestType_Jurisdiction__c> serviceTypeJuridication = [select id, name, SLA__c, Jurisdiction__r.Id, Jurisdiction__r.Agency__c, ServiceRequestType__r.Id, ServiceRequestType__r.Name from ServiceRequestType_Jurisdiction__c where ServiceRequestType__r.Id = :serviceTypeId Limit 1];

    if (serviceTypeJuridication.isEmpty()) return null;
    return serviceTypeJuridication[0];
  }

  // creating map of flexnotequestion id and flexnotequestion        
  private void fetchFlexNoteQuestionMap() {
    for (FlexNoteQuestion__c flexQuestion :[select id, name, AnswerValues__c, QuestionAlias__c, Answer_Type__c, Questions__c, Required__c from FlexNoteQuestion__c]) {
      flexNoteIdMap.put(flexQuestion.id, flexQuestion);
    }
  }

  // invoked from javascript ,search based on serviceRequest type ,case number ,contactphone ,contactemail 

  public PageReference doSearch() {
    try {
      string tempQuery = 'Select c.Service_Request_Number__c,c.Expected_Resolution_Date__c,c.Address__c, AgencyCode__c,c.SLA__c,c.GeoLocation__Longitude__s, c.GeoLocation__Latitude__s, c.CaseNumber, c.Status, c.SRType__r.Service_Name__c, c.SRType__r.Name,c.SRType__r.Agency__c,c.SRType__r.Id,c.SRType__r.Default_Status__c, c.SRType__r.Default_Priority__c, c.SRType__r.Default_Method__c, c.SRType__c, c.Reason, c.Priority, c.Origin, c.IsClosed, c.Id, c.Contact.Email, c.Contact.Phone, c.Contact.FirstName, c.Contact.LastName, c.Contact.Id,c.CreatedDate,c.SRType__r.ContactRequired__c,c.SRType__r.ServiceLocationRequired__c,(Select Id, FlexNote_Question__c,Case__c,Questions__c, Answer_Date_Time__c,Answer__c From FlexNotes__r) From Case c where ';

      string queryStr = '';
      if (!selContactPhone.equals('')) {
        queryStr += ' And contact.phone Like \'' + string.escapesingleQuotes(selContactPhone) + '%\'';
      }
      if (!selContactEmail.equals('')) {
        queryStr += ' And contact.email Like \'' + string.escapesingleQuotes(selContactEmail) + '%\'';
      }

      if (!selServicRequestNumber.equals('')) {
        queryStr += ' And Service_Request_Number__c Like \'' + string.escapesingleQuotes(selServicRequestNumber) + '%\'';
      }

      if (!selServiceRequestType.equals('')) {
        queryStr += ' And SRType__r.Service_Name__c Like \'' + string.escapesingleQuotes(selServiceRequestType) + '%\'';
      }

      if (!selServiceAddress.equals('')) {
        queryStr += ' And Address__c Like \'%' + string.escapesingleQuotes(selServiceAddress) + '%\'';
        system.debug('selServiceAddress-->' + selServiceAddress);
      }

      if (isClosedCases == false) {
        if (!selContactPhone.equals('') || !selContactEmail.equals('') || !selServicRequestNumber.equals('') || !selServiceRequestType.equals('') || !selServiceAddress.equals('')) {
          queryStr += ' And IsClosed=false ';
          system.debug('filter close cases' + isClosedCases);
        }
      }

      if (selContactPhone.equals('') && selContactEmail.equals('') && selServicRequestNumber.equals('') && selServiceRequestType.equals('') && selServiceAddress.equals('')) {
        isErrorMsgSr = false;
        isErrorMsg = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Please Provide Search KeyWord.'));
        // isValid=false;
        return null;
      }
      else {
        queryStr += 'ORDER BY CaseNumber DESC LIMIT 100';
      }

      if (!queryStr.equals('')) {
        string filterStr = retrieveWhereClauseString(queryStr);
        system.debug('filterstring-->' + filterStr);
        tempQuery += filterStr;
        if (!filterStr.equals(''))
        retriveSearchResult(tempQuery);
      }
    }
    catch(exception e) {
      system.debug('Unable to complete SearchProcess due--' + e);
      ApexPages.addMessages(e);
    }

    return null;
  }


  // Used to remove the starting "And" keyword from filter condition
  private string retrieveWhereClauseString(string tempString) {
    if (tempString == null) return null;
    list<string> splittedString;
    if (tempString.startsWith(' And')) splittedString = tempString.split(' And', 2);
    // remove starting 'And' 
    tempString = splittedString[splittedString.size() - 1];
    system.debug('tempstring-->' + tempString);
    return tempString;
  }

  // fetches cases based on filter search if any present otherwise result nothing
  private void retriveSearchResult(string soqlStr) {
    if (soqlStr == null) return;
    try {
      casesList = database.query(soqlStr);
      if (casesList.isEmpty()) {
        isErrorMsg = true;
        isErrorMsgSr = false;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'There Are No Cases For a Given Search KeyWord.'));
      }

      if (casesList.size() == 1) {
        selectedParamCaseId = casesList[0].Id;
        doRetreieveContactCasesFlexNotes();
      }
    }
    catch(exception e) {
      isErrorMsg = true;
      isErrorMsgSr = false;
      system.debug('unable to complete query execution due--' + e);
      ApexPages.addMessages(e);
    }
  }

  // fetches overall all details like contact servicerequest flexnotes & tasks
  public pageReference doRetreieveContactCasesFlexNotes() {
    //contactCaseFlexNote=new ContactCaseFlexNoteWrapper();        
    isCloneBtn = true; // show clone button
    isCloneBtn1 = true;

    contact con = new contact();
    ServiceRequestType__c tempSerivceRequestType = new ServiceRequestType__c();
    case tempCase = new Case();
    list<FlexNote__c> tempFlexNotesList = new list<FlexNote__c> ();
    //list<CaseHistory>tempCaseHistory=new list<CaseHistory>();
    //list<ActivityHistory>tempActivityHistory=new list<ActivityHistory>();
    list<OUC_Activity_History__c> tempOUCActivityHistory = new list<OUC_Activity_History__c> ();
    QuestionAnswerMap = new map<string, string> (); // map added // 1708
    for (case caseItem :[Select c.Service_Request_Number__c, c.YCOORD__c, c.XCOORD__c, c.SMD__c, c.Quadrant__c, c.PSA__c, c.POlDistrict__c, c.IntersectionId__c, c.FullBlock__c, c.Cluster__c, c.BlockName__c, c.AliasName__c, c.AddressID__c, c.ANC__c, c.Address__c, c.Ward__c, c.Expected_Resolution_Date__c, c.GeoLocation__Longitude__s, c.AgencyCode__c, c.SLA__c, c.GeoLocation__Latitude__s, c.ClosedDate, c.CreatedDate, c.CaseNumber, c.Description, c.Status, c.SRType__r.Service_Name__c, c.SRType__r.Name, c.SRType__r.Id, c.SRType__r.Default_Status__c, c.SRType__r.Default_Priority__c, c.SRType__r.Default_Method__c, c.SRType__r.SR_Alert_Message__c, c.ParentId, c.SRType__c, c.Reason, c.Priority, c.Origin, c.IsClosed, c.Id, c.Contact.Email, c.Contact.Phone, c.Contact.FirstName, c.Contact.LastName, c.Contact.Id, c.ContactId, (Select Id, Questions__c, Order__c, FlexNote_Question__c, Answer_Date_Time__c, Answer__c From FlexNotes__r) From Case c where id = :selectedParamCaseId]) {
      if (caseItem.ContactId != null) {
        //con=ContactIdMap.get(caseItem.ContactId);
        con = retrieveContactDetails(caseItem.ContactId);
      }

      if (caseItem.SRType__r.Id != null) {
        //tempSerivceRequestType=sRTypeIdMap.get(caseItem.SRType__r.Id);
        tempSerivceRequestType = getSelServiceRequestType(caseItem.SRType__r.Id);

        // added to fill service code based on servicetype selected
        tempSerivceRequestType.Service_Name__c = caseItem.SRType__r.Service_Name__c;

        priorServiceTypeName = caseItem.SRType__r.Service_Name__c; // GETING sevice Name
        //tempSerivceRequestType.Service_Name__c=caseItem.SRType__r.Id;

        // added get servicetype selected
        selectedServiceRequestType = caseItem.SRType__r.Id;
        serviceType = caseItem.SRType__r.Id; //added 1808

        // invoking display message
        doDisplayAlertMsg(tempSerivceRequestType);

      } else if (caseItem.SRType__r.Id == null) { serviceType = null; selectedServiceRequestType = null; } // add on 2608

      //if(caseItem!=null){
      tempCase = caseItem;
      tempFlexNotesList = caseItem.FlexNotes__r;
      //tempActivityHistory=caseItem.ActivityHistories;

      tempOUCActivityHistory = fetchOUCActivityHistoryList(caseItem.Id);

      QuestionAnswerMap = retrieveQuestionAnswerMap(tempFlexNotesList);
      system.debug('QuestionAnswerMap---' + QuestionAnswerMap);

      //  include default values,if not present in case from servie type 
      if (tempCase.Status == null && caseItem.SRType__r.Default_Status__c != null) {
        tempCase.Status = caseItem.SRType__r.Default_Status__c;
      }
      if (tempCase.Priority == null && caseItem.SRType__r.Default_Priority__c != null) {
        tempCase.Priority = caseItem.SRType__r.Default_Priority__c;
      }
      if (tempCase.Origin == null && caseItem.SRType__r.Default_Method__c != null) {
        tempCase.Origin = caseItem.SRType__r.Default_Method__c;
      }
      //}

      contactCaseFlexNote = new ContactCaseFlexNoteWrapper(con, tempSerivceRequestType, tempCase, tempFlexNotesList);
      contactCaseFlexNote.selOUCActivity = tempOUCActivityHistory;

      // edit mode enabled
      isNewMode = false;
      // case not null fetch the flexnotes and questions details
      retrieveFlexNoteQuestions(); // 1808


    }

    selectedParamCaseId = null;
    return null;
  }

  // invoked from address validate button to get valid addrss if any 
  public void retrieveAdresses() {
    string addressStreet;
    string jsonstring;
    string newJsonstring;
    if (locationData.street != null) {
      addressStreet = locationData.street;
      if (Test.isRunningTest()) {
        jsonstring = '{"returnCodes":null,"details":"<STRONG>Parsed:</STRONG></br><EM>Street Name 1: </EM>14TH</br><EM>Street Type 1: </EM></br><EM>Quad 1: </EM></br><EM>Direction 1: </EM></br><EM>Street Name 2: </EM>U</br><EM>Street Type 2: </EM>STREET</br><EM>Quad 2: </EM></br><EM>Direction 2: </EM></br><STRONG>Possible Standard Street Names 1: </STRONG></br>14TH</br><STRONG>Possible Standard Street Names 2: </STRONG></br>U</br>","returnDataset":{"Table1":[{"MARID":903573.0,"INTERSECTIONID":15843.0,"STREET1ID":108723.0,"STREET2ID":100140.0,"ST1NAME":"U","ST1TYPE":"STREET","ST1QUAD":"NW","FULLSTREET1DISPLAY":"U STREET NW","ST2NAME":"14TH","ST2TYPE":"STREET","ST2QUAD":"NW","FULLSTREET2DISPLAY":"14TH STREET NW","FULLINTERSECTION":"U STREET NW AND 14TH STREET NW","REFX":397229.13001138,"REFY":138792.67999823,"NATIONALGRID":"18S UJ 23837 09529","LATITUDE":38.91699812128980,"LONGITUDE":-77.03195073766770,"ConfidenceLevel":62.5},{"MARID":903021.0,"INTERSECTIONID":15289.0,"STREET1ID":300140.0,"STREET2ID":308723.0,"ST1NAME":"14TH","ST1TYPE":"STREET","ST1QUAD":"SE","FULLSTREET1DISPLAY":"14TH STREET SE","ST2NAME":"U","ST2TYPE":"STREET","ST2QUAD":"SE","FULLSTREET2DISPLAY":"U STREET SE","FULLINTERSECTION":"14TH STREET SE AND U STREET SE","REFX":401268.25001513,"REFY":133120.61000897,"NATIONALGRID":"18S UJ 27750 03769","LATITUDE":38.86590545932130,"LONGITUDE":-76.985386353798,"ConfidenceLevel":62.5},{"MARID":903021.0,"INTERSECTIONID":15289.0,"STREET1ID":308723.0,"STREET2ID":300140.0,"ST1NAME":"U","ST1TYPE":"STREET","ST1QUAD":"SE","FULLSTREET1DISPLAY":"U STREET SE","ST2NAME":"14TH","ST2TYPE":"STREET","ST2QUAD":"SE","FULLSTREET2DISPLAY":"14TH STREET SE","FULLINTERSECTION":"U STREET SE AND 14TH STREET SE","REFX":401268.25001513,"REFY":133120.61000897,"NATIONALGRID":"18S UJ 27750 03769","LATITUDE":38.86590545932130,"LONGITUDE":-76.985386353798,"ConfidenceLevel":62.5},{"MARID":903573.0,"INTERSECTIONID":15843.0,"STREET1ID":100140.0,"STREET2ID":108723.0,"ST1NAME":"14TH","ST1TYPE":"STREET","ST1QUAD":"NW","FULLSTREET1DISPLAY":"14TH STREET NW","ST2NAME":"U","ST2TYPE":"STREET","ST2QUAD":"NW","FULLSTREET2DISPLAY":"U STREET NW","FULLINTERSECTION":"14TH STREET NW AND U STREET NW","REFX":397229.13001138,"REFY":138792.67999823,"NATIONALGRID":"18S UJ 23837 09529","LATITUDE":38.91699812128980,"LONGITUDE":-77.03195073766770,"ConfidenceLevel":62.5}]},"returnBlkAddrDataset":null,"returnCDDataSet":{"Address Return Codes":[{"Component":"Street Type 1","Parsed & Normalized":"","Assessment":"Missing"},{"Component":"Street Type 2","Parsed & Normalized":"STREET","Assessment":"Valid"},{"Component":"Quad","Parsed & Normalized":"","Assessment":"Missing"},{"Component":"Direction","Parsed & Normalized":"","Assessment":"Missing"},{"Component":"Street Name 1","Parsed & Normalized":"14TH","Assessment":"Valid"},{"Component":"Street Name 2","Parsed & Normalized":"U","Assessment":"Valid"}]},"UNIT":null,"UNITNUMBER":null,"sourceOperation":"DC Intersection","processTime":null}';
        newJsonstring = jsonstring.replace('"CLUSTER_":', '"CLUSTER":'); //0410
      }
      else {
        // address validation now available, restoring API call
        jsonstring = AddressValidation.verifyAddress(addressStreet);
        newJsonstring = jsonstring.replace('"CLUSTER_":', '"CLUSTER":'); //0410
      }
    }

    system.debug('----> jsonstring: ' + jsonstring);
    // holds parsed location data 
    AddressValidationResponseWrapper.AddressValidationWrapper addressValidWrap = retrieveParsedValidAddress(newJsonstring); // 0410
    System.debug('----> addressValidWrap: ' + addressValidWrap);
    // holds location data list as to displayed to end user
    List<AddressValidationResponseWrapper.TableWrapper> check_data_in_table = new List<AddressValidationResponseWrapper.TableWrapper> ();

    // mapping To location validation wrapper variable list to be displayed to end user ,
    //result got frm mar validation
    if (addressValidWrap != null) {
      if (addressValidWrap.returnDataset != null) {
        if (addressValidWrap.returnDataset.Table1 != null) {
          check_data_in_table = addressValidWrap.returnDataset.Table1;
          resultAddress = new list<locationWrapper> ();
          for (AddressValidationResponseWrapper.TableWrapper aVW : check_data_in_table) {
            locationWrapper lw = new locationWrapper();
            lw.street = aVW.FULLADDRESS;
            lw.placename = aVW.ALIASNAME;
            lw.city = aVW.CITY;
            lw.state = aVW.STATE;
            lw.longitude = aVW.LONGITUDE;
            lw.latitude = aVW.LATITUDE;
            lw.country = 'USA';
            lw.intersectionFullAddress = aVW.FULLINTERSECTION;
            // extra field included  //2809
            lw.quadrant = aVW.QUADRANT;
            if (aVW.FULLADDRESS != null) {
              lw.xCoord = aVW.XCOORD;
              lw.yCoord = aVW.YCOORD;
            }
            if (aVW.FULLINTERSECTION != null) {
              lw.xCoord = aVW.REFX;
              lw.yCoord = aVW.REFY;
            }
            if (aVW.FULLBLOCK != null) {
              lw.xCoord = aVW.CENTROIDX;
              lw.yCoord = aVW.CENTROIDY;
            }
            lw.aNC = aVW.ANC;
            lw.pSA = aVW.PSA;
            lw.ward = aVW.WARD;
            lw.sMD = aVW.SMD;

            lw.podList = aVW.POLDIST;
            lw.cluster = aVW.CLUSTER;

            lw.fullBlock = aVW.FULLBLOCK;
            lw.blockName = aVW.BLOCKNAME;

            // removing dot if any contains
            // will hve to change this logic later
            // intersection data
            if (aVW.INTERSECTIONID != null) {
              integer dotPosition = aVW.INTERSECTIONID.indexof('.');
              lw.intersectionId = aVW.INTERSECTIONID.substring(0, dotPosition);
            }
            if (aVW.ZIPCODE != null) {
              integer dotPosition = aVW.ZIPCODE.indexof('.');
              lw.zipCode = aVW.ZIPCODE.substring(0, dotPosition);
            }
            if (aVW.ADDRESS_ID != null) {
              integer dotPosition = aVW.ADDRESS_ID.indexof('.');
              lw.addressId = aVW.ADDRESS_ID.substring(0, dotPosition);
            }
            if (aVW.ROADWAYSEGID != null) {
              Integer dotPosition = aVW.ROADWAYSEGID.indexof('.');
              lw.roadwaySegId = aVW.ROADWAYSEGID.substring(0, dotPosition);
            }

            resultAddress.add(lw);
            system.debug('address --->' + resultAddress);
          }
        }
      }
      // nothing return from mar validation as result displaying this message to end user 
      if (check_data_in_table == null || check_data_in_table.isEmpty()) {
        isErrorMsg = true;
        isErrorMsgSr = false;
        ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Provide Valid Address');
        ApexPages.addMessage(error_msg);
      }

    }
  }

  // deserialing json got from mars address validation
  private AddressValidationResponseWrapper.AddressValidationWrapper retrieveParsedValidAddress(string tempJsonString) {
    AddressValidationResponseWrapper.AddressValidationWrapper m;
    if (tempJsonString != null) {
      try {
        JSONParser parser = JSON.createParser(tempJsonString);
        m = (AddressValidationResponseWrapper.AddressValidationWrapper) parser.readValueAs(AddressValidationResponseWrapper.AddressValidationWrapper.class);
        System.debug('returned result from mar validation in returndataset wrapper---' + m);
      }
      catch(exception e) {
        system.debug('unable to complete parsing --' + e);
      }
    }
    return m;
  }


  private map<string, string> retrieveQuestionAnswerMap(list<FlexNote__c> tempFlexNoteList) {
    map<string, string> flexNoteQuestionMap = new map<string, string> ();
    if (tempFlexNoteList.isEmpty()) return null;
    for (integer j = 0; j < (tempFlexNoteList).size(); j++) {
      //flexNoteQuestionMap.put(tempFlexNoteList[j].Question__c,tempFlexNoteList[j].Is_Answer__c);
      flexNoteQuestionMap.put(tempFlexNoteList[j].Questions__c, tempFlexNoteList[j].Answer__c);
    }
    return flexNoteQuestionMap;
  }

  private contact retrieveContactDetails(string contId) {
    contact cont = new contact();
    for (contact con :[Select c.Phone, c.MailingStreet, c.MailingStateCode, c.MailingPostalCode, c.MailingCountryCode, c.MailingCity, c.LastName, c.Id, c.FirstName, c.Email From Contact c where Id = :contId limit 1]) {
      cont = con;
    }
    return cont;
  }


  // invoked from radio button of validate address list 
  public pageReference doAddressSelection() {
    string selStreet = ApexPages.currentPage().getParameters().get('selStreetParm');
    string selCity = ApexPages.currentPage().getParameters().get('selCityParm');
    string selState = ApexPages.currentPage().getParameters().get('selStateParm');
    string selCounty = ApexPages.currentPage().getParameters().get('selCountryParm');
    string selZipCode = ApexPages.currentPage().getParameters().get('selZipCodeParm');
    string selLongitute = ApexPages.currentPage().getParameters().get('selLongituteParm');
    string selLatitude = ApexPages.currentPage().getParameters().get('selLatitudeParm');
    string selAddressId = ApexPages.currentPage().getParameters().get('selAddressIdParm');

    string selInterIdParam = ApexPages.currentPage().getParameters().get('selInterIdParam');
    string selInterFullAdrsParam = ApexPages.currentPage().getParameters().get('selInterFullAdrsParam');
    string selAlias = ApexPages.currentPage().getParameters().get('selAliasParam');
    string selQuadrant = ApexPages.currentPage().getParameters().get('selQuadrantParam');
    string selXCoord = ApexPages.currentPage().getParameters().get('selXCoordParam');
    string selYCoord = ApexPages.currentPage().getParameters().get('selYCoordParam');
    string selANC = ApexPages.currentPage().getParameters().get('selANCParam');
    string selPSA = ApexPages.currentPage().getParameters().get('selPSAParam');
    string selWard = ApexPages.currentPage().getParameters().get('selWardParam');
    string selSMD = ApexPages.currentPage().getParameters().get('selSMDParam');
    string selPodlist = ApexPages.currentPage().getParameters().get('selPodlistParam');
    string selCluster = ApexPages.currentPage().getParameters().get('selClusterParam');

    string selFullBlock = ApexPages.currentPage().getParameters().get('selfullBlockParam');
    string selBlockName = ApexPages.currentPage().getParameters().get('selblockNameParam');

    String selSnowArea = ApexPages.currentPage().getParameters().get('selSnowAreaParam');
    String selSnowZone = ApexPages.currentPage().getParameters().get('selSnowZoneParam');

    LocationWrapper w = new LocationWrapper();
    w.street = selStreet;
    w.city = selCity;
    w.country = selCounty;
    w.state = selState;
    w.zipCode = selZipCode;
    w.longitude = selLongitute;
    w.latitude = selLatitude;
    w.addressId = selAddressId;

    // intersection 
    w.intersectionId = selInterIdParam;
    w.intersectionFullAddress = selInterFullAdrsParam;
    w.placename = selAlias;
    w.quadrant = selQuadrant;
    w.xCoord = selXCoord;
    w.yCoord = selYCoord;
    w.aNC = selANC;
    w.pSA = selPSA;
    w.ward = selWard;
    w.sMD = selSMD;

    w.podList = selPodlist;
    w.cluster = selCluster;

    w.fullBlock = selFullBlock;
    w.blockName = selBlockName;

    w.snowzone = selSnowZone;
    w.snowarea = selSnowArea;

    locationData = w;
    system.debug('w----' + w);
    system.debug('locationData----' + locationData);

    // added on 2608
    if (!locationData.street.equals('') && !locationData.zipCode.equals('')) {
      contactCaseFlexNote.selCase.Address__c = locationData.street + ',' + locationData.city + ',' + locationData.state + ',' + locationData.country + ',' + locationData.zipCode;
    }
    // checking if intersection id
    if (!locationData.intersectionId.equals('') && !locationData.intersectionFullAddress.equals('')) {
      contactCaseFlexNote.selCase.Address__c = locationData.intersectionFullAddress + ',' + locationData.city + ',' + locationData.state + ',' + locationData.country;
    }

    if (!locationData.ward.equals('')) {
      contactCaseFlexNote.selCase.Ward__c = locationData.ward;
      system.debug('ward--' + contactCaseFlexNote.selCase.Ward__c);
    }
    system.debug('address-->' + contactCaseFlexNote.selCase.Address__c);

    if (!locationData.fullBlock.equals('') && !locationData.blockName.equals('')) {
      // contactCaseFlexNote.selCase.Address__c=locationData.blockName+' '+locationData.fullBlock+','+locationData.city+','+locationData.state+','+locationData.country;
      contactCaseFlexNote.selCase.Address__c = locationData.blockName + ',' + locationData.city + ',' + locationData.state + ',' + locationData.country;
      system.debug('address--' + contactCaseFlexNote.selCase.Address__c);
    }

    if (!locationData.longitude.equals('')) {
      contactCaseFlexNote.selCase.GeoLocation__Longitude__s = decimal.valueOf(locationData.longitude);
    }

    if (!locationData.latitude.equals('')) {
      contactCaseFlexNote.selCase.GeoLocation__Latitude__s = decimal.valueOf(locationData.latitude);
    }

    // clearing service type
    if (contactCaseFlexNote.sRType != null) {
      /*if(contactCaseFlexNote.sRType.Service_Name__c!=null && contactCaseFlexNote.sRType.Service_Name__c=='Bulk Collection'){
        contactCaseFlexNote.sRType.Service_Name__c='';
        contactCaseFlexNote.selCase.Priority='';
        contactCaseFlexNote.selCase.Origin='';
        contactCaseFlexNote.selCase.Status='';
        if(!serviceRequestQuestionWrapList.isEmpty() && serviceRequestQuestionWrapList!=null){
        serviceRequestQuestionWrapList.clear();
       
        }
        }*/

      // fetching potential services request based on servicetype and addresss 
      if (contactCaseFlexNote.selCase.Address__c != null && contactCaseFlexNote.sRType.Service_Name__c != null) {
        list<case> tempDuplicateSRList = ServiceRequestsHelper.getDuplicateServiceRequests(contactCaseFlexNote.selCase.Address__c, contactCaseFlexNote.sRType.Service_Name__c, contactCaseFlexNote.selCase.GeoLocation__Longitude__s, contactCaseFlexNote.selCase.GeoLocation__Latitude__s);
        if (tempDuplicateSRList != null) {
          system.debug('temp case storing list--' + tempDuplicateSRList);
          duplicateSRList = tempDuplicateSRList;
        }
      }
    }

    if (duplicateSRList != null && duplicateSRList.size() > 0) {
      isDuplicatesAvailable = true;
    } else {
      isDuplicatesAvailable = false;
    }
    return null;
  }

  // invoked from cancel button ,redirecting home tab for now
  public pageReference doCancel() {
    pageReference p = new PageReference('/home/home.jsp');
    return p;
  }


  // invoked from new service request button, to start new form for service request creation
  public pageReference doClearOldDataCreateNewForm() {
    try {

      contact con = new contact();
      ServiceRequestType__c tempSerivceRequestType = new ServiceRequestType__c();
      //list<case>duplicateSRList = new list<case>();
      case tempCase = new Case(Status = 'Open', Origin = 'Phone', Priority = 'Standard');
      list<FlexNote__c> tempFlexNotesList = new list<FlexNote__c> ();

      contactCaseFlexNote = new ContactCaseFlexNoteWrapper(con, tempSerivceRequestType, tempCase, tempFlexNotesList);

      casesList = new list<case> ();

      // clearing all data
      selectedServiceRequestType = null;
      serviceType = null; //added 1808
      if (duplicateSRList != null && !duplicateSRList.isEmpty()) duplicateSRList.clear();
      if (serviceRequestQuestionWrapList != null && !serviceRequestQuestionWrapList.isEmpty()) serviceRequestQuestionWrapList.clear();
      locationData = new LocationWrapper();
      locationData.city = 'WASHINGTON';
      locationData.state = 'DC';
      locationData.country = 'USA';

      resultAddress = new list<LocationWrapper> ();
      // clear previous service type name
      priorServiceTypeName = null;
      // enable new mode
      isNewMode = true;

      isCloneBtn = false; // hide clone button
      isCloneBtn1 = false;

      isCloned = false;

      isErrorMsgSr = false;
      isErrorMsg = true;
      flexnotelabel = false;

    }
    catch(exception e) {
      system.debug('unable complete clear due=' + e);
      //ApexPages.addMessages(e);
    }
    return null;
  }


  // delete flexnotes if service type changed in edit mode
  public void doDeleteFlexNotes(list<FlexNote__c> flexNotesListToDelete) {
    savePoint deleteSPoint = database.setSavepoint();
    try {
      if (flexNotesListToDelete.isEmpty()) return;
      delete(flexNotesListToDelete);
    }
    catch(exception e) {
      system.debug('unable to complete Delete Process due--' + e);
      database.rollback(deleteSPoint);
    }
  }

  /*component service request type selection methods*/
  public string serviceType;

  // getting all service types 
  public List<SelectOption> getServiceRequestItems() {
    List<SelectOption> tempOptions = new List<SelectOption> ();
    List<SelectOption> options = new List<SelectOption> ();

    list<ServiceRequestType__c> srList = new list<ServiceRequestType__c> ();

    string tempQueryStr = 'Select i.Object__c, i.Name, Service_Name__c,i.Id,i.Start_Date__c,i.Stop_Date__c,i.Description__c From ServiceRequestType__c i  where ';

    datetime deadline = datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));

    tempQueryStr += ' (Start_Date__c  <=' + deadline.format('yyyy-MM-dd');
    tempQueryStr += ' Or Start_Date__c  = null)';
    tempQueryStr += ' AND (Stop_Date__c  >=' + deadline.format('yyyy-MM-dd');
    tempQueryStr += ' Or Stop_Date__c  = null)';

    tempQueryStr += ' ORDER BY i.Service_Name__c ASC';
    srList = database.query(tempQueryStr);

    tempOptions.clear();

    for (ServiceRequestType__c temp : srList) {
      //Avoid Salesforce limit of collection suze 1000  - MNB
      tempOptions.add(new SelectOption(temp.Id, temp.Service_Name__c));

    }

    // we only concentrating on case object template
    /* for(ServiceRequestType__c temp:[Select i.Object__c, i.Name, Service_Name__c,i.Id From ServiceRequestType__c i where Object__c='Case' Order By Name ]){
      if (temp.Service_Name__c != null)
      tempOptions .add(new SelectOption(temp.Id,temp.Service_Name__c));
      }*/

    // tempOptions.sort(); 
    //default option
    options.add(new SelectOption('', 'Please Select'));
    options.addAll(tempOptions);
    //  SelectOptionSorter.doSort(options, SelectOptionSorter.FieldToSort.Label);
    system.debug('Sorted ServiceTypes:' + options);
    return options;
  }

  public String getServiceType() {
    return serviceType;
  }

  public void setServiceType(String serviceType) {
    this.serviceType = serviceType;
  }


  public void doRetrieveFlexNotesAnswer() {
    flexnotelabel = true;

    /* if(isCloned == true){
      ServiceRequestType__c srtype=[ Select Id,Name, Service_Name__c From ServiceRequestType__c i  where Service_Name__c =:selServiceRequestType];
      //contactCaseFlexNote.sRType.Service_Name__c=selServiceRequestType;
      selectedServiceRequestType = srtype.Id;
      retrieveFlexNoteQuestions();
      }*/

    if (contactCaseFlexNote.sRType.Service_Name__c == selServiceRequestType) {
      contactCaseFlexNote.SelectedFlexNoteList = clonedFlexNote;
    }

    //system.debug('serviceCodeSRTypeId--->'+serviceCodeSRTypeId);
    if (contactCaseFlexNote.sRType.Service_Name__c != '' || contactCaseFlexNote.sRType.Service_Name__c != NULL) {
      //if(serviceCodeSRTypeId.get(contactCaseFlexNote.sRType.Service_Name__c)!=null){
      ServiceRequestType__c sRType = getSelServiceRequestType(contactCaseFlexNote.sRType.Service_Name__c);

      if (sRType != null) {
        serviceType = sRType.Id;
        if (serviceType != null) {
          selectedServiceRequestType = serviceType;

          //if(sRTypeIdMap.get(serviceType)!=null){
          if (sRType.Name != null) contactCaseFlexNote.sRType.Name = sRType.Name;
          if (sRType.Default_Status__c != null) contactCaseFlexNote.selCase.Status = sRType.Default_Status__c;
          if (sRType.Default_Priority__c != null) contactCaseFlexNote.selCase.Priority = sRType.Default_Priority__c;
          if (sRType.Default_Method__c != null) contactCaseFlexNote.selCase.Origin = sRType.Default_Method__c;

          if (sRType.ContactStatus__c != null) contactCaseFlexNote.sRType.ContactStatus__c = sRType.ContactStatus__c;
          // contact required
          if (sRType.ContactRequired__c != null) contactCaseFlexNote.sRType.ContactRequired__c = sRType.ContactRequired__c;
          // service location required
          if (sRType.ServiceLocationRequired__c != null) contactCaseFlexNote.sRType.ServiceLocationRequired__c = sRType.ServiceLocationRequired__c;

          if (sRType.SLA__c != null) contactCaseFlexNote.selCase.SLA__c = sRType.SLA__c;
          if (sRType.Agency__c != null) contactCaseFlexNote.selCase.AgencyCode__c = sRType.Agency__c;

          system.debug('service type map--' + sRType);
          doDisplayAlertMsg(sRType);
          //}

          retrieveFlexNoteQuestions();
          system.debug('location data--->' + locationData);
          if (contactCaseFlexNote.sRType.Service_Name__c == 'Bulk Collection' && !locationData.intersectionFullAddress.equals('')) {
            isErrorMsg = true;
            ApexPages.addMessage(new Apexpages.Message(apexpages.severity.Info, 'Please Provide Non Intersection Addresses for this service type ' + contactCaseFlexNote.sRType.Service_Name__c));
          }

        }
      }

      System.debug('----> Attempting to get duplicates');
      System.debug('----> contactCaseFlexNote.selCase.Address__c: ' + contactCaseFlexNote.selCase.Address__c);
      System.debug('----> contactCaseFlexNote.sRType.Service_Name__c: ' + contactCaseFlexNote.sRType.Service_Name__c);
      // fetching potential service request based on service type and address
      if (contactCaseFlexNote.selCase.Address__c != null && contactCaseFlexNote.sRType.Service_Name__c != null) {
        list<case> tempDuplicateSRList = ServiceRequestsHelper.getDuplicateServiceRequests(contactCaseFlexNote.selCase.Address__c, contactCaseFlexNote.sRType.Service_Name__c, contactCaseFlexNote.selCase.GeoLocation__Longitude__s, contactCaseFlexNote.selCase.GeoLocation__Latitude__s);
        System.debug('----> tempDuplicateSRList: ' + tempDuplicateSRList);
        if (tempDuplicateSRList != null) {
          system.debug('temp case storing list--' + tempDuplicateSRList);
          duplicateSRList = tempDuplicateSRList;
        }
        System.debug('----> isDuplicateAvailable: ' + isDuplicatesAvailable);
      }

    }

    if (duplicateSRList != null && duplicateSRList.size() > 0) {
      isDuplicatesAvailable = true;
    } else {
      isDuplicatesAvailable = false;
    }
  }


  /* modified in component method*/
  private list<QuestionAnswerWrapper> validateInsertingData() {
    // holds list question and answer wrapper       
    list<QuestionAnswerWrapper> tempQuestionAnswerWrapList = new list<QuestionAnswerWrapper> ();
    for (ServiceRequestQuestionWrapper sRQW : serviceRequestQuestionWrapList) {

      for (QuestionAnswerWrapper qAW : sRQW.questionAnswerList) {

        //retrieving multipicklist values selected
        if (qAW.flexNoteQuestion.Answer_Type__c == 'MultiPicklist') {
          string tempMultiPickListValue = '';
          system.debug('qAW.questionMultiPicklistValueList---' + qAW.questionMultiPicklistValueList);
          for (QuestionMultiPickListWrapper qMPW : qAW.questionMultiPicklistValueList) {
            system.debug('qAW.questionMultiPicklistValueList---' + qMPW.isSelectedQuestion);
            // selected options for a multipicklist from page shuld include in string
            if (qMPW.isSelectedQuestion) {
              tempMultiPickListValue += qMPW.questionMultiPicklistItem + ',';
            }
            if (qMPW.selectedMultipicklist != null && !qMPW.selectedMultipicklist.isEmpty()) {
              string mPicklistValue = '';
              for (string strItem : qMPW.selectedMultipicklist) {
                mPicklistValue += strItem;
              }
              system.debug('mPicklistValue---' + mPicklistValue);
              tempMultiPickListValue += mPicklistValue + ',';
              system.debug('tempMultiPickListValue--' + tempMultiPickListValue);
            }

          }

          Boolean isEndComma = tempMultiPickListValue.endsWith(',');
          system.debug('isEndComma ---' + isEndComma);
          // removing ending comma symbol
          if (isEndComma) {
            integer le = tempMultiPickListValue.length() - 1;
            string tempAnsStr = tempMultiPickListValue.substring(0, le);
            system.debug('tempAnsStr---' + tempAnsStr);
            //qAW.answer.Is_Answer__c=tempAnsStr; // 2209
            qAW.answer.Answer__c = tempAnsStr;
          }
          else {
            // qAW.answer.Is_Answer__c=tempMultiPickListValue; //2209
            qAW.answer.Answer__c = tempMultiPickListValue;
          }
          system.debug('end--');
        }

        // validation if question is required ..this questions as to be answered otherwise it not saved
        if (qAW.relationQuestion.IsRequiredQuestion__c == true) {
          if (qAW.answer.Answer__c == null || qAW.answer.Answer__c == '') {
            //  we need to modify this
            isErrorMsg = false;
            isErrorMsgSr = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Please Provide Answer For All Required Questions.'));
            // isValid=false;
            return null;
          }
        }

        // VALIDATING DATE TIME
        // Comment 02914
        if (qAW.flexNoteQuestion.Answer_Type__c == 'Date/Time') {
          if (qAW.answer.Answer__c != '') { //|| qAW.answer.Answer__c!=null ){    
            // valid format 
            system.debug('Test--DateTime' + qAW.flexNoteQuestion.Answer_Type__c);
            Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d) ([0-1]?[0-9]|[2][0-3]):([0-5][0-9]) (AM|PM)');

            Matcher MyMatcher = MyPattern.matcher(qAW.answer.Answer__c);
            system.debug('matches--' + MyMatcher.matches());

            if (!MyMatcher.matches()) {
              isErrorMsg = false;
              isErrorMsgSr = true;
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Info: Valid Date Time Format is mm/dd/yyyy hh:mm AM/PM.');
              ApexPages.addMessage(myMsg);
              system.debug('entry--');
              return null;
            }
          }
        }

        if (qAW.flexNoteQuestion.Answer_Type__c == 'Date') {
          system.debug('answer value--' + qAW.answer.Answer__c);
          if (!qAW.answer.Answer__c.equals('')) { //|| qAW.answer.Answer__c!=null ){    
            // valid format 
            Pattern datePattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)');

            Matcher dateMatcher = datePattern.matcher(qAW.answer.Answer__c);
            system.debug('matches--' + dateMatcher.matches());

            if (!dateMatcher.matches()) {
              isErrorMsg = false;
              isErrorMsgSr = true;
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Error: Valid Date Format is mm/dd/yyyy.');
              ApexPages.addMessage(myMsg);
              system.debug('entry--');
              return null;
            }
          }
        }

        try {
          System.debug('----> Type: ' + getServiceType());
          // TODO: Add check for service type with the code instead of the type name.
          if (contactCaseFlexNote.sRType.Service_Name__c == 'Bulk Collection' && qAW.flexNoteQuestion.Answer_Type__c == 'Text') {
            if (!String.isBlank(qAW.answer.Answer__c) && qAW.answer.Answer__c.equals('{!Value}')) {
              isErrorMsg = false;
              isErrorMsgSr = true;
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Error: Invalid bulk schedule collection date.');
              ApexPages.addMessage(myMsg);
              return null;
            }
          }
        } catch(Exception e) {
          System.debug('----> Error on bulk schedule date validation: ' + e.getMessage());
        }

        // Collectin all question and answer which will used for inserting flexnote
        tempQuestionAnswerWrapList.add(qAW);
      }
    }
    system.debug('tempQuestionAnswerWrapList-->' + tempQuestionAnswerWrapList);
    return tempQuestionAnswerWrapList;

  }


  // gettting flexnotes to be inserted 
  private list<FlexNote__c> retrieveFlexNotesToInsert(list<QuestionAnswerWrapper> retriveFlexNotesQuestionAnswers, case caseRrd, list<FlexNote__c> fNList, ServiceRequestType__c sRT) {
    list<FlexNote__c> flexNotesToBeInserted = new list<FlexNote__c> ();

    if (retriveFlexNotesQuestionAnswers.IsEmpty() && caseRrd == null) return null;
    savepoint fnSPoint = database.setSavePoint();
    try {
      boolean isUpdatePriorFNotes;
      // holds question and question alias 
      MAP<string, string> questionAliasMap = new Map<string, string> ();
      //System.debug('----> Processing: QuestionAnswerMap');
      for (QuestionAnswerWrapper a : retriveFlexNotesQuestionAnswers) {
        // new mode insert flexnotes
        //System.debug('----> Processing: isNewMode => ' + isNewMode);
        if (isNewMode) {
          // mapping for question answer fields in flexNotes
          FlexNote__c tempAnswer = new FlexNote__c();
          // tempAnswer.Question__c=a.flexNoteQuestion.Question__c; //220914
          // tempAnswer.Is_Answer__c=a.answer.Is_Answer__c;
          tempAnswer.Questions__c = a.flexNoteQuestion.Questions__c;
          if (a.relationQuestion.Order__c != null) {
            tempAnswer.Order__c = decimal.valueof(a.relationQuestion.Order__c); // 2010         
          }
          tempAnswer.Answer__c = a.answer.Answer__c;
          tempAnswer.Answer_Date_Time__c = a.answer.Answer_Date_Time__c;
          tempAnswer.FlexNote_Question__c = a.flexNoteQuestion.Id;
          tempAnswer.Case__c = caseRrd.Id;
          //System.debug('----> Processing: tempAnswer => ' + tempAnswer);
          // 2309  questionAliasMap.put(a.flexNoteQuestion.Questions__c,a.flexNoteQuestion.QuestionAlias__c);
          flexNotesToBeInserted.add(tempAnswer);
        } // in edit mode upsert flexnotes, if there is same service type update else insert flexnote and delete previous flexnotes
        else {
          if (sRT.Service_Name__c == priorServiceTypeName) {
            if (isCloned == false) {
              for (FlexNote__c fl : fNList) {
                if (fl.Questions__c == a.flexNoteQuestion.Questions__c) {
                  fl.Questions__c = a.flexNoteQuestion.Questions__c;
                  fl.Order__c = decimal.valueof(a.relationQuestion.Order__c); //201014
                  fl.Answer__c = a.answer.Answer__c;
                  fl.Answer_Date_Time__c = a.answer.Answer_Date_Time__c;
                  system.debug('flexnote to update --' + fl);
                  // determines whether to delete previous flexnotes 
                  isUpdatePriorFNotes = false;
                  flexNotesToBeInserted.add(fl);
                }
              }
            }
            if (isCloned == true) {
              for (FlexNote__c fl : fNList) {
                if (fl.Questions__c == a.flexNoteQuestion.Questions__c) {
                  fl.Questions__c = a.flexNoteQuestion.Questions__c;
                  fl.Order__c = decimal.valueof(a.relationQuestion.Order__c); //201014
                  fl.Answer__c = a.answer.Answer__c;
                  fl.Answer_Date_Time__c = a.answer.Answer_Date_Time__c;
                  fl.Case__c = caseRrd.Id;
                  system.debug('flexnote to update --' + fl);
                  // determines whether to delete previous flexnotes 
                  isUpdatePriorFNotes = false;
                  flexNotesToBeInserted.add(fl);
                }
              }
            }

          }
          else {
            // mapping for question answer fields in flexNotes
            FlexNote__c tAnswer = new FlexNote__c();
            tAnswer.Questions__c = a.flexNoteQuestion.Questions__c;
            tAnswer.Order__c = decimal.valueof(a.relationQuestion.Order__c); //201014
            tAnswer.Answer__c = a.answer.Answer__c;
            tAnswer.Questions__c = a.flexNoteQuestion.Questions__c; //220914
            tAnswer.Answer_Date_Time__c = a.answer.Answer_Date_Time__c;
            tAnswer.FlexNote_Question__c = a.flexNoteQuestion.Id;
            tAnswer.Case__c = caseRrd.Id;

            //questionAliasMap.put(a.flexNoteQuestion.Questions__c,a.flexNoteQuestion.QuestionAlias__c);
            system.debug('if service type not equal insert new --' + tAnswer);
            flexNotesToBeInserted.add(tAnswer);
            isUpdatePriorFNotes = true;
          }
        }

      }
      // delete if previous flexnotes if service type different while in edit mode
      if (isUpdatePriorFNotes != null && isUpdatePriorFNotes == true) {
        doDeleteFlexNotes(fNList);
      }

      // system.debug('total flexnotes list--'+flexNotesToBeInserted);
      if (flexNotesToBeInserted.isEmpty()) return null;

    }
    catch(exception e) {
      system.debug('unable to complete flexnote mapping process due--' + e);
      database.rollback(fnSPoint);
      return null;
    }
    return flexNotesToBeInserted;
  }





  // saving all the case , contact and flexnotes
  public PageReference doSave() {
    System.debug('----> doSave Enter');
    savePoint sD = database.setSavePoint();
    contact conToUpsert = new contact();
    case caseToUpsert = new case();
    // holds flexnotes to upserted 
    list<FlexNote__c> flexNoteListToUpsert = new list<FlexNote__c> ();

    try {
      // check whether case details are null if null return null 
      if (contactCaseFlexNote.selCase == null) return null;
      // determining whether contact required for creating case based on service type 
      boolean isContactRequired = isContactRequiredToCreateCase(contactCaseFlexNote.sRType, contactCaseFlexNote.selContact);
      if (isContactRequired == null) return null;

      if (contactCaseFlexNote.SelectedFlexNoteList == null) return null;
      if (validateInsertingData() == null) {
        return null;
      }

      // service request type's field contactRequired determines whether to contact required to create case
      map<string, string> contParmMap = new map<string, string> ();
      if (contactCaseFlexNote.selContact.lastName != null) contParmMap.put('lastname', contactCaseFlexNote.selContact.lastName);
      if (contactCaseFlexNote.selContact.firstName != null) contParmMap.put('firstname', contactCaseFlexNote.selContact.firstName);

      if (isContactRequired) {
        if (contactCaseFlexNote.selContact.FirstName.equals('')) {
          isErrorMsg = true;
          isErrorMsgSr = false;
          Apexpages.Message Msg = new Apexpages.Message(apexpages.severity.Info, 'Please Provide Contact First Name Its Required');
          ApexPages.addMessage(Msg);
          return null;
        }

        if (contactCaseFlexNote.selContact.LastName.equals('')) {
          isErrorMsg = true;
          isErrorMsgSr = false;
          Apexpages.Message Msg = new Apexpages.Message(apexpages.severity.Info, 'Please Provide Contact Last Name Its Required');
          ApexPages.addMessage(Msg);
          return null;
        }

        if (contactCaseFlexNote.selContact.Email.equals('')) {
          isErrorMsg = true;
          isErrorMsgSr = false;
          Apexpages.Message Msg = new Apexpages.Message(apexpages.severity.Info, 'Please Provide Contact Email Address Its Required');
          ApexPages.addMessage(Msg);
          return null;
        }
      }
      if (contactCaseFlexNote.selContact.LastName != '' && contactCaseFlexNote.selContact.Email != '')
      {
        // Verify that there isn't a contact with the given name and insert it. If one exists then simply use it.               
        // Verify that there isn't already a contact in the system under the given email.
        Integer duplicateContacts = [Select Count() From Contact Where Email = :contactCaseFlexNote.selContact.Email];
        // If there is no duplicate contact then add a new one. 
        if (duplicateContacts <= 0) {
          account acc = ServiceRequestsHelper.createPersonalAccount(contParmMap);
          conToUpsert = doContactUpsert(contactCaseFlexNote.selContact, acc);
        } else {
          if (contactCaseFlexNote.selContact.Id != null) {
            conToUpsert = doContactUpsert(contactCaseFlexNote.selContact, null);
          }
          else {
            Contact ctemp = [Select Id, FirstName, LastName, Email From Contact Where Email = :contactCaseFlexNote.selContact.Email ORDER BY CreatedDate DESC Limit 1];
            if (ctemp != null) {
              contactCaseFlexNote.selContact.Id = ctemp.Id;
              conToUpsert = doContactUpsert(contactCaseFlexNote.selContact, null);
            }
            else {
              conToUpsert = null;
            }

          }
        }
      }
      // If no contact is available to process then return back to the page.
      if (conToUpsert == null) {
        return null;
      }


      case caseRecord = doRetrieveCaseDetails(conToUpsert, locationData, contactCaseFlexNote.selCase, serviceType);

      if (caseRecord == null) return null;
      // Validate the location service.
      if (doLocationValidation(caseRecord, serviceType) || doLocationValidation(caseRecord, serviceType) == null) return null;
      system.debug('----> Validation Success');
      System.debug('----> caseRecord: ' + caseRecord);

      // Calling the Case upsert method and returning upserted case obj.
      // caseToUpsert=doCaseUpsert(doRetrieveCaseDetails(conToUpsert,locationData,contactCaseFlexNote.selCase,serviceType));
      caseToUpsert = doCaseUpsert(caseRecord);
      system.debug('----> caseToUpsert: ' + caseToUpsert);

      if (caseToUpsert == null) return null;
      // getting all question and answer wrapper list to be inserted or updated 
      list<QuestionAnswerWrapper> tempQuestionAnswerToInsert = validateInsertingData();
      system.debug('----> tempQuestionAnswerToInsert: ' + tempQuestionAnswerToInsert);

      if (tempQuestionAnswerToInsert == null) return null;
      list<QuestionAnswerWrapper> temp = doRetrieveQuestionAnswerWrapperList(tempQuestionAnswerToInsert, caseToUpsert);
      system.debug('----> Selected question anwser: ' + temp);
      if (temp == null) return null;

      system.debug('----> Flex notes: ' + contactCaseFlexNote.SelectedFlexNoteList);

      // gettting all flexnote to be upserted 
      flexNoteListToUpsert = retrieveFlexNotesToInsert(temp, caseToUpsert, contactCaseFlexNote.SelectedFlexNoteList, contactCaseFlexNote.sRType);
      system.debug('----> Total size of flexnotes');
      boolean isFlexNotesPriorPresent = false;
      //if(flexNoteListToUpsert!=null || !flexNoteListToUpsert.isEmpty()){
      if (flexNoteListToUpsert != null && !flexNoteListToUpsert.isEmpty()) {
        //return null;
        system.debug('----> Flex notes to upsert: ' + flexNoteListToUpsert);
        doFlexNoteListUpsert(flexNoteListToUpsert);
        isFlexNotesPriorPresent = true;


        if (contactCaseFlexNote.sRType != null && contactCaseFlexNote.sRType.Service_Name__c == 'Bulk Collection') {
          doCreateUpdateServiceRequestBulkSchedule(caseToUpsert);
        }
      }

      try {
        System.debug('----> [AgentConsoleCtrl] Attempting to send new email for Bulk Collections...');
        // Send creation email if Bulk Collection type.
        if (contactCaseFlexNote.sRType.Service_Name__c.equalsIgnoreCase('Bulk Collection')) {
          System.debug('----> [AgentConsoleCtrl] Sending email to Contact to inform of Bulk Case Creation...');
          WorkflowProcessUtility.sendTemplatedEmail(new List<String> (), new List<String> (), 'SR_HTML_Creation_Confirm_Bulk_Collection', caseToUpsert.ContactId, caseToUpsert.Id, null, false, null);
        }
      } catch(Exception e) {
        System.debug('----> [AgentConsoleCtrl] Attempt to send email failed. No creations email sent to User.');
      }

      // previous service type and present are different delete flex notes of pervious service type while edit
      if (isNewMode == false) {
        if (priorServiceTypeName != null) {
          if (isFlexNotesPriorPresent == false) {
            if (priorServiceTypeName != contactCaseFlexNote.sRType.Service_Name__c) {
              doDeleteFlexNotes(contactCaseFlexNote.SelectedFlexNoteList);
            }
          }
        }
      }
    }
    catch(exception e) {
      system.debug('unable to complete insert-->' + e);
      // we will inserting the error into error log object
      isErrorMsg = true;
      isErrorMsgSr = false;

      database.rollback(sD);
      return null;

    }
    string tabId = ApexPages.currentPage().getParameters().get('sfdc.tabName');
    pageReference p = Page.AgentConsolePge;
    if (!tabId.equals('')) p.getParameters().put('sfdc.tabName', tabId);

    //if(isNewMode){
    p.getParameters().put('Id', caseToUpsert.Id);
    //}

    p.setRedirect(true);
    return p;
  }

  private boolean doLocationValidation(case toCaseInsert, string sRTId) {
    if (toCaseInsert == null && sRTId == null) return null;

    ServiceRequestType__c sRT = getSelServiceRequestType(sRTId);
    if (sRT != null) {
      //ServiceRequestType__c sRT=sRTypeIdMap.get(sRTId)

      if (sRT.ServiceLocationRequired__c != null && sRT.ServiceLocationRequired__c == true) {
        if (toCaseInsert.Address__c == null) {
          isErrorMsg = true;
          isErrorMsgSr = false;
          //Apexpages.Message addressMsg=new Apexpages.Message(apexpages.severity.Info,'Please Provide Address, Its Required.');
          Apexpages.Message addressMsg = new Apexpages.Message(apexpages.severity.Info, 'Service Request Address Is Required for Selected Service Type.');
          ApexPages.addMessage(addressMsg);
          return True;
        }
        else {
          return false;
        }
      }
    }
    else {
      isErrorMsg = false;
      isErrorMsgSr = true;
      Apexpages.Message sRTMsg = new Apexpages.Message(apexpages.severity.Info, 'Please Provide ServiceType, Its Required.');
      ApexPages.addMessage(sRTMsg);
      return True;
    }
    return false;
  }


  // displaying alert message if any present
  private void doDisplayAlertMsg(ServiceRequestType__c sRT) {
    if (sRT.SR_Alert_Message__c != null) {
      isErrorMsg = false;
      isErrorMsgSr = true;
      ApexPages.addMessage(new Apexpages.Message(apexpages.severity.Info, sRT.SR_Alert_Message__c));
    }
  }


  // contact upserted based on passed contact
  private contact doContactUpsert(Contact contactToBeUpsert, account acc) {
    try {
      if (contactToBeUpsert == null) {
        return null;
      }
      if (acc != null) {
        contactToBeUpsert.AccountId = acc.Id;
      }

      upsert(contactToBeUpsert);
    }
    catch(exception e) {
      system.debug('unable to complete Contact upsert due--' + e);
      ApexPages.addMessages(e);
      throw new CustomException(e); // custom Exception message added
      //database.rollback(contactSavePoint);
      return null;
    }
    return contactToBeUpsert;
  }



  private boolean isContactRequiredToCreateCase(ServiceRequestType__c serviceRequestType, contact con) {
    boolean isContactReq;
    try {
      if (serviceRequestType == null) return null;
      system.debug('Contact Status--' + serviceRequestType.ContactStatus__c);
      //if(serviceRequestType.ContactRequired__c!=null && serviceRequestType.ContactRequired__c==true){
      if (serviceRequestType.ContactStatus__c == 'Required (LN, FN, EM)') {
        if (con == null) {
          system.debug('con--' + con);
          return null;
        }
        else {
          system.debug('else condition');
          isContactReq = true;
        }
      }
      // else if(serviceRequestType.ContactRequired__c!=null && serviceRequestType.ContactRequired__c==false){
      else if (serviceRequestType.ContactStatus__c != 'Required (LN, FN, EM)') {
        if (con == null) {
          isContactReq = false;
        }
        else {
          system.debug('else if elsecondition--');
          system.debug('contact details--' + con);
          system.debug('contact last name--' + con.LastName);
          if (!con.LastName.equals('') || !con.firstName.equals('') || !con.phone.equals('') || !con.email.equals('')) {
            system.debug('contact to insert');
            isContactReq = true;
          }
          else {
            isContactReq = false;
          }
        }
      }
      if (isContactReq == null) return null;
    }
    catch(exception e) {
      system.debug('unable to complete process contact validation due==' + e);
      throw new CustomException(e); // custom Exception message added
    }
    return isContactReq;
  }


  // case upserted based on passed case
  private case doCaseUpsert(case caseToBeUpsert) {
    try {
      if (caseToBeUpsert == null) return null;
      System.debug('----> Inserting Case into System');
      caseToBeUpsert.Case_Source__c = 'Agent';
      // assigning case to default active assignment rule
      Database.DMLOptions dmo = new Database.DMLOptions();
      dmo.assignmentRuleHeader.useDefaultRule = true;
      caseToBeUpsert.setOptions(dmo);
      upsert(caseToBeUpsert);
      System.debug('----> Inserted Case into System');
    }
    catch(exception e) {
      system.debug('unable to complete case upsert due--' + e);
      ApexPages.addMessages(e);
      throw new CustomException(e); // custom Exception message added
      return null;
    }
    return caseToBeUpsert;
  }


  // case upserted based on passed case
  private void doFlexNoteListUpsert(list<FlexNote__c> flexNoteToBeUpsert) {
    try {
      if (flexNoteToBeUpsert.isEmpty()) return;

      upsert(flexNoteToBeUpsert);
    }
    catch(exception e) {
      system.debug('unable to complete flexNoteToUpsert upsert due--' + e);
      ApexPages.addMessages(e);
      throw new CustomException(e); // custom Exception message added
      return;
    }
  }

  // fetching case details 
  private case doRetrieveCaseDetails(contact contRecord, LocationWrapper lWRecord, Case caseRecord, String sRTRecordId) {
    try {
      // case service type  and location are null then exist from this method
      if (sRTRecordId == null) return null;

      if (contRecord != null) {
        // contact id 
        if (contRecord.Id != null) caseRecord.contactId = contRecord.Id;
      }

      if (caseRecord != null) {
        caseRecord = caseRecord;
      }

      // Service Type Section
      if (sRTRecordId != null) caseRecord.SRType__c = sRTRecordId;

      ServiceRequestType__c service = getSelServiceRequestType(sRTRecordId);
      if (service.Service_Name__c != null) {
        caseRecord.Subject = service.Service_Name__c;
      }

      if (getSRJurisdication(sRTRecordId) != null) {
        caseRecord.SRType_Jurisdiction__c = getSRJurisdication(sRTRecordId).Id;
      }

      // Address Section
      if (lWRecord != null) {
        // address details
        if (!lWRecord.street.equals('') && !lWRecord.city.equals('') && !lWRecord.state.equals('') && !lWRecord.country.equals('') && !lWRecord.zipCode.equals('')) {
          caseRecord.Address__c = lWRecord.street + ',' + lWRecord.city + ',' + lWRecord.state + ',' + lWRecord.country + ',' + lWRecord.zipCode;
        }

        // longitude and latitude     
        if (!lWRecord.latitude.equals('')) caseRecord.GeoLocation__Latitude__s = decimal.valueOf(lWRecord.latitude);
        if (!lWRecord.longitude.equals('')) caseRecord.GeoLocation__Longitude__s = decimal.valueOf(lWRecord.longitude);

        // addressId
        if (!lWRecord.addressId.equals('')) caseRecord.AddressID__c = lWRecord.addressId;

        // RoadwaySegId
        if (!lWRecord.roadwaySegId.equals('')) caseRecord.RoadwaySegId__c = lWRecord.roadwaySegId;

        // intersection address
        if (!lWRecord.intersectionFullAddress.equals('')) caseRecord.Address__c = lWRecord.intersectionFullAddress;
        system.debug('place name or alias name');
        //  address alias
        if (!lWRecord.placename.equals('')) {
          if (lWRecord.placename.length() > 28)
          caseRecord.AliasName__c = lWRecord.placename.substring(0, 28); // added due to alias 30 length
          else
          caseRecord.AliasName__c = lWRecord.placename;
        }
        // intersection Id
        if (!lWRecord.intersectionId.equals('')) caseRecord.IntersectionId__c = String.valueOf(Integer.valueOf(lWRecord.intersectionId));

        if (!lWRecord.quadrant.equals('')) caseRecord.Quadrant__c = lWRecord.quadrant;
        if (!lWRecord.xCoord.equals('')) caseRecord.XCOORD__c = lWRecord.xCoord;
        if (!lWRecord.yCoord.equals('')) caseRecord.YCOORD__c = lWRecord.yCoord;
        if (!lWRecord.aNC.equals('')) caseRecord.ANC__c = lWRecord.aNC;
        if (!lWRecord.pSA.equals('')) caseRecord.PSA__c = lWRecord.pSA;
        if (!lWRecord.ward.equals('')) caseRecord.Ward__c = lWRecord.ward;
        if (!lWRecord.sMD.equals('')) caseRecord.SMD__c = lWRecord.sMD;
        if (!lWRecord.podList.equals('')) caseRecord.POlDistrict__c = lWRecord.podList;
        if (!lWRecord.cluster.equals('')) caseRecord.Cluster__c = lWRecord.cluster;

        if (!lWRecord.fullBlock.equals('') && !lWRecord.blockName.equals('')) {
          caseRecord.Address__c = lWRecord.blockName + ',' + lWRecord.city + ',' + lWRecord.state + ',' + lWRecord.country + ',' + lWRecord.zipCode;
        }

        if (!lWRecord.fullBlock.equals('')) caseRecord.FullBlock__c = lWRecord.fullBlock;
        if (!lWRecord.blockName.equals('')) caseRecord.BlockName__c = lWRecord.blockName;

        if (!lWRecord.snowArea.equals('')) caseRecord.SnowRoute__c = lWRecord.snowArea;
        if (!lwRecord.snowZone.equals('')) caseRecord.SnowZone__c = lWRecord.snowZone;
      }

      System.debug('----> [AgentConsoleCtrl:DoSave] isDuplicateAvailable: ' + isDuplicatesAvailable);
      if (isDuplicatesAvailable) {
        for (Case duplicateC : duplicateSRList) {
          System.debug('----> [AgentConsoleCtrl:DoSave] Checking for parent case of duplicate...');
          if (duplicateC.Status.equalsIgnoreCase('Open')) {
            System.debug('----> Found parent case of current duplicate. Setting parent id for duplicate...');
            caseRecord.ParentId = duplicateC.Id;
          }
        }
      }

      if (caseRecord == null) return null;

    } catch(exception e) {
      system.debug('unable to complete process due=' + e);
      ApexPages.addMessages(e);
      throw new CustomException(e); // custom Exception message added
      return null;
    }
    return caseRecord;
  }


  private list<QuestionAnswerWrapper> doRetrieveQuestionAnswerWrapperList(list<QuestionAnswerWrapper> qAWList, Case caseRecord) {
    if ((qAWList.isEmpty() || qAWList == null) && caseRecord == null) return null;
    try {
      return qAWList;
    } catch(exception e) {
      throw new CustomException(e); // custom Exception message added
      return null;
    }
    return qAWList;
  }


  // fetching case suggestion list based passed fieldname and search string    
  public static list<case> doRetrieveSuggestionCaseList(string fieldName, string selString) {

    if (fieldName == null || selString == null) return null;
    list<case> suggestedCaseList = new list<case> ();
    try {
      string tempQueryStr = 'Select c.Service_Request_Number__c,c.Expected_Resolution_Date__c,c.Address__c,c.AgencyCode__c,c.SLA__c, c.GeoLocation__Longitude__s, c.GeoLocation__Latitude__s, c.CaseNumber, c.Status, c.SRType__r.Service_Name__c, c.SRType__r.Name, c.SRType__r.Id, c.SRType__c, c.Reason, c.Priority, c.Origin, c.IsClosed, c.Id, c.Contact.Email, c.Contact.Phone, c.Contact.FirstName, c.Contact.LastName, c.Contact.Id, c.ContactId,c.SRType__r.ContactRequired__c,c.SRType__r.ServiceLocationRequired__c, (Select Id, FlexNote_Question__c, Answer_Date_Time__c,Answer__c From FlexNotes__r) From Case c where ';

      if (!selString.equals('')) {
        tempQueryStr += fieldName + ' Like \'' + string.escapesingleQuotes(selString) + '%\'';
        tempQueryStr += 'ORDER BY ' + fieldName + ' ASC';
        suggestedCaseList = database.query(tempQueryStr);
      }

    }
    catch(exception e) {
      system.debug('unable to complete query execution due--' + e);
    }
    if (suggestedCaseList.isEmpty()) return null;

    return suggestedCaseList;
  }

  // invoked from autocomplete javascript on field search input fields
  @RemoteAction
  public static list<case> getCaseList(string selSearchStr, string TypeStr) {

    if (selSearchStr == null && TypeStr == null) return null;
    list<case> retriveCaseList = new list<case> ();
    try {
      /*if(TypeStr=='1'){
        retriveCaseList=doRetrieveSuggestionCaseList('CaseNumber',selSearchStr);
        }*/

      if (TypeStr == '1') {
        retriveCaseList = doRetrieveSuggestionCaseList('Service_Request_Number__c', selSearchStr);
      }

      if (TypeStr == '2') {
        retriveCaseList = doRetrieveSuggestionCaseList('contact.email', selSearchStr);
      }

      if (TypeStr == '3') {
        retriveCaseList = doRetrieveSuggestionCaseList('contact.phone', selSearchStr);
      }
      if (TypeStr == '4') {
        retriveCaseList = doRetrieveSuggestionCaseList('SRType__r.Service_Name__c', selSearchStr);
      }

    }
    catch(exception e) {
      system.debug('unable to complete javascript remoting due--' + e); //add message needs here
    }

    if (retriveCaseList.isEmpty()) return null;

    return retriveCaseList;
  }

  // invoked from autocomplete javascript on field service request type inputfield 
  /* @RemoteAction
    public static list<ServiceRequestType__c>getServiceRequestList(string selServiceRequestStr){
    if(selServiceRequestStr==null)return null;
    list<ServiceRequestType__c>retrieveServiceRequestList=new list<ServiceRequestType__c>();
    try{
    retrieveServiceRequestList=doRetrieveSuggestionServiceRequestList(selServiceRequestStr);
    }
    catch(exception e){
    system.debug('unable to complete process of retrieve of suggestion service request list--'+e);
    }
    if(retrieveServiceRequestList.isEmpty())return null;
    return retrieveServiceRequestList;
    }
   
    // fetches servicerequest type based on search keywords passed 
    private static list<ServiceRequestType__c>doRetrieveSuggestionServiceRequestList(string selStr){
    if(selStr==null)return null;
    list<ServiceRequestType__c>suggestedServiceRequestList=new list<ServiceRequestType__c>();
    try{
    string tempQueryStr='Select i.Object__c, i.Name, Service_Name__c,i.Id,Start_Date__c,Stop_Date__c From ServiceRequestType__c i  where ';
    if(!selStr.equals('')){
    String dateframe = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
    tempQueryStr+='( Start_Date__c  < ='+dateframe + '  Or  Start_Date__c  = null ) ' ;
    tempQueryStr+='  and ( Stop_Date__c  >= '+dateframe + ' Or  Stop_Date__c  = null )';
    tempQueryStr+='  and Service_Name__c Like \''+string.escapesingleQuotes(selStr)+ '%\'';
    system.debug('tempQueryStr----'+tempQueryStr);
    suggestedServiceRequestList=database.query(tempQueryStr); 
    }
    }
    catch(exception e){
    system.debug('unable to complete query execution due--'+e);
    }
    if(suggestedServiceRequestList.isEmpty())return null;
    system.debug('suggestedServiceRequestList--'+suggestedServiceRequestList);
    return suggestedServiceRequestList;
    }*/

  // invoked from autocomplete javascript on field service request type inputfield 
  @RemoteAction
  public static list<ServiceRequestType__c> getServiceRequestList(string selServiceRequestStr) {
    if (selServiceRequestStr == null) return null;
    list<ServiceRequestType__c> retrieveServiceRequestList = new list<ServiceRequestType__c> ();
    try {
      retrieveServiceRequestList = doRetrieveSuggestionServiceRequestList(selServiceRequestStr);
      if (retrieveServiceRequestList.isEmpty()) return null;
    }
    catch(exception e) {
      system.debug('unable to complete process of retrieve of suggestion service request list--' + e);
    }

    return retrieveServiceRequestList;
  }

  // fetches servicerequest type based on search keywords passed 
  private static list<ServiceRequestType__c> doRetrieveSuggestionServiceRequestList(string selStr) {
    if (selStr == null) return null;
    list<ServiceRequestType__c> suggestedServiceRequestList = new list<ServiceRequestType__c> ();
    try {
      if (selStr.length() > 1) {
        String searchStr1 = '*' + selStr + '*';

        string tempQueryStr = 'FIND \'' + searchStr1 + '\' IN All Fields RETURNING ServiceRequestType__c (Service_Name__c Where  ';

        datetime deadline = datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));

        tempQueryStr += ' (Start_Date__c  <=' + deadline.format('yyyy-MM-dd');
        tempQueryStr += ' Or Start_Date__c  = null)';
        tempQueryStr += ' AND (Stop_Date__c  >=' + deadline.format('yyyy-MM-dd');
        tempQueryStr += ' Or Stop_Date__c  = null)';

        tempQueryStr += ' ORDER BY Service_Name__c ASC )';

        List<List<sObject>> searchList = search.query(tempQueryStr);
        list<ServiceRequestType__c> accList1 = new list<ServiceRequestType__c> ();
        accList1 = ((List<ServiceRequestType__c>) searchList[0]);

        for (ServiceRequestType__c temp : accList1) {
          String name = temp.Service_Name__c;
          if (name.contains(selStr.subString(0, 1).toUpperCase())) {
            suggestedServiceRequestList.add(temp);
          }
        }
      }
    }
    catch(exception e) {
      system.debug('unable to complete query execution due--' + e);
    }
    if (suggestedServiceRequestList.isEmpty()) return null;
    system.debug('suggestedServiceRequestList--' + suggestedServiceRequestList);
    return suggestedServiceRequestList;
  }


  // invoked from autocomplete javascript on field of address validation input fields
  @RemoteAction
  public static List<AddressValidationResponseWrapper.TableWrapper> getAddressSuggestion(string streetStr) {

    if (streetStr == null) return null;

    list<AddressValidationResponseWrapper.TableWrapper> addressTableWrapperlist = new list<AddressValidationResponseWrapper.TableWrapper> ();
    try {
      string jsonStr;
      string newJsonstring;
      if (Test.isRunningTest()) {
        jsonStr = '{"returnCodes":null,"details":"<STRONG>Normalized:</STRONG> 3100 NW STREET</br><STRONG>Parsed:</STRONG></br><EM>Address Number: </EM>3100</br><EM>Address Number Suffix: </EM></br><EM>Street Name: </EM>NW</br><EM>Street Type: </EM></br><EM>Quad: </EM></br><STRONG>Possible Standard Street Names: </STRONG></br>W,N</br>","returnDataset":{"Table1":[{"ADDRESS_ID":274821.0,"STATUS":"ACTIVE","FULLADDRESS":"3100 N STREET NW","ADDRNUM":3100.0,"ADDRNUMSUFFIX":null,"STNAME":"N","STREET_TYPE":"STREET","QUADRANT":"NW","CITY":"WASHINGTON","STATE":"DC","XCOORD":394674.32,"YCOORD":137648.32,"SSL":"1208    0060","ANC":"ANC 2E","PSA":"Police Service Area 206","WARD":"Ward 2","NBHD_ACTION":" ","CLUSTER_":"Cluster 4","POLDIST":"Police District - Second District","ROC":"NA","CENSUS_TRACT":"000100","VOTE_PRCNCT":"Precinct 5","SMD":"SMD 2E05","ZIPCODE":20007.0,"NATIONALGRID":"18S UJ 21257 08441","ROADWAYSEGID":4625.0,"FOCUS_IMPROVEMENT_AREA":"NA","HAS_ALIAS":"N","HAS_CONDO_UNIT":"Y","HAS_RES_UNIT":"Y","HAS_SSL":"Y","LATITUDE":38.90667757,"LONGITUDE":-77.06140122,"STREETVIEWURL":"http://maps.google.com/maps?z=16&layer=c&cbll=38.90667757,-77.06140122&cbp=11,161.229197394201,,0,2.09","RES_TYPE":"RESIDENTIAL","WARD_2002":"Ward 2","WARD_2012":"Ward 2","ANC_2002":"ANC 2E","ANC_2012":"ANC 2E","SMD_2002":"SMD 2E06","SMD_2012":"SMD 2E05","IMAGEURL":"http://citizenatlas.dc.gov/mobilevideo","IMAGEDIR":"20040803","IMAGENAME":"E3064022.jpg","ConfidenceLevel":70.0}]},"returnBlkAddrDataset":null,"returnCDDataSet":{"Address Return Codes":[{"Component":"Street Type","Parsed & Normalized":"","Assessment":"Missing"},{"Component":"Quad","Parsed & Normalized":"","Assessment":"Missing"},{"Component":"Street Name","Parsed & Normalized":"NW","Assessment":"Not Valid"}]},"UNIT":null,"UNITNUMBER":null,"sourceOperation":"DC Address","processTime":"0 seconds and 343 milliseconds"}';
        newJsonstring = jsonStr.replace('"CLUSTER_":', '"CLUSTER":'); //0410
      } else {
        jsonStr = AddressValidation.verifyAddress(streetStr);
        newJsonstring = jsonStr.replace('"CLUSTER_":', '"CLUSTER":'); //0410
      }
      addressTableWrapperlist = getAddressSuggestionFrmJson(newJsonstring); //0410 
      system.debug('----> addressTableWrapperlist: ' + addressTableWrapperlist);
    }
    catch(exception e) {
      system.debug('unable to complete parsing --' + e);
    }
    if (addressTableWrapperlist.size() < 0) return null;


    return addressTableWrapperlist;
  }

  // fetches address suggestion list 
  private static list<AddressValidationResponseWrapper.TableWrapper> getAddressSuggestionFrmJson(string tempJsonString) {
    List<AddressValidationResponseWrapper.TableWrapper> addressTable = new List<AddressValidationResponseWrapper.TableWrapper> ();
    if (tempJsonString != null) {
      try {
        JSONParser parser = JSON.createParser(tempJsonString);
        AddressValidationResponseWrapper.AddressValidationWrapper m = (AddressValidationResponseWrapper.AddressValidationWrapper) parser.readValueAs(AddressValidationResponseWrapper.AddressValidationWrapper.class);
        System.debug('----> returndataset: ' + m);
        if (m.returnDataset != null) {
          if (m.returnDataset.Table1 != null) {
            addressTable = m.returnDataset.Table1;

            // Collect the Snow Zone and Area for the address.
            addressTable = SnowController.retrieveSnowInformation(addressTable);
          }
        }
      }
      catch(exception e) {
        system.debug('unable to complete parsing --' + e);
      }
    }
    if (addressTable.isEmpty()) return null;

    return addressTable;
  }

  // invoked from contact lookup field on change 
  // populating contacts fields based on contactlookup value
  public void updateContactsDetails() {
    string contactParamId = ApexPages.CurrentPage().getParameters().get('conId');

    string contactLkUpParamId = ApexPages.CurrentPage().getParameters().get('conlkId');
    system.debug('contactParamId-->' + contactParamId);
    system.debug('contactLkUpParamId-->' + contactLkUpParamId);


    if (contactParamId.equals('') || contactLkUpParamId.equals('')) return;
    contact con;
    system.debug('contact entry--');

    if (contactParamId != null) {
      con = retrieveContactDetails(contactParamId);
      system.debug('if entry--');
    }

    if (con == null) return;
    contactCaseFlexNote.selContact.firstName = con.FirstName;
    contactCaseFlexNote.selContact.LastName = con.LastName;
    //contactCaseFlexNote.selContact.ContactId=con.Id;
    contactCaseFlexNote.selContact.Phone = con.Phone;
    contactCaseFlexNote.selContact.Email = con.Email;
    system.debug('contactCaseFlexNote.selContact---' + contactCaseFlexNote.selContact);

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


  @RemoteAction
  public static list<Contact> getContactList(string selSearchStr, string typeStr) {
    list<contact> retriveContactList = new list<contact> ();
    try {
      if (TypeStr == '1') {
        retriveContactList = doRetrieveSuggestionContactList('contact.email', selSearchStr);
      }
      if (TypeStr == '2') {
        retriveContactList = doRetrieveSuggestionContactList('contact.phone', selSearchStr);
      }
      if (retriveContactList.isEmpty()) return null;
    }
    catch(exception e) {
      system.debug('unable to complete process of contact=' + e);
    }
    return retriveContactList;
  }

  private static list<contact> doRetrieveSuggestionContactList(string fieldSelStr, string selStr) {
    if (fieldSelStr == null && selStr == null) return null;
    list<contact> suggestedContactList = new list<contact> ();
    try {
      string tempQueryStr = 'Select i.email, i.Name,i.lastName,i.firstName,i.phone,i.Id From contact i where ';
      if (!selStr.equals('')) {
        tempQueryStr += fieldSelStr + ' Like \'' + string.escapesingleQuotes(selStr) + '%\'';
        tempQueryStr += 'ORDER BY Name ASC';
        suggestedContactList = database.query(tempQueryStr);
      }
    }
    catch(exception e) {
      system.debug('unable to complete query execution due--' + e);
    }
    if (suggestedContactList.isEmpty()) return null;
    system.debug('suggestedServiceRequestList--' + suggestedContactList);
    return suggestedContactList;
  }


  /*component methods start*/


  //holds case Record Id
  public String selectedCaseId { get; set; }

  public integer selIndex { get; set; }
  public string selAnswerValue { get; set; }

  // holds flexnotesquestion for a given service request type 
  public list<ServiceRequestQuestionWrapper> serviceRequestQuestionWrapList { get; set; }

  // Determine which type of service Request Type
  public string selectedServiceRequestType {
    get;
    set {
      selectedServiceRequestType = value;
    }
  }


  // retrieving questions based on service request selected 
  public void retrieveFlexNoteQuestions() {

    serviceRequestQuestionWrapList = new list<ServiceRequestQuestionWrapper> ();
    try {
      // if selected service request null return nothing
      if (selectedServiceRequestType == null) {
        isErrorMsg = false;
        isErrorMsgSr = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'ServiceRequestType  not defined.'));
        return;
      }

      // collecting all flexnote question ids             
      list<Id> flexNotesQuestionIds = new list<Id> ();
      map<Id, ServiceRequestTypeFlexNote__c> qRelMap = new map<Id, ServiceRequestTypeFlexNote__c> ();

      for (ServiceRequestTypeFlexNote__c temp :[Select Service_Request_Type__c, Order__c, IsReadOnly__c, DisplaySortOrder__c, IsRequiredQuestion__c, FlexNote_Question__r.QuestionAlias__c, FlexNote_Question__c, isRequired__c
           From ServiceRequestTypeFlexNote__c Where Service_Request_Type__c = :selectedServiceRequestType order by DisplaySortOrder__c ASC]) {
        flexNotesQuestionIds.add(temp.FlexNote_Question__c);
        qRelMap.put(temp.FlexNote_Question__c, temp);
      }

      list<QuestionAnswerWrapper> tempFlexNotesList = new list<QuestionAnswerWrapper> ();
      for (Id tempflexNoteQuest : flexNotesQuestionIds) {
        System.debug('----> Question Map: ' + qRelMap.get(tempflexNoteQuest));
        QuestionAnswerWrapper qA = new QuestionAnswerWrapper(flexNoteIdMap.get(tempflexNoteQuest), qRelMap.get(tempflexNoteQuest));

        // if edit mode enabled append answers
        if (isNewMode == false) {
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
          if (flexNoteIdMap.size() > 0) {
            if (flexNoteIdMap.get(tempflexNoteQuest) != null) {
              if (flexNoteIdMap.get(tempflexNoteQuest).Answer_Type__c != null) {
                  
                System.debug('----> flexNoteIdMap.get(tempflexNoteQuest): ' + flexNoteIdMap.get(tempflexNoteQuest));
                System.debug('----> flexNoteIdMap.get(tempflexNoteQuest).Answer_Type__c: ' + flexNoteIdMap.get(tempflexNoteQuest).Answer_Type__c);
                  
                // fetching picklist values from decode obj or from flexnotequestion 
                if (flexNoteIdMap.get(tempflexNoteQuest).Answer_Type__c == 'Picklist') {
                  // Converting string to picklist and adding to questionAnswerwrapper list ,based on type
                  System.debug('----> flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c: ' + flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c);
                  if (flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c != null) {
                    string picklistOptions = nameDecodeValueMap.get(flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c);
                    System.debug('----> picklistOptions: ' + picklistOptions);
                    list<Decode_Object__c> decodeList = picklistNameDecodeMap.get(flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c);
                    System.debug('----> decodeList: ' + decodeList);  
                    if (decodeList == null || decodeList.isEmpty()) {
                      picklistOptions = flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c;
                      qA.questionPicklistValues = retrievePicklistValues(picklistOptions); //0409
                    }
                    else {
                      qA.questionPicklistValues = retrievePicklistValues(decodeList); //0409
                    }
                    // if(picklistOptions==null)picklistOptions=flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c;       
                  }
                }
                // fetching multipicklist values from decode or flexnotequestion 
                if (flexNoteIdMap.get(tempflexNoteQuest).Answer_Type__c == 'MultiPicklist') {
                  if (flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c != null) {
                    list<Decode_Object__c> decodeList = picklistNameDecodeMap.get(flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c);
                    if (decodeList == null || decodeList.isEmpty()) {
                      qA.questionMultiPicklistValueList = retriveMultiPickListSelectOption(flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c);
                    }
                    else {
                      //qA.questionMultiPicklistValueList=retriveMultiPickList(flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c);
                      qA.questionMultiPicklistValueList = retriveMultiPickListSelectOption(decodeList);
                    }
                  }
                  // added to selecct multipicklist in edit mode
                  if (qA.answer.Answer__c != null) {
                    list<string> answerList = convertStringToAnswerList(qA.answer.Answer__c);
                    if (answerList != null && !answerList.isEmpty()) {
                      //  system.debug('Answer list string--'+answerList);
                      list<string> ansList = new list<string> ();
                      for (string ansItem : answerList) {
                        for (QuestionMultiPickListWrapper qAnswers : qA.questionMultiPicklistValueList) {
                          if (ansItem == qAnswers.flexNoteSelectItem.getValue()) {
                            ansList.add(ansItem);
                            qAnswers.selectedMultipicklist = ansList;
                          }
                        }
                      }
                    }
                  }
                }

                // ADDING DEFAULT VALUES
                if (flexNoteIdMap.get(tempflexNoteQuest).Answer_Type__c == 'Text') {
                  if (flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c != null) {
                    if (qA.answer.Answer__c == null) {
                      qA.answer.Answer__c = flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c;
                      System.debug('----> Default values: ' + qA.answer.Answer__c);
                    }

                  }

                }

                if (flexNoteIdMap.get(tempflexNoteQuest).Answer_Type__c == 'Text') {
                  if (flexNoteIdMap.get(tempflexNoteQuest).AnswerValues__c != null) {
                    System.debug('----> qA.answer.Answer__c: ' + qA.answer.Answer__c);
                    if (qA.answer.Answer__c == '{!value}') {
                      // Check the case for an existing bulk schedule date. 
                      //FlexNote__c caseNote = [Select FlexNote_Question__c, Answer__c From FlexNote__c Where Case__c = :contactCaseFlexNote.selCase.Id];
                      //System.debug('----> Flex Notes: ' + caseNote);
                      BulkSchedule__c bS = fetchBulkScheduleDetails(contactCaseFlexNote.selCase, 'DailyLimit');
                      if (bS != null) {
                        qA.answer.Answer__c = string.valueOf(bS.ScheduleDate__c.format());
                        if (bS.ScheduleDate__c != null) {
                          if (!bulkScheduleMap.containsKey(bS.ScheduleDate__c)) {
                            bulkScheduleMap.put(bS.ScheduleDate__c, bS);
                            system.debug('----> BulkScheduleMap: ' + bulkScheduleMap);
                          }
                        }
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

      if (tempFlexNotesList.isEmpty() && (selectedServiceRequestType != '' || selectedServiceRequestType != null)) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'There Are No Flex Notes Defined For a given Service Request Type .'));
        return;
      }

      for (ServiceRequestType__c temp :[Select i.Object__c, i.Name, i.Id From ServiceRequestType__c i where Id = :selectedServiceRequestType]) {
        ServiceRequestQuestionWrapper sRQW = new ServiceRequestQuestionWrapper(temp, tempFlexNotesList);
        serviceRequestQuestionWrapList.add(sRQW);
      }

      if (serviceRequestQuestionWrapList.isEmpty() && (selectedServiceRequestType != '' || selectedServiceRequestType != null)) {
        isErrorMsg = false;
        isErrorMsgSr = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Please Select a Valid Service Request Type.'));
        return;
      }
    }
    catch(Exception e)
    {
      System.debug('Unable to retrieve flexnotes and answers Process due--' + e);
      //we hve to store this message in some errorlog object
    }

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
  private list<QuestionMultiPickListWrapper> retriveMultiPickList(string commaSeperatedString) {
    list<QuestionMultiPickListWrapper> Options = new list<QuestionMultiPickListWrapper> ();
    if (commaSeperatedString == null) return null;

    if (commaSeperatedString.contains(',')) {
      // spliting comma seperated string 
      list<string> picklistValues = commaSeperatedString.split(',');
      for (Integer k = 0; k < picklistValues.size(); k++) {
        Options.add(new QuestionMultiPickListWrapper(picklistValues[k]));
      }
    }
    else {
      Options.add(new QuestionMultiPickListWrapper(commaSeperatedString));
    }
    return Options;
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


  // Invoked from onchange event of picklist
  public void doRenderInputText() {
    try {
      if (selAnswerValue == 'Other') {
        // its index zero we hve hardcoded need to modify
        if (selIndex != null) {

          serviceRequestQuestionWrapList[0].questionAnswerList[selIndex].isRenderText = True;
          // clear the param index and answer value
          selIndex = null;
          selAnswerValue = null;
        }
      }
      // whether picklist option selected is not other option and isRenderText is true make it false
      else if (selAnswerValue != 'Other' && selIndex != null) {
        system.debug('selIndex' + selIndex);
        //need to change this HardCoded zero need to modfiy later

        if (serviceRequestQuestionWrapList[0].questionAnswerList[selIndex].isRenderText == true) {
          serviceRequestQuestionWrapList[0].questionAnswerList[selIndex].isRenderText = false;
        }
        // clearing param values
        selIndex = null;
        selAnswerValue = null;
      }
    }
    catch(Exception e) {
      system.debug('unable to Complete Process' + e);
    }

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

  // invoked from javascript autocomplete address 
  public PageReference doAssignSelAddress() {
    string selStreet = ApexPages.currentPage().getParameters().get('streetParm');
    string selZipCode = ApexPages.currentPage().getParameters().get('zipCodeParm');
    string selIntersectionFullAddress = ApexPages.currentPage().getParameters().get('intersectionFullAddressParm');
    string selIntersectionId = ApexPages.currentPage().getParameters().get('intersectionIdParam');
    string selAliasName = ApexPages.currentPage().getParameters().get('AliasIdParam');
    string selWardName = ApexPages.currentPage().getParameters().get('wardIdParam');

    string selFullBlock = ApexPages.currentPage().getParameters().get('fullBlockParam');
    string selBlockName = ApexPages.currentPage().getParameters().get('blockNameParam');

    string selLatitude = ApexPages.currentPage().getParameters().get('latitudeParam');
    string selLongitude = ApexPages.currentPage().getParameters().get('longitudeParam');

    if (selStreet != '' && selZipCode != '' && locationData.street != '' && locationData.state != '' && locationData.country != '') {

      if (selStreet != null && selZipCode != null && locationData.street != null && locationData.state != null && locationData.country != null) {
        contactCaseFlexNote.selCase.Address__c = locationData.street + ',' + locationData.city + ',' + locationData.state + ',' + locationData.country + ',' + locationData.zipCode;
      }
    }
    // checking if intersection id
    if (selIntersectionId != '' && selIntersectionFullAddress != '') {
      if (selIntersectionId != null && selIntersectionFullAddress != null) {
        contactCaseFlexNote.selCase.Address__c = locationData.intersectionFullAddress + ',' + locationData.city + ',' + locationData.state + ',' + locationData.country;
      }
    }
    if (selAliasName != '' && selZipCode != '') {
      if (selAliasName != null && selZipCode != null) {
        contactCaseFlexNote.selCase.Address__c = locationData.placename + ',' + locationData.city + ',' + locationData.state + ',' + locationData.country + ',' + locationData.zipCode;
      }
    }

    if (selWardName != '') {
      contactCaseFlexNote.selCase.Ward__c = selWardName;
    } else {
      contactCaseFlexNote.selCase.Ward__c = '';
    }

    if (selFullBlock != '' && selBlockName != '') {
      if (selFullBlock != null && selBlockName != null) {
        contactCaseFlexNote.selCase.FullBlock__c = selFullBlock;
        contactCaseFlexNote.selCase.BlockName__c = selBlockName;
        contactCaseFlexNote.selCase.Address__c = locationData.blockName + ',' + locationData.city + ',' + locationData.state + ',' + locationData.country;
      }
    }


    if (selLatitude != '') {
      contactCaseFlexNote.selCase.GeoLocation__Latitude__s = decimal.valueOf(selLatitude);
    }

    if (selLongitude != '') {
      contactCaseFlexNote.selCase.GeoLocation__Longitude__s = decimal.valueOf(selLongitude);
    }


    // clearing service type
    if (contactCaseFlexNote.sRType != null) {
      /*if(contactCaseFlexNote.sRType.Service_Name__c=='Bulk Collection'){
        contactCaseFlexNote.sRType.Service_Name__c='';
        contactCaseFlexNote.selCase.Priority='';
        contactCaseFlexNote.selCase.Origin='';
        contactCaseFlexNote.selCase.Status='';
        if(!serviceRequestQuestionWrapList.isEmpty() && serviceRequestQuestionWrapList!=null){
        serviceRequestQuestionWrapList.clear();
        }
        }*/


      if (contactCaseFlexNote.selCase.Address__c != null && contactCaseFlexNote.sRType.Service_Name__c != null) {
        list<case> tempDuplicateSRList = ServiceRequestsHelper.getDuplicateServiceRequests(contactCaseFlexNote.selCase.Address__c, contactCaseFlexNote.sRType.Service_Name__c, contactCaseFlexNote.selCase.GeoLocation__Longitude__s, contactCaseFlexNote.selCase.GeoLocation__Latitude__s);
        if (tempDuplicateSRList != null) {
          duplicateSRList = tempDuplicateSRList;
        }
        System.debug('----> isDuplicateAvailable: ' + isDuplicatesAvailable);
      }

    }

    if (duplicateSRList != null && duplicateSRList.size() > 0) {
      isDuplicatesAvailable = true;
    } else {
      isDuplicatesAvailable = false;
    }
    doRetrieveFlexNotesAnswer();
    return null;
  }

  private list<OUC_Activity_History__c> fetchOUCActivityHistoryList(string caseId) {
    if (caseId == null) return null;

    list<OUC_Activity_History__c> activityHistoryList = new list<OUC_Activity_History__c> ();
    for (OUC_Activity_History__c aH :[select name, Completion_Date__c, id, Due_Date__c, OutCome__c, Status__c, Task_Short_Name__c, Activity_Id__c, Case__c, Display_Sort_Order__c, External_Comments__c from OUC_Activity_History__c where Case__c = :caseId Order By Display_Sort_Order__c ASC]) {
      activityHistoryList.add(aH);
    }

    if (activityHistoryList.isEmpty()) return null;

    return activityHistoryList;
  }

  private BulkSchedule__c fetchBulkScheduleDetails(case tempCase, string DailyLimit) {
    string scheduleDate;
    system.debug('case detail--' + tempCase);
    if (tempCase.Ward__c == null) {
      isErrorMsg = true;
      isErrorMsgSr = false;
      ApexPages.addMessage(new Apexpages.Message(Apexpages.Severity.INFO, 'Please provide address for this service type, then reselect service type'));
      return null;
    }
    else {
      sObject sobj = ServiceRequestsHelper.getFlexNoteDefault(tempCase.Ward__c, DailyLimit);
      if (sobj != null) {
        BulkSchedule__c bS = (BulkSchedule__c) sobj;
        scheduleDate = string.valueOf(bS.ScheduleDate__c.format());
        system.debug('BULK SCHEDULE--' + bS);
        return bS;
      }
      else {
        isErrorMsg = true;
        isErrorMsgSr = false;
        ApexPages.addMessage(new Apexpages.Message(Apexpages.Severity.INFO, 'There are no records for provided address'));
        return null;
      }
    }

  }

  private void doCreateUpdateServiceRequestBulkSchedule(case caseRrd) {
    list<ServiceRequestBulkSchedule__c> serviceBulkScheduleToUpsert = new list<ServiceRequestBulkSchedule__c> ();
    for (Date bSItem : bulkScheduleMap.keySet()) {
      if (isValidBulkScheduleDate(bSItem, caseRrd.Ward__c)) return;

      ServiceRequestBulkSchedule__c sRBS = new ServiceRequestBulkSchedule__c();
      sRBS.BulkSchedule__c = bulkScheduleMap.get(bSItem).Id;
      sRBS.ServiceRequest__c = caseRrd.Id;
      sRBS.SRBulkScheduleExtId__c = sRBS.BulkSchedule__c + '-' + sRBS.ServiceRequest__c;
      sRBS.Status__c = 'Open';
      serviceBulkScheduleToUpsert.add(sRBS);

      system.debug('bulkScheduleMap--' + bulkScheduleMap.get(bSItem));
    }

    try {
      if (!serviceBulkScheduleToUpsert.isEmpty()) upsert serviceBulkScheduleToUpsert SRBulkScheduleExtId__c;
    } catch(exception e) {
      system.debug('unable to complete Process of Upsert of servicerequestbulkschedule due--' + e);
      throw new CustomException(e); // custom Exception message added
    }
  }

  private boolean isValidBulkScheduleDate(Date scheduleDate, string Ward) {
    boolean isValidDate;
    for (BulkSchedule__c bs :[select id, Name, ServiceRequestBulkScheduleCount__c, ScheduleDate__c, Ward__c from BulkSchedule__c where ScheduleDate__c = :scheduleDate Order By ScheduleDate__c ASC limit 1]) {
      if (bs.Ward__c.contains(Ward)) {
        if (bs.ServiceRequestBulkScheduleCount__c > = OUCServiceRequestConfig__c.getValues('DailyLimit').BulkScheduleDailyStopLimit__c) {
          system.debug('count---' + bs.ServiceRequestBulkScheduleCount__c);
          throw new CustomException('DailyStopLimit for bulk schedule has been crossed');
          return isValidDate = true;
        }
        else {
          return isValidDate = false;
        }
      }
    }

    return isValidDate = false;
  }

  // retriving ServiceRequestType__c name record based on selId passed 
  private ServiceRequestType__c getSelServiceRequestType(string selServiceIdName) {
    if (selServiceIdName == null) return new ServiceRequestType__c();
    list<ServiceRequestType__c> sRTList = [Select i.Object__c, i.Name, i.Id, i.Service_Name__c, Default_Method__c, Default_Priority__c, Default_Status__c, ContactStatus__c, ContactRequired__c, ServiceLocationRequired__c, SR_Alert_Message__c, SLA__c, Jurisdiction__c, Agency__c From ServiceRequestType__c i where Object__c = 'Case' And(Id = :selServiceIdName or Service_Name__c = :selServiceIdName)];
    if (sRTList.isEmpty()) return new ServiceRequestType__c();
    return sRTList[0];

  }


  public pagereference doCloneDuplicateSR() {
    isCloned = true;

    contact clonedCon = contactCaseFlexNote.selContact.clone(true);
    case clonedCase = contactCaseFlexNote.selCase.clone(false);
    system.debug('clonedCase-->' + clonedCase);
    ServiceRequestType__c clonedSRType = contactCaseFlexNote.sRType.clone(true);

    //Set default status for the cloned case
    //clonedCase.Status = clonedSRType.Default_Status__c;
    clonedCase.Status = 'Open';

    list<FlexNote__c> clonedFnList = contactCaseFlexNote.SelectedFlexNoteList.deepClone(false);

    // invoking display message
    if (clonedSRType != null) doDisplayAlertMsg(clonedSRType);

    if (clonedSRType.Service_Name__c != null && clonedSRType.Service_Name__c == 'Bulk Collection') {
      BulkSchedule__c bS = fetchBulkScheduleDetails(clonedCase, 'DailyLimit');
      String bulkQuestion = OUCServiceRequestConfig__c.getValues('DailyLimit').BulkCollectionScheduleQuestion__c;

      if (bS == null) {
        ApexPages.addMessage(new Apexpages.Message(apexpages.severity.Info, 'There are no records for provided address'));
      }

      if (bulkQuestion == null) {
        isErrorMsg = false;
        isErrorMsgSr = true;
        ApexPages.addMessage(new Apexpages.Message(apexpages.severity.Info, 'Bulk collection Question not defined in custom setting'));
      }

      if (bS != null && bulkQuestion != null) {
        for (ServiceRequestQuestionWrapper qA : serviceRequestQuestionWrapList) {
          for (QuestionAnswerWrapper qAW : qA.questionAnswerList) {
            if (qAW.flexNoteQuestion.Questions__c == bulkQuestion) {
              qAW.answer.Answer__c = string.valueOf(bS.ScheduleDate__c.format());
              system.debug('schedule question-->' + qAW.answer.Answer__c);
              break;
            }
          }
        }
      }


    }
    ContactCaseFlexNoteWrapper clonedContactCaseFlexNote = new ContactCaseFlexNoteWrapper(clonedCon, clonedSRType, clonedCase, clonedFnList);
    contactCaseFlexNote = clonedContactCaseFlexNote;

    if (casesList != null && !casesList.isEmpty()) casesList.clear();

    isCloneBtn = false; // hide clone button
    isCloneBtn1 = false;

    contactCaseFlexNote.selCase = SnowController.retrieveSnowInformation(contactCaseFlexNote.selCase);

    return null;
  }


  public pagereference doCloneCopySR() {
    isCloned = true;

    contact clonedCon = contactCaseFlexNote.selContact.clone(true);
    case clonedCase = contactCaseFlexNote.selCase.clone(false);
    system.debug('clonedCase-->' + clonedCase);
    //selServiceRequestType=null;  

    ServiceRequestType__c clonedSRType = contactCaseFlexNote.sRType.clone(true);

    //Set default status for the cloned case
    //clonedCase.Status = clonedSRType.Default_Status__c;
    clonedCase.Status = 'Open';

    //ServiceRequestType__c clonedSRType =null;    
    list<FlexNote__c> clonedFnList = new list<FlexNote__c> ();

    serviceRequestQuestionWrapList = new list<ServiceRequestQuestionWrapper> ();

    clonedFlexNote = contactCaseFlexNote.SelectedFlexNoteList.deepClone(false);

    // invoking display message
    if (clonedSRType != null) doDisplayAlertMsg(clonedSRType);

    if (clonedSRType.Service_Name__c != null && clonedSRType.Service_Name__c == 'Bulk Collection') {
      BulkSchedule__c bS = fetchBulkScheduleDetails(clonedCase, 'DailyLimit');
      String bulkQuestion = OUCServiceRequestConfig__c.getValues('DailyLimit').BulkCollectionScheduleQuestion__c;

      if (bS == null) {
        ApexPages.addMessage(new Apexpages.Message(apexpages.severity.Info, 'There are no records for provided address'));
      }

      if (bulkQuestion == null) {
        isErrorMsg = false;
        isErrorMsgSr = true;
        ApexPages.addMessage(new Apexpages.Message(apexpages.severity.Info, 'Bulk collection Question not defined in custom setting'));
      }

      if (bS != null && bulkQuestion != null) {
        for (ServiceRequestQuestionWrapper qA : serviceRequestQuestionWrapList) {
          for (QuestionAnswerWrapper qAW : qA.questionAnswerList) {
            if (qAW.flexNoteQuestion.Questions__c == bulkQuestion) {
              qAW.answer.Answer__c = string.valueOf(bS.ScheduleDate__c.format());
              system.debug('schedule question-->' + qAW.answer.Answer__c);
              break;
            }
          }
        }
      }


    }

    ContactCaseFlexNoteWrapper clonedContactCaseFlexNote = new ContactCaseFlexNoteWrapper(clonedCon, clonedSRType, clonedCase, clonedFnList);
    contactCaseFlexNote = clonedContactCaseFlexNote;

    if (casesList != null && !casesList.isEmpty()) casesList.clear();

    isCloneBtn = false; // hide clone button
    isCloneBtn1 = false;

    contactCaseFlexNote.selCase = SnowController.retrieveSnowInformation(contactCaseFlexNote.selCase);

    return null;
  }

  // invoked from clone button
  public pageReference doClone() {

    isCloned = true;

    contact clonedCon = contactCaseFlexNote.selContact.clone(true);
    case clonedCase = contactCaseFlexNote.selCase.clone(false);
    system.debug('clonedCase-->' + clonedCase);
    ServiceRequestType__c clonedSRType = contactCaseFlexNote.sRType.clone(true);
    list<FlexNote__c> clonedFnList = contactCaseFlexNote.SelectedFlexNoteList.deepClone(false);

    // invoking display message
    if (clonedSRType != null) doDisplayAlertMsg(clonedSRType);

    if (clonedSRType.Service_Name__c != null && clonedSRType.Service_Name__c == 'Bulk Collection') {
      BulkSchedule__c bS = fetchBulkScheduleDetails(clonedCase, 'DailyLimit');
      String bulkQuestion = OUCServiceRequestConfig__c.getValues('DailyLimit').BulkCollectionScheduleQuestion__c;

      if (bS == null) {
        ApexPages.addMessage(new Apexpages.Message(apexpages.severity.Info, 'There are no records for provided address'));
      }

      if (bulkQuestion == null) {
        isErrorMsg = false;
        isErrorMsgSr = true;
        ApexPages.addMessage(new Apexpages.Message(apexpages.severity.Info, 'Bulk collection Question not defined in custom setting'));
      }

      if (bS != null && bulkQuestion != null) {
        for (ServiceRequestQuestionWrapper qA : serviceRequestQuestionWrapList) {
          for (QuestionAnswerWrapper qAW : qA.questionAnswerList) {
            if (qAW.flexNoteQuestion.Questions__c == bulkQuestion) {
              qAW.answer.Answer__c = string.valueOf(bS.ScheduleDate__c.format());
              system.debug('schedule question-->' + qAW.answer.Answer__c);
              break;
            }
          }
        }
      }


    }
    ContactCaseFlexNoteWrapper clonedContactCaseFlexNote = new ContactCaseFlexNoteWrapper(clonedCon, clonedSRType, clonedCase, clonedFnList);
    contactCaseFlexNote = clonedContactCaseFlexNote;

    /*
      system.debug('selContact---'+contactCaseFlexNote.selContact);
      system.debug('selCase---'+contactCaseFlexNote.selCase);
      system.debug('sRType---'+contactCaseFlexNote.sRType);
      system.debug('SelectedFlexNoteList---'+contactCaseFlexNote.SelectedFlexNoteList);
      system.debug('selOUCActivity---'+contactCaseFlexNote.selOUCActivity);
     */
    if (casesList != null && !casesList.isEmpty()) casesList.clear();

    isCloneBtn = false; // hide clone button
    isCloneBtn1 = false;
    return null;
  }

  // used in displaying multipicklist and getting selected values also
  public Class QuestionMultiPickListWrapper {
    // based on this will include picklist value
    public boolean isSelectedQuestion { get; set; }
    public string questionMultiPicklistItem { get; set; }
    public SelectOption flexNoteSelectItem { get; set; } // 3009
    public list<string> selectedMultipicklist { get; set; }

    public QuestionMultiPickListWrapper(string questionMultiPicklistItem) {
      this.questionMultiPicklistItem = questionMultiPicklistItem;
      this.isSelectedQuestion = false;
    }
    public QuestionMultiPickListWrapper(SelectOption flexNoteSelectItem) {
      this.flexNoteSelectItem = flexNoteSelectItem;
      this.isSelectedQuestion = false;
      this.selectedMultipicklist = new list<string> ();
    }
  }


  // Question And Answer Container
  public class QuestionAnswerWrapper {
    // holds service request and question relation
    public ServiceRequestTypeFlexNote__c relationQuestion { get; set; }
    // Determines whether picklist selected other option
    public boolean isRenderText { get; set; }
    // holds Answer for a question
    public FlexNote__c answer { get; set; }
    // holds question picklist values
    public list<SelectOption> questionPicklistValues { get; set; }
    // holds questions 
    public FlexNoteQuestion__c flexNoteQuestion { get; set; }
    // holds multipicklist values 
    public list<QuestionMultiPickListWrapper> questionMultiPicklistValueList { get; set; }

    public QuestionAnswerWrapper(FlexNoteQuestion__c flexNoteQuestion, ServiceRequestTypeFlexNote__c relationQuestion) {
      this.flexNoteQuestion = flexNoteQuestion;
      this.relationQuestion = relationQuestion;
      this.answer = new FlexNote__c();
      this.questionPicklistValues = new list<SelectOption> ();
      this.isRenderText = false;
      // added
      this.questionMultiPicklistValueList = new list<QuestionMultiPickListWrapper> ();
    }
  }


  // Service Request and QuestionAnswerWrapper Container
  public class ServiceRequestQuestionWrapper {
    // holds service Request 
    public ServiceRequestType__c serviceRequest { get; set; }
    // holds question related to selected service request       
    public list<QuestionAnswerWrapper> questionAnswerList { get; set; }

    public ServiceRequestQuestionWrapper(ServiceRequestType__c serviceRequest, list<QuestionAnswerWrapper> questionAnswerList) {
      this.serviceRequest = serviceRequest;
      this.questionAnswerList = questionAnswerList;
    }

  }


  // container for storing all contact ,case ,service type flexnotes
  public class ContactCaseFlexNoteWrapper {
    public contact selContact { get; set; }
    public case selCase { get; set; }
    public ServiceRequestType__c sRType { get; set; }
    public list<FlexNote__c> SelectedFlexNoteList { get; set; }
    // public list<CaseHistory>selCaseHistory{get;set;}
    //public list<ActivityHistory>selActivityHistory{get;set;}
    public list<OUC_Activity_History__c> selOUCActivity { get; set; } //2809
    public ContactCaseFlexNoteWrapper(contact selContact, ServiceRequestType__c sRType, case selCase, list<FlexNote__c> SelectedFlexNoteList) {
      this.selContact = selContact;
      this.selCase = selCase;
      this.sRType = sRType;
      this.SelectedFlexNoteList = SelectedFlexNoteList;
      //this.selActivityHistory=new list<ActivityHistory>();
      this.selOUCActivity = new list<OUC_Activity_History__c> ();
    }
  }


  // container for storing location 
  public class LocationWrapper {
    public string street { get; set; }

    public string city { get; set; }
    public string state { get; set; }
    public string country { get; set; }
    public string zipCode { get; set; }
    public string longitude { get; set; }
    public string latitude { get; set; }
    public string addressId { get; set; }
    public string roadwaySegId { get; set; }
    // alias name
    public string placename { get; set; }
    // intersection 
    public string intersectionId { get; set; }
    public string intersectionFullAddress { get; set; }

    public string quadrant { get; set; }
    public string xCoord { get; set; }
    public string yCoord { get; set; }
    public string aNC { get; set; }
    public string pSA { get; set; }
    public string ward { get; set; }
    public string sMD { get; set; }
    public string podList { get; set; }
    public string cluster { get; set; }

    //holds blkaddress fields
    public String fullBlock { get; set; }
    public String blockName { get; set; }

    public String snowArea { get; set; }
    public String snowZone { get; set; }
    //public String lowerRange;
    //public String highRange;
    public LocationWrapper() {

    }
  }

  public void allPrivateMethods() {
    String tempString = ' And alley';
    string soqlStr = 'Select c.Service_Request_Number__c,c.Expected_Resolution_Date__c,c.Address__c, AgencyCode__c,c.SLA__c,c.GeoLocation__Longitude__s, c.GeoLocation__Latitude__s, c.CaseNumber, c.Status, c.SRType__r.Service_Name__c, c.SRType__r.Name,c.SRType__r.Agency__c,c.SRType__r.Id,c.SRType__r.Default_Status__c, c.SRType__r.Default_Priority__c, c.SRType__r.Default_Method__c, c.SRType__c, c.Reason, c.Priority, c.Origin, c.IsClosed, c.Id, c.Contact.Email, c.Contact.Phone, c.Contact.FirstName, c.Contact.LastName, c.Contact.Id,c.CreatedDate,c.SRType__r.ContactRequired__c,c.SRType__r.ServiceLocationRequired__c,(Select Id, FlexNote_Question__c,Case__c,Questions__c, Answer_Date_Time__c,Answer__c From FlexNotes__r) From Case c';

    Account acc = new Account(Name = 'accname');
    insert acc;

    Contact con = new Contact(Lastname = 'lastname', Firstname = 'firstname', email = 'test@test.com');
    insert con;
    String contId = con.Id;

    fetchFlexNoteQuestionMap();
    retrieveWhereClauseString(tempString);
    retriveSearchResult(soqlStr);
    retrieveContactDetails(contId);
    doContactUpsert(con, acc);

  }
}