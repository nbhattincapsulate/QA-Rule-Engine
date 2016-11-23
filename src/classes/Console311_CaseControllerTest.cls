@isTest
public class Console311_CaseControllerTest {
  private static Contact cont;
  private static ServiceRequestType__c serviceType;
  private static ServiceRequestType__c bulkServiceType;
  private static Case caseRrd;
  private static List<Case> caseRrdList;
  private static List<FlexNoteQuestion__c> flexNoteQuestList;
  private static List<FlexNote__c> AnswersList;
  private static List<ServiceRequestTypeFlexNote__c> sRTypeJunc;

  @testSetup static void setup() {
    List<ServiceRequestType__c> srTypeList = new List<ServiceRequestType__c> ();
    ServiceRequestType__c bulkType = new
    ServiceRequestType__c(Name = 'S0031',Service_Name__c = 'Bulk Collection',External_Name__c = 'Residential Bulk Collection');
    /*ServiceRequestType__c bicycleType = new ServiceRequestType__c(
      Name = 'ABANBI',
      Service_Name__c = 'Abandoned Bicycle',
      External_Name__c = 'Abandoned Bicycle',
      ContactStatus__c = 'Required(LN, FN, EM)',
      SLA__c = '20',
      Object__c = 'Case',
      Agency__c = 'DPW',
      SLAType__c = 'Business days',
      Description = '',
      LongExternalDescription__c = 'This service request is to be used for bicycles that are left on public space and which are abandoned.',
      Allow_Citizen_Web_Intake__c = true,
      Start_Date__c = '',
      Stop_Date__c = ''
      );*/
    insert bulkType;
    bulkServiceType = bulkType;

    OUCServiceRequestConfig__c oucServiceRequestConfig = new OUCServiceRequestConfig__c();
    oucServiceRequestConfig.BulkCollectionScheduleQuestion__c = 'SCHEDULED BULK COLLECTION DATE (cannot be changed)';
    oucServiceRequestConfig.BulkCollectionScheduleQuestionCode__c = 'DE0710';
    oucServiceRequestConfig.BulkScheduleDailyStopLimit__c = 10;
    oucServiceRequestConfig.DefaultBusinesshoursName__c = 'Fixed 8 Hour Schedule';
    oucServiceRequestConfig.NumberofDays__c = 1;
    oucServiceRequestConfig.Name = 'DailyLimit';
    insert oucServiceRequestConfig;

    List<BusinessHours> records = [Select b.Name, b.Id From BusinessHours b where Name = :OUCServiceRequestConfig__c.getValues('DailyLimit').DefaultBusinesshoursName__c and isActive = true];
    System.assert(records.size() >= 1);

    List<Holiday> holidays = [Select Id From Holiday];
    system.assert(!holidays.isEmpty());

    List<Decode_Object__c> decodeObjList = new List<Decode_Object__c> ();
    Decode_Object__c decode1 = new Decode_Object__c(Name = 'Testa', Code__c = 'CODE1', Value__c = 'Item1', Active__c = true);
    Decode_Object__c decode2 = new Decode_Object__c(Name = 'Testb', Code__c = 'CODE2', Value__c = 'Item2', Active__c = true);
    Decode_Object__c decode3 = new Decode_Object__c(Name = 'Testc', Code__c = 'CODE3', Value__c = 'Item3', Active__c = true);
    decodeObjList.add(decode1);
    decodeObjList.add(decode2);
    decodeObjList.add(decode3);
    insert decodeObjList;

    Contact con = new Contact(FirstName = 'Mars', LastName = 'bruno', email = 'testContact@abc.com', Phone = '1234567890');
    insert con;
    cont = con;

    ServiceRequestType__c sRT = new ServiceRequestType__c(Name = 'Test', Object__c = 'Case', Service_Name__c = 'Abandoned Vehicle- On Private Property', Default_Status__c = 'New', Default_Priority__c = 'Standard', Default_Method__c = 'Phone', ContactRequired__c = true, ServiceLocationRequired__c = true, SR_Alert_Message__c = 'Test Message', Start_Date__c = system.today(), Stop_Date__c = system.today(), DuplicateDetectionMethod__c = 'Standard', DuplicateRadius__c = 1, Duplicate_Threshold_Period__c = 1);
    insert sRT;
    serviceType = sRT;

    flexNoteQuestList = new List<FlexNoteQuestion__c> ();
    FlexNoteQuestion__c fNQuestion = new FlexNoteQuestion__c(Object_Name__c = 'Case', Questions__c = 'This is the test Question', Answer_Type__c = 'MultiPicklist', Name = 'Test1', AnswerValues__c = 'test1:a1,test2:a2'); //,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test Question'
    FlexNoteQuestion__c fNQuestion1 = new FlexNoteQuestion__c(Object_Name__c = 'Case', Questions__c = 'This is the test', Answer_Type__c = 'Text', Name = 'Test2'); //,Answer_Values__c='test1:a1,test2:a2');//,Question__c='This is the test'
    FlexNoteQuestion__c fNQuestion2 = new FlexNoteQuestion__c(Object_Name__c = 'Case', Questions__c = 'This is the test picklist', Answer_Type__c = 'Picklist', Name = 'Test3', AnswerValues__c = 'test1:a1,test2:a2'); //,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test picklist'
    FlexNoteQuestion__c fNQuestion3 = new FlexNoteQuestion__c(Object_Name__c = 'Case', Questions__c = 'This is the test Question', Answer_Type__c = 'MultiPicklist', Name = 'Test4', AnswerValues__c = 'test1:a1,test2:a2'); //,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test Question'
    FlexNoteQuestion__c fNQuestion4 = new FlexNoteQuestion__c(Object_Name__c = 'Case', Questions__c = 'This is the test', Answer_Type__c = 'MultiPicklist', Name = 'Test5', Answer_Values__c = decode2.Name); //,Question__c='This is the test'Name=Answer_Values__c='Test'
    FlexNoteQuestion__c fNQuestion5 = new FlexNoteQuestion__c(Object_Name__c = 'Case', Questions__c = 'This is the test picklist', Answer_Type__c = 'Picklist', Name = 'Test6', AnswerValues__c = decode1.Name); //,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test picklist'Name=decode1.Name
    FlexNoteQuestion__c fNQuestion6 = new FlexNoteQuestion__c(Object_Name__c = 'Case', Questions__c = 'This is the test Date ', Answer_Type__c = 'Date', Name = 'Test7'); //,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test picklist'Name=decode1.Name
    FlexNoteQuestion__c fNQuestion7 = new FlexNoteQuestion__c(Object_Name__c = 'Case', Questions__c = 'This is the test Date Time question', Answer_Type__c = 'Date/Time', Name = 'Test8'); //,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test picklist'Name=decode1.Name
    flexNoteQuestList.add(fnQuestion);
    flexNoteQuestList.add(fnQuestion1);
    flexNoteQuestList.add(fnQuestion2);
    flexNoteQuestList.add(fnQuestion3);
    flexNoteQuestList.add(fnQuestion4);
    flexNoteQuestList.add(fnQuestion5);
    flexNoteQuestList.add(fNQuestion6);
    flexNoteQuestList.add(fNQuestion7);
    insert flexNoteQuestList;

    sRTypeJunc = new list<ServiceRequestTypeFlexNote__c> ();
    ServiceRequestTypeFlexNote__c sRTypeFNRelation = new ServiceRequestTypeFlexNote__c(Service_Request_Type__c = sRT.Id, FlexNote_Question__c = fnQuestion.Id, Order__c = '1', IsRequired__c = false);
    ServiceRequestTypeFlexNote__c sRTypeFNRelation1 = new ServiceRequestTypeFlexNote__c(Service_Request_Type__c = sRT.Id, FlexNote_Question__c = fNQuestion2.Id, Order__c = '2');
    ServiceRequestTypeFlexNote__c sRTypeFNRelation2 = new ServiceRequestTypeFlexNote__c(Service_Request_Type__c = sRT.Id, FlexNote_Question__c = fNQuestion6.Id, Order__c = '3');
    ServiceRequestTypeFlexNote__c sRTypeFNRelation3 = new ServiceRequestTypeFlexNote__c(Service_Request_Type__c = sRT.Id, FlexNote_Question__c = fNQuestion7.Id, Order__c = '4');
    sRTypeJunc.add(sRTypeFNRelation);
    sRTypeJunc.add(sRTypeFNRelation1);
    sRTypeJunc.add(sRTypeFNRelation2);
    sRTypeJunc.add(sRTypeFNRelation3);
    insert sRTypeJunc;

    caseRrdList = new List<Case> ();
    Case c = new Case(Origin = 'Phone', Status = 'New', ContactId = con.Id, SRType__c = sRT.Id, Address__c = '1400 M STREET NW,WASHINGTON,DC,USA,20005.0');
    insert c;
    caseRrd = c;
    caseRrdList.add(caseRrd);

    AnswersList = new list<FlexNote__c> ();
    FlexNote__c fn = new FlexNote__c(Case__c = c.Id, FlexNote_Question__c = fNQuestion.Id, Answer__c = 'test1:a1', Questions__c = fNQuestion.Questions__c); //Question__c=fNQuestion.Question__c //Is_Answer__c='test1:a1',
    FlexNote__c fn1 = new FlexNote__c(Case__c = c.Id, FlexNote_Question__c = fNQuestion1.Id, Answer__c = 'test1:a1', Questions__c = fNQuestion.Questions__c); //,Is_Answer__c='test1:a1'..,Question__c=fNQuestion.Question__c,

    Date dt = Date.today();
    String datetimeStr = dt.format();
    FlexNote__c fn2 = new FlexNote__c(Case__c = c.Id, FlexNote_Question__c = fNQuestion6.Id, Answer__c = datetimeStr, Questions__c = fNQuestion6.Questions__c); //,Is_Answer__c='test1:a1'..,Question__c=fNQuestion.Question__c,

    String dtime = '12/10/2014 5:36 AM';
    FlexNote__c fn3 = new FlexNote__c(Case__c = c.Id, FlexNote_Question__c = fNQuestion7.Id, Answer__c = dtime, Questions__c = fNQuestion7.Questions__c); //,Is_Answer__c='test1:a1'..,Question__c=fNQuestion.Question__c,
    AnswersList.add(fn);
    AnswersList.add(fn1);
    AnswersList.add(fn2);
    AnswersList.add(fn3);
    insert AnswersList;

    Jurisdiction__c jur = new Jurisdiction__c(Department__c = '311- Call Center', Agency__c = 'OUC', name = '311CALCE');
    insert jur;
  }

  private static void pageSetup() {
    // Setup an instance of the page. 
    PageReference page = new PageReference('Page.Console311_Case');
    Test.setCurrentPageReference(page);
    // Set the get params for the page.
    Case c = [Select Id From Case Limit 1];
    System.currentPageReference().getParameters().put('clone', c.Id);
  }

  public static testMethod void testConstructor() {
    // Call the basic constructor.
    Console311_CaseController ctrl = new Console311_CaseController();

    // Test clone logic constructor.
    Console311_CaseControllerTest.pageSetup();
    ctrl = new Console311_CaseController();
    System.assert(ctrl.getIsBulkCollectionAddressSet());
    System.assertEquals(ctrl.getShortAddress(), '1400 M STREET NW');
  }

  public static testMethod void testSave() {
    // Call the basic constructor.
    Console311_CaseController ctrl = new Console311_CaseController();
    // Test getters.
    System.assert(!ctrl.getIsBulkCollectionAddressSet());

    pageSetup();
    // Test save without json param.
    System.assertEquals(null, ctrl.save());
    // Prep for save.
    System.currentPageReference().getParameters().put('caseObjJson', '{"c":{"Agency__c":"DPW","SLA__c":"20","Status":"Duplicate (Opened)","Origin":"Phone","Ward__c":"Ward 2","Description":"test"},"flexnotes":[{"Answer__c":"test","Order__c":"0","Questions__c":"Where is the bike located?","FlexNote_Question__c":"a02r0000000VDNLAA4"},{"Answer__c":"test","Order__c":"1","Questions__c":"Please provide description of the bike.","FlexNote_Question__c":"a02r0000000VDNMAA4"},{"Answer__c":"test","Order__c":"2","Questions__c":"Is the bike missing any parts?","FlexNote_Question__c":"a02r0000000VDNNAA4"},{"Answer__c":"test","Order__c":"3","Questions__c":"Is the bike attached to anything?","FlexNote_Question__c":"a02r0000000VDPJAA4"}],"contact":{"FirstName":"test","LastName":"test","Email":"test@test.com","MailingCountryCode":"US"}}');
    ctrl.storeJson();
    // Get service type id for controller.
    ServiceRequestType__c srt = [Select Id From ServiceRequestType__c Limit 1];
    ctrl.serviceType = srt.Id;
    ctrl.save();
  }

  public static testMethod void testGetServiceRequestItems() { 
    // Call the basic constructor.
    Console311_CaseController ctrl = new Console311_CaseController();
    System.assertNotEquals(null, ctrl.getServiceRequestItems());
  }

  public static testMethod void testGetServiceRequestNames() { 
    // Call the basic constructor.
    Console311_CaseController ctrl = new Console311_CaseController();
    System.assertNotEquals(null, ctrl.getServiceRequestNames());
  }

  public static testMethod void testGetPicklists() { 
    // Call the basic constructor.
    Console311_CaseController ctrl = new Console311_CaseController();
    System.assertNotEquals(null, ctrl.getStatusOptions());
    System.assertNotEquals(null, ctrl.getOriginOptions());
    System.assertNotEquals(null, ctrl.getStateOptions());
  }

  public static testMethod void testRerenderMap() {
    // Call the basic constructor.
    Console311_CaseController ctrl = new Console311_CaseController();
    System.assert(!ctrl.isMapVisible);
    ctrl.rerenderMap();
    System.assert(ctrl.isMapVisible);
    System.assertEquals(null, ctrl.rerenderMap());
  }

  public static testMethod void testAssortmentFunctions() {
    // Call the basic constructor.
    Console311_CaseController ctrl = new Console311_CaseController();

     List<BulkSchedule__c> testSchedules = new List<BulkSchedule__c>{
      new BulkSchedule__c(
        ScheduleDate__c = Date.TODAY(),
        Ward__c = 'Ward 2, Ward 4'
      )   
    };  
    insert testSchedules;

     pageSetup();
    // Test save without json param.
    System.assertEquals(null, ctrl.save());
    // Prep for save.
    System.currentPageReference().getParameters().put('caseObjJson', '{"c":{"Agency__c":"DPW","SLA__c":"14","Status":"Open","Origin":"Phone","Ward__c":"Ward 2","Description":"htrhtr"},"flexnotes":[{"Answer__c":"4/8/2016","Order__c":"0","Questions__c":"SCHEDULED BULK COLLECTION DATE (cannot be changed)","FlexNote_Question__c":"a02t0000000UyCLAA0"},{"Answer__c":"Single Family","Order__c":"3","Questions__c":"What type of residence do you have?","FlexNote_Question__c":"a02t0000000Uv0cAAC"},{"Answer__c":"Furniture","Order__c":"6","Questions__c":"Please identify the items for collection (refrigerator, household furniture, etc.)","FlexNote_Question__c":"a02t0000000Uz9XAAS"},{"Answer__c":"Front Collection","Order__c":"9","Questions__c":"Do you have front, rear or side collection?","FlexNote_Question__c":"a02t0000000Uv0SAAS"}],"contact":{"FirstName":"Trowa","LastName":"Barton","Email":"trowa.barton@mailinator.com","MailingCountryCode":"US"}}');
    ctrl.storeJson();
    
    // Get service type id for controller.
    ServiceRequestType__c srt = [Select Id From ServiceRequestType__c Where Name = 'S0031' Limit 1];
    ctrl.serviceType = srt.Id;
    ctrl.retrieveFlexNoteQuestions();
    ctrl.getAddressAutocompleteActionFunc();
    ctrl.retrieveFlexNoteQuestions();
    ctrl.save();
    // Catch a duplicate save.
    ctrl.save();

  }
}