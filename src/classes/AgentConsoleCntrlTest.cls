@isTest

public class AgentConsoleCntrlTest{
    
    
    private static contact cont;
    private static ServiceRequestType__c serviceType;
    private static case caseRrd;
    private static list<case> caseRrdList;
    private static list<FlexNoteQuestion__c> flexNoteQuestList;
    private static list<FlexNote__c>AnswersList;
    private static list<ServiceRequestTypeFlexNote__c>sRTypeJunc;
    
    private static void createData(){
        OUCServiceRequestConfig__c oucServiceRequestConfig=new OUCServiceRequestConfig__c ();
            oucServiceRequestConfig.BulkCollectionScheduleQuestion__c='SCHEDULED BULK COLLECTION DATE (cannot be changed)';
            oucServiceRequestConfig.BulkCollectionScheduleQuestionCode__c='DE0710';
            oucServiceRequestConfig.BulkScheduleDailyStopLimit__c=10 ;
            oucServiceRequestConfig.DefaultBusinesshoursName__c='Fixed 8 Hour Schedule';
            oucServiceRequestConfig.NumberofDays__c= 1;
            oucServiceRequestConfig.Name='DailyLimit';
        
        insert oucServiceRequestConfig;
        
        //BusinessHours stdBusinessHours = [Select b.Name, b.Id From BusinessHours b where Name=:OUCServiceRequestConfig__c.getValues('DailyLimit').DefaultBusinesshoursName__c and isActive = true];
        
        List <BusinessHours> records = [Select b.Name, b.Id From BusinessHours b where Name=:OUCServiceRequestConfig__c.getValues('DailyLimit').DefaultBusinesshoursName__c and isActive = true];
        System.assert(records.size() >= 1);

        List<Holiday> holidays = [Select Id From Holiday];
        system.assert(!holidays.isEmpty());
        
        
        Decode_Object__c decode1=new Decode_Object__c(Name='Testa', Code__c='CODE1',Value__c='Item1',Active__c=true);
        Decode_Object__c decode2=new Decode_Object__c(Name='Testb', Code__c='CODE2',Value__c='Item2',Active__c=true);
        Decode_Object__c decode3=new Decode_Object__c(Name='Testc', Code__c='CODE3',Value__c='Item3',Active__c=true);
        insert decode1;
        insert decode2;
        insert decode3;
        
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        Contact con=new Contact(FirstName='Mars',LastName='bruno', email='testContact@abc.com',Phone='1234567890');
        insert con;
        cont=con;
        
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        ServiceRequestType__c sRT=new ServiceRequestType__c(Name='Test',Object__c='Case',Service_Name__c='Abandoned Vehicle- On Private Property',Default_Status__c='New',Default_Priority__c='Standard',Default_Method__c='Phone',ContactRequired__c=true,ServiceLocationRequired__c=true,SR_Alert_Message__c='Test Message',Start_Date__c=system.today(), Stop_Date__c=system.today(),DuplicateDetectionMethod__c='Standard',DuplicateRadius__c=1,Duplicate_Threshold_Period__c=1);
        insert sRT;
        serviceType=sRT;
        
        flexNoteQuestList=new list<FlexNoteQuestion__c>();
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        FlexNoteQuestion__c fNQuestion=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='This is the test Question',Answer_Type__c='MultiPicklist' ,Name='Test1',AnswerValues__c='test1:a1,test2:a2');//,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test Question'
        insert fnQuestion;
        
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        FlexNoteQuestion__c fNQuestion1=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='This is the test',Answer_Type__c='Text' ,Name='Test2');//,Answer_Values__c='test1:a1,test2:a2');//,Question__c='This is the test'
        insert fnQuestion1;
        
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        FlexNoteQuestion__c fNQuestion2=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='This is the test picklist',Answer_Type__c='Picklist' ,Name='Test3',AnswerValues__c='test1:a1,test2:a2');//,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test picklist'
        insert fnQuestion2;
        
        FlexNoteQuestion__c fNQuestion3=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='This is the test Question',Answer_Type__c='MultiPicklist' ,Name='Test4',AnswerValues__c='test1:a1,test2:a2');//,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test Question'
        insert fNQuestion3;
        
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        FlexNoteQuestion__c fNQuestion4=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='This is the test',Answer_Type__c='MultiPicklist' ,Name='Test5',Answer_Values__c=decode2.Name);//,Question__c='This is the test'Name=Answer_Values__c='Test'
        insert fNQuestion4;
        
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        FlexNoteQuestion__c fNQuestion5=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='This is the test picklist',Answer_Type__c='Picklist' ,Name='Test6',AnswerValues__c=decode1.Name);//,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test picklist'Name=decode1.Name
        insert fNQuestion5;
        
        FlexNoteQuestion__c fNQuestion6=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='This is the test Date ',Answer_Type__c='Date' ,Name='Test7');//,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test picklist'Name=decode1.Name
        insert fNQuestion6;
        
        FlexNoteQuestion__c fNQuestion7=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='This is the test Date Time question',Answer_Type__c='Date/Time' ,Name='Test8');//,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test picklist'Name=decode1.Name
        insert fNQuestion7;
        
        
        
        flexNoteQuestList.add(fnQuestion);
        flexNoteQuestList.add(fnQuestion1);
        flexNoteQuestList.add(fnQuestion2);
        flexNoteQuestList.add(fnQuestion3);
        flexNoteQuestList.add(fnQuestion4);
        flexNoteQuestList.add(fnQuestion5);
        
        flexNoteQuestList.add(fNQuestion6);
        flexNoteQuestList.add(fNQuestion7);
        sRTypeJunc=new list<ServiceRequestTypeFlexNote__c>();
        
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        ServiceRequestTypeFlexNote__c sRTypeFNRelation=new ServiceRequestTypeFlexNote__c(Service_Request_Type__c=sRT.Id,FlexNote_Question__c=fnQuestion.Id,Order__c='1',IsRequired__c=false);
        insert sRTypeFNRelation;
        
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        ServiceRequestTypeFlexNote__c sRTypeFNRelation1=new ServiceRequestTypeFlexNote__c(Service_Request_Type__c=sRT.Id,FlexNote_Question__c=fNQuestion2.Id,Order__c='2');
        insert sRTypeFNRelation1;
        
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        ServiceRequestTypeFlexNote__c sRTypeFNRelation2=new ServiceRequestTypeFlexNote__c(Service_Request_Type__c=sRT.Id,FlexNote_Question__c=fNQuestion6.Id,Order__c='3');
        insert sRTypeFNRelation2;
        
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        ServiceRequestTypeFlexNote__c sRTypeFNRelation3=new ServiceRequestTypeFlexNote__c(Service_Request_Type__c=sRT.Id,FlexNote_Question__c=fNQuestion7.Id,Order__c='4');
        insert sRTypeFNRelation3;
        
        
        
        sRTypeJunc.add(sRTypeFNRelation);
        sRTypeJunc.add(sRTypeFNRelation1);
        sRTypeJunc.add(sRTypeFNRelation2);
        sRTypeJunc.add(sRTypeFNRelation3);
        
        caseRrdList=new list<case>();
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        Case c=new Case(Origin='Phone',Status='New',ContactId=con.Id,SRType__c=sRT.Id);
        insert c;      
        caseRrd=c;
        
        caseRrdList.add(caseRrd);
        
        AnswersList=new list<FlexNote__c>();
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        FlexNote__c fn=new FlexNote__c(Case__c=c.Id,FlexNote_Question__c=fNQuestion.Id,Answer__c='test1:a1',Questions__c=fNQuestion.Questions__c);//Question__c=fNQuestion.Question__c //Is_Answer__c='test1:a1',
        insert fn;
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        FlexNote__c fn1=new FlexNote__c(Case__c=c.Id,FlexNote_Question__c=fNQuestion1.Id,Answer__c='test1:a1',Questions__c=fNQuestion.Questions__c);//,Is_Answer__c='test1:a1'..,Question__c=fNQuestion.Question__c,
        insert fn1;
        
        Date dt = Date.today();
        String datetimeStr = dt.format();
        
        //date myDate = date.newInstance(2001, 3, 21);
        //String dayString = myDate.format();
        
         // THIS PART AS TO MOVE TO TESTHELPER CLASS
        FlexNote__c fn2=new FlexNote__c(Case__c=c.Id,FlexNote_Question__c=fNQuestion6.Id,Answer__c=datetimeStr,Questions__c=fNQuestion6.Questions__c);//,Is_Answer__c='test1:a1'..,Question__c=fNQuestion.Question__c,
        insert fn2;
        
        //datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
        // hard code for now will hve to change this
        string dtime='12/10/2014 5:36 AM';
         // THIS PART AS TO MOVE TO TESTHELPER CLASS
        FlexNote__c fn3=new FlexNote__c(Case__c=c.Id,FlexNote_Question__c=fNQuestion7.Id,Answer__c=dtime,Questions__c=fNQuestion7.Questions__c);//,Is_Answer__c='test1:a1'..,Question__c=fNQuestion.Question__c,
        insert fn3;
        
        
        AnswersList.add(fn);
        AnswersList.add(fn1);
        AnswersList.add(fn2);
        AnswersList.add(fn3);
        
        
        Jurisdiction__c jur=new Jurisdiction__c(Department__c='311- Call Center',Agency__c='OUC',name='311CALCE');
        insert jur;
        
    }
    
    
    public static testMethod void testAllMethods(){
        // create required data for all methods
        createData();
        // creating wrapper variable
        AgentConsoleCntrl.ContactCaseFlexNoteWrapper ccfw=new AgentConsoleCntrl.ContactCaseFlexNoteWrapper(cont,serviceType,caseRrd,AnswersList);
        AgentConsoleCntrl.LocationWrapper lw=new AgentConsoleCntrl.LocationWrapper();
        
        lw.street='3100 NW street';
        //lw.street=selStreet;
        lw.city='';
        lw.country='';
        lw.state='';
        lw.zipCode='';
        lw.longitude='';
        lw.latitude='';
        lw.addressId='';
        lw.roadwaySegId = '';
            
        // intersection 
        lw.intersectionId='';
        lw.intersectionFullAddress='';
        lw.placename='';
        //locationData=w;
        AgentConsoleCntrl.QuestionAnswerWrapper qAW=new AgentConsoleCntrl.QuestionAnswerWrapper(flexNoteQuestList[0],sRTypeJunc[0]);
        AgentConsoleCntrl.QuestionAnswerWrapper qAW1=new AgentConsoleCntrl.QuestionAnswerWrapper(flexNoteQuestList[1],sRTypeJunc[1]);
        
        AgentConsoleCntrl.QuestionAnswerWrapper qAW2=new AgentConsoleCntrl.QuestionAnswerWrapper(flexNoteQuestList[6],sRTypeJunc[2]);
        AgentConsoleCntrl.QuestionAnswerWrapper qAW3=new AgentConsoleCntrl.QuestionAnswerWrapper(flexNoteQuestList[7],sRTypeJunc[3]);
        
        list<AgentConsoleCntrl.QuestionAnswerWrapper> qAWList=new list<AgentConsoleCntrl.QuestionAnswerWrapper>{qAW,qAW1,qAW2,qAW3};
        
        
        
        //list<AgentConsoleCntrl.QuestionAnswerWrapper> qAWList=new list<AgentConsoleCntrl.QuestionAnswerWrapper>{qAW,qAW1};
        AgentConsoleCntrl.ServiceRequestQuestionWrapper sRQW=new AgentConsoleCntrl.ServiceRequestQuestionWrapper(serviceType,qAWList);
        list<AgentConsoleCntrl.ServiceRequestQuestionWrapper> sRQWList=new list<AgentConsoleCntrl.ServiceRequestQuestionWrapper>();
        sRQWList.add(sRQW);
            
            
        PageReference pge=Page.AgentConsolePge;
        Test.setCurrentPage(pge);
        ApexPages.CurrentPage().getParameters().put('sfdc.tabName','');
        string tabName=ApexPages.CurrentPage().getParameters().get('sfdc.tabName');
        system.assertEquals('', tabName);
        
        ApexPages.CurrentPage().getParameters().put('selStreetParm','3100 N STREET NW');
        ApexPages.CurrentPage().getParameters().put('selCityParm','WASHINGTON');
        ApexPages.CurrentPage().getParameters().put('selStateParm','DC');
        ApexPages.CurrentPage().getParameters().put('selCountryParm','USA');
        ApexPages.CurrentPage().getParameters().put('selZipCodeParm','20007');
        ApexPages.CurrentPage().getParameters().put('selLongituteParm','-77.06140122');
        ApexPages.CurrentPage().getParameters().put('selLatitudeParm','38.90667757');
        ApexPages.CurrentPage().getParameters().put('selInterIdParam','');
        ApexPages.CurrentPage().getParameters().put('selInterFullAdrsParam','');
        ApexPages.CurrentPage().getParameters().put('selAliasParam','');
        ApexPages.CurrentPage().getParameters().put('selAddressIdParm','274821');
        ApexPages.currentPage().getParameters().put('selRoadwaySegId', '12345.0');
        
        ApexPages.CurrentPage().getParameters().put('selQuadrantParam','NW');
        ApexPages.CurrentPage().getParameters().put('selXCoordParam','394674.32');
        ApexPages.CurrentPage().getParameters().put('selYCoordParam','137648.32');
        ApexPages.CurrentPage().getParameters().put('selANCParam','ANC 2E');
        ApexPages.CurrentPage().getParameters().put('selPSAParam','Police Service Area 206');
        ApexPages.CurrentPage().getParameters().put('selWardParam','Ward 2');
        ApexPages.CurrentPage().getParameters().put('selSMDParam','SMD 2E05');
        ApexPages.CurrentPage().getParameters().put('selPodlistParam','Police District - Second District');
        ApexPages.CurrentPage().getParameters().put('selClusterParam','');
        ApexPages.currentPage().getParameters().put('selfullBlockParam','');
        ApexPages.currentPage().getParameters().put('selblockNameParam','');
        
        
        
        string selStreetParm=ApexPages.CurrentPage().getParameters().get('selStreetParm');
        string selCityParm=ApexPages.CurrentPage().getParameters().get('selCityParm');
        string selStateParm=ApexPages.CurrentPage().getParameters().get('selStateParm');
        string selCountryParm=ApexPages.CurrentPage().getParameters().get('selCountryParm');
        string selZipCodeParm=ApexPages.CurrentPage().getParameters().get('selZipCodeParm');
        string selLongituteParm=ApexPages.CurrentPage().getParameters().get('selLongituteParm');
        string selInterIdParam=ApexPages.CurrentPage().getParameters().get('selInterIdParam');
        string selInterFullAdrsParam=ApexPages.CurrentPage().getParameters().get('selInterFullAdrsParam');
        string selAliasParam=ApexPages.CurrentPage().getParameters().get('selAliasParam');
        string selAddressIdParm=ApexPages.CurrentPage().getParameters().get('selAddressIdParm');
        string selLatitudeParm=ApexPages.CurrentPage().getParameters().get('selLatitudeParm');
        string selRoadwaySegId = ApexPages.currentPage().getParameters().get('selRoadwaySegId');
        
        string selQuadrant=ApexPages.currentPage().getParameters().get('selQuadrantParam');
        string selXCoord=ApexPages.currentPage().getParameters().get('selXCoordParam');
        string selYCoord=ApexPages.currentPage().getParameters().get('selYCoordParam');
        string selANC=ApexPages.currentPage().getParameters().get('selANCParam');
        string selPSA=ApexPages.currentPage().getParameters().get('selPSAParam');
        string selWard=ApexPages.currentPage().getParameters().get('selWardParam');
        string selSMD=ApexPages.currentPage().getParameters().get('selSMDParam');
        string selPodlist=ApexPages.currentPage().getParameters().get('selPodlistParam');
        string selCluster=ApexPages.currentPage().getParameters().get('selClusterParam');
        
        string selFullBlock=ApexPages.currentPage().getParameters().get('selfullBlockParam');
        string selBlockName=ApexPages.currentPage().getParameters().get('selblockNameParam');
       
        system.assertEquals('3100 N STREET NW', selStreetParm);
        system.assertEquals('WASHINGTON', selCityParm);
        system.assertEquals('DC', selStateParm);
        system.assertEquals('USA', selCountryParm);
        system.assertEquals('20007', selZipCodeParm);
        system.assertEquals('-77.06140122', selLongituteParm);
        system.assertEquals('', selInterIdParam);
        system.assertEquals('', selInterFullAdrsParam);
        system.assertEquals('', selAliasParam);
        system.assertEquals('274821', selAddressIdParm);
        system.assertEquals('38.90667757', selLatitudeParm);
        system.assertEquals('12345.0', selRoadwaySegId);
        
        
        system.assertEquals('NW', selQuadrant);
        system.assertEquals('394674.32', selXCoord);
        system.assertEquals('137648.32', selYCoord);
        system.assertEquals('ANC 2E', selANC);
        system.assertEquals('Police Service Area 206', selPSA);
        system.assertEquals('Ward 2', selWard);
        system.assertEquals('SMD 2E05', selSMD);
        system.assertEquals('Police District - Second District', selPodlist);
        system.assertEquals('', selCluster);
        
        system.assertEquals('', selFullBlock);
        system.assertEquals('', selBlockName);
        
        
        
        AgentConsoleCntrl controller =new AgentConsoleCntrl();
        
        controller.casesList=caseRrdList;
        controller.selServicRequestNumber='';
        controller.selContactPhone='';
        controller.selContactEmail='';
        controller.selServiceAddress='';
        
        //controller.selServiceRequestType=serviceType.Name;
        controller.selServiceRequestType=serviceType.Service_Name__c;
        //system.assertNotEquals(null, controller.selContactPhone);
        //system.assertNotEquals(null, controller.selContactEmail);
        //system.assertNotEquals(null, controller.selServiceRequestType);
        system.assertNotEquals(null, controller.selServiceRequestType);
        system.assertEquals('', controller.selContactEmail);
        system.assertEquals('', controller.selServicRequestNumber);
        system.assertEquals('', controller.selContactPhone);
        
        system.assertEquals('', controller.selServiceAddress);
        controller.doSearch(); 
        controller.selectedParamCaseId=caseRrd.Id;
        controller.contactCaseFlexNote=ccfw;
        
        controller.serviceRequestQuestionWrapList=sRQWList;
        controller.doRetreieveContactCasesFlexNotes();
        controller.locationData=lw;
        controller.retrieveAdresses();
        controller.allPrivateMethods();
        
        //controller.doClearOldDataCreateNewForm();
        
       
        controller.serviceType=serviceType.Id;
        // collecting all questions answers for selected service type
       // controller.serviceRequestQuestionWrapList=sRQWList;
        controller.selAnswerValue='Other';
        controller.selIndex=0;
        controller.doRenderInputText();
        controller.doRetrieveFlexNotesAnswer();
        controller.doAddressSelection();
        controller.doSave();
        controller.doDeleteFlexNotes(AnswersList);
        controller.doClearOldDataCreateNewForm();
        controller.doCancel();
        List<SelectOption> selItemsList=controller.getServiceRequestItems();
        
        caseRrd.Address__c = null;
        update caseRrd;
        controller.doSave();
    } 
    
    public static testMethod void testAllStaticMethods(){
        // create required data for all methods
        createData();
        AgentConsoleCntrl.ContactCaseFlexNoteWrapper ccfw=new AgentConsoleCntrl.ContactCaseFlexNoteWrapper(cont,serviceType,caseRrd,AnswersList);
        AgentConsoleCntrl.QuestionAnswerWrapper qAW=new AgentConsoleCntrl.QuestionAnswerWrapper(flexNoteQuestList[0],sRTypeJunc[0]);
        AgentConsoleCntrl.QuestionAnswerWrapper qAW1=new AgentConsoleCntrl.QuestionAnswerWrapper(flexNoteQuestList[1],sRTypeJunc[1]);
        
        AgentConsoleCntrl.QuestionAnswerWrapper qAW2=new AgentConsoleCntrl.QuestionAnswerWrapper(flexNoteQuestList[6],sRTypeJunc[2]);
        AgentConsoleCntrl.QuestionAnswerWrapper qAW3=new AgentConsoleCntrl.QuestionAnswerWrapper(flexNoteQuestList[7],sRTypeJunc[3]);
        
        list<AgentConsoleCntrl.QuestionAnswerWrapper> qAWList=new list<AgentConsoleCntrl.QuestionAnswerWrapper>{qAW,qAW1,qAW2,qAW3};
        
        //list<AgentConsoleCntrl.QuestionAnswerWrapper> qAWList=new list<AgentConsoleCntrl.QuestionAnswerWrapper>{qAW,qAW1};
        AgentConsoleCntrl.ServiceRequestQuestionWrapper sRQW=new AgentConsoleCntrl.ServiceRequestQuestionWrapper(serviceType,qAWList);
        list<AgentConsoleCntrl.ServiceRequestQuestionWrapper> sRQWList=new list<AgentConsoleCntrl.ServiceRequestQuestionWrapper>();
        sRQWList.add(sRQW);
            
        AgentConsoleCntrl.LocationWrapper lw=new AgentConsoleCntrl.LocationWrapper();
        lw.street='3100 NW street';
        //lw.street=selStreet;
        lw.city='WASHINGTON';
        lw.country='USA';
        lw.state='DC';
        lw.zipCode='20007.0';
        //lw.longitude='1376.32';
        //lw.latitude='3946.32';
        lw.longitude='';
        lw.latitude='';
        lw.addressId='274821.0';
        lw.roadwaySegId = '';
            
        // intersection 
        lw.intersectionId='';
        lw.intersectionFullAddress='';
        lw.placename='';
        lw.quadrant='';
        lw.xCoord='';
        lw.yCoord='';
        lw.aNC='';
        lw.pSA='';
        lw.ward='';
        lw.xCoord='';
        lw.yCoord='';
        lw.aNC='';
        lw.pSA='';
        lw.podList='';
        lw.cluster='';
        lw.sMD='';
        
        PageReference pge=Page.AgentConsolePge;
        Test.setCurrentPage(pge);
        AgentConsoleCntrl controller =new AgentConsoleCntrl();
        controller.selContactPhone=cont.Phone;
        controller.casesList=caseRrdList;
        
        
        controller.selServicRequestNumber='';
        controller.selServiceRequestType='';
        controller.selContactEmail='';
        controller.selServiceAddress='';
        
        //controller.selContactPhone='';
        //controller.selServiceRequestType=serviceType.Name;
       
         
        system.assertNotEquals(null, controller.selContactPhone);
        system.assertEquals('', controller.selContactEmail);
        system.assertEquals('', controller.selServiceRequestType);
        system.assertEquals('', controller.selServicRequestNumber);
        system.assertEquals('', controller.selServiceAddress);
        
        controller.doSearch();
        controller.selectedParamCaseId=caseRrd.Id;
        controller.locationData=lw;
        controller.locationData.street='3100 NW street';
        system.assertEquals('3100 NW street',  controller.locationData.street);
        controller.retrieveAdresses();
        controller.doSave();
    }
    
    public static testMethod void testNegative(){
        
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        Contact con=new Contact(FirstName='Mars',LastName='bruno', email='testContact@abc.com',Phone='1234567890');
        insert con;
        
                // THIS PART AS TO MOVE TO TESTHELPER CLASS
        ServiceRequestType__c sRT=new ServiceRequestType__c(Name='Test',Object__c='Case',Service_Name__c='Abandoned Vehicle- On Private Property',Default_Status__c='New',Default_Priority__c='Standard',Default_Method__c='Phone',Start_Date__c=system.today(), Stop_Date__c=system.today());
        insert sRT;
        // THIS PART AS TO MOVE TO TESTHELPER CLASS
        Case c=new Case(Origin='Phone',Status='New',ContactId=con.Id,SRType__c=sRT.Id);
        insert c;
        system.debug('case numbere--'+c.CaseNumber);
        
        
        case cRcrd=[select id,contact.email,Origin,Status,ContactId,SRType__c,caseNumber,SRType__r.Service_Name__c,SRType__r.Name from case where id=:c.Id limit 1];
        ServiceRequestType__c sRcrd=[select id,name ,Object__c,Service_Name__c from ServiceRequestType__c where id=:sRT.Id limit 1];
        
        contact conRcrd=[select id,name from contact where id=:con.Id];
        
        
        //AgentConsoleCntrl.getAddressSuggestion('3100 N STREET');
        AgentConsoleCntrl.getAddressSuggestion('14th%20@%20U%20St');
        // calling static remoting methods
        AgentConsoleCntrl.getCaseList('1234567890', '3');
        
        // calling static remoting methods
        AgentConsoleCntrl.getCaseList(cRcrd.caseNumber, '1');
        
        // calling static remoting methods
        AgentConsoleCntrl.getCaseList(cRcrd.SRType__r.Service_Name__c, '4');
        
        // calling static remoting methods
        AgentConsoleCntrl.getCaseList(cRcrd.contact.email, '2');
        
        //AgentConsoleCntrl.getCaseList('sdfa', '3');
        AgentConsoleCntrl.getServiceRequestList(sRcrd.Service_Name__c);
        
        
        AgentConsoleCntrl.getContactList(cRcrd.contact.email, '1');
        
        PageReference pge=Page.AgentConsolePge;
        Test.setCurrentPage(pge);
        AgentConsoleCntrl controller =new AgentConsoleCntrl();
        controller.selContactPhone=con.Phone;
        system.assertEquals(con.Phone, controller.selContactPhone);
        
        
        ApexPages.CurrentPage().getParameters().put('conId',con.Id);
        string conId=ApexPages.CurrentPage().getParameters().get('conId');
        
        ApexPages.CurrentPage().getParameters().put('conlkId',conRcrd.Name);
        string conlkId=ApexPages.CurrentPage().getParameters().get('conlkId');
        
        system.assertEquals(con.Id, conId);
        system.assertEquals(conRcrd.Name, conlkId);
        controller.updateContactsDetails();
        
        
        
        controller.doSearch();
        controller.doSave();
        
    }
    
    public static testMethod void testAllStaticMethods1(){
        // create required data for all methods
        createData();
        AgentConsoleCntrl.ContactCaseFlexNoteWrapper ccfw=new AgentConsoleCntrl.ContactCaseFlexNoteWrapper(cont,serviceType,caseRrd,AnswersList);
        AgentConsoleCntrl.QuestionAnswerWrapper qAW=new AgentConsoleCntrl.QuestionAnswerWrapper(flexNoteQuestList[0],sRTypeJunc[0]);
        AgentConsoleCntrl.QuestionAnswerWrapper qAW1=new AgentConsoleCntrl.QuestionAnswerWrapper(flexNoteQuestList[1],sRTypeJunc[1]);
        
        AgentConsoleCntrl.QuestionAnswerWrapper qAW2=new AgentConsoleCntrl.QuestionAnswerWrapper(flexNoteQuestList[6],sRTypeJunc[2]);
        AgentConsoleCntrl.QuestionAnswerWrapper qAW3=new AgentConsoleCntrl.QuestionAnswerWrapper(flexNoteQuestList[7],sRTypeJunc[3]);
        
        
        list<AgentConsoleCntrl.QuestionAnswerWrapper> qAWList=new list<AgentConsoleCntrl.QuestionAnswerWrapper>{qAW,qAW1,qAW2,qAW3};
        AgentConsoleCntrl.ServiceRequestQuestionWrapper sRQW=new AgentConsoleCntrl.ServiceRequestQuestionWrapper(serviceType,qAWList);
        list<AgentConsoleCntrl.ServiceRequestQuestionWrapper> sRQWList=new list<AgentConsoleCntrl.ServiceRequestQuestionWrapper>();
        sRQWList.add(sRQW);
            
        AgentConsoleCntrl.LocationWrapper lw=new AgentConsoleCntrl.LocationWrapper();
        
        lw.street='3100 NW street';
        //lw.street=selStreet;
        lw.city='WASHINGTON';
        lw.country='USA';
        lw.state='DC';
        lw.zipCode='20007';
        //lw.longitude='1376.32';
        //lw.latitude='3946.32';
        lw.longitude='';
        lw.latitude='';
        lw.addressId='274821';
        lw.roadwaySegId = '';
            
        // intersection 
        lw.intersectionId='';
        lw.intersectionFullAddress='';
        lw.placename='';
        lw.quadrant='';
        lw.xCoord='';
        lw.yCoord='';
        lw.aNC='';
        lw.pSA='';
        lw.ward='';
        lw.xCoord='';
        lw.yCoord='';
        lw.aNC='';
        lw.pSA='';
        lw.podList='';
        lw.cluster='';
        lw.sMD='';
        lw.fullBlock='';
        lw.blockName='';
        
        PageReference pge=Page.AgentConsolePge;
        Test.setCurrentPage(pge);
        
        ApexPages.CurrentPage().getParameters().put('sfdc.tabName','');
        string tabName=ApexPages.CurrentPage().getParameters().get('sfdc.tabName');
        system.assertEquals('', tabName);
        
        AgentConsoleCntrl controller =new AgentConsoleCntrl();
        controller.selContactEmail=cont.email;
        
        system.debug('email details ---'+controller.selContactEmail);
        system.debug('email details to compare--->'+cont.email);
        //system.assertEquals(cont.email, controller.selContactEmail);
        
        controller.casesList=caseRrdList;
        controller.selServicRequestNumber='';
        controller.selContactPhone='';
       // controller.selContactEmail='';
        //controller.selServiceRequestType=serviceType.Name;
        controller.selServiceRequestType='';
        controller.selServiceAddress='';
        
        system.assertNotEquals(null, controller.selContactEmail);
        system.assertEquals('', controller.selServiceRequestType);
        system.assertEquals('', controller.selServicRequestNumber);
        system.assertEquals('', controller.selContactPhone);
        system.assertEquals('', controller.selServiceAddress);
        controller.doSearch();
        
        controller.selectedParamCaseId=caseRrd.Id;
        controller.locationData.street='3100 NW street';
        system.assertEquals('3100 NW street',  controller.locationData.street);
        ApexPages.CurrentPage().getParameters().put('streetParm','3100 NW street');
        ApexPages.CurrentPage().getParameters().put('zipCodeParm','20007');
        ApexPages.CurrentPage().getParameters().put('wardIdParam','Ward 2');
        ApexPages.CurrentPage().getParameters().put('AliasIdParam','');
        ApexPages.CurrentPage().getParameters().put('intersectionIdParam','');
        ApexPages.CurrentPage().getParameters().put('intersectionFullAddressParm','');
        
        ApexPages.CurrentPage().getParameters().put('fullBlockParam',null);
        ApexPages.CurrentPage().getParameters().put('fullBlockParam',null);
        
        ApexPages.CurrentPage().getParameters().put('latitudeParam','');
        ApexPages.CurrentPage().getParameters().put('longitudeParam','');
        
        
        string selStreetParm=ApexPages.CurrentPage().getParameters().get('streetParm');
        string selZipCodeParm=ApexPages.CurrentPage().getParameters().get('zipCodeParm');
        string selWardParm=ApexPages.CurrentPage().getParameters().get('wardIdParam');
        string selAliasIdParm=ApexPages.CurrentPage().getParameters().get('AliasIdParam');
        string selintersectionIdParm=ApexPages.CurrentPage().getParameters().get('intersectionIdParam');
        string selintersectionFullAddressParm=ApexPages.CurrentPage().getParameters().get('intersectionFullAddressParm');
        
        string selFullBlock=ApexPages.currentPage().getParameters().get('fullBlockParam');
        string selBlockName=ApexPages.currentPage().getParameters().get('blockNameParam');
        
        string sellatitudeParam=ApexPages.currentPage().getParameters().get('latitudeParam');
        string sellongitudeParam=ApexPages.currentPage().getParameters().get('longitudeParam');

        controller.locationData=lw;
        system.assertEquals('3100 NW street', selStreetParm);
        system.assertEquals('20007', selZipCodeParm); 
        system.assertEquals('Ward 2', selWardParm);
        system.assertEquals('', selAliasIdParm);
        system.assertEquals('', selintersectionIdParm);
        system.assertEquals('', selintersectionFullAddressParm);
        
        system.assertEquals(null, selFullBlock);
        system.assertEquals(null, selBlockName);
        
        system.assertEquals('', sellatitudeParam);
        system.assertEquals('', sellongitudeParam);
        
        controller.doAssignSelAddress();
        controller.contactCaseFlexNote=ccfw;
        controller.serviceRequestQuestionWrapList=sRQWList;
       // string tabId=ApexPages.currentPage().getParameters().get('sfdc.tabName');
       // system.assertNotEquals('', tabId); 
        //controller.doDeleteFlexNotes(AnswersList);  // 11114
        
        contact conRcrd=[select id,name from contact where id=:cont.Id];
        
        ApexPages.CurrentPage().getParameters().put('conId',conRcrd.Id);
        string conId=ApexPages.CurrentPage().getParameters().get('conId');
        
        ApexPages.CurrentPage().getParameters().put('conlkId',conRcrd.Name);
        string conlkId=ApexPages.CurrentPage().getParameters().get('conlkId');
        
        system.assertEquals(conRcrd.Id, conId);
        system.assertEquals(conRcrd.Name, conlkId);
        controller.updateContactsDetails();
        
        
        controller.setServiceType(serviceType.Id);
        controller.getServiceType();
        system.assertEquals(controller.getServiceType(),serviceType.Id);
        controller.doClone();   //2012 
        
        system.assertEquals(controller.getServiceType(),serviceType.Id);
        controller.doCloneDuplicateSR();   //2012 
        
        system.assertEquals(controller.getServiceType(),serviceType.Id);
        controller.doCloneCopySR();   //2012       
        
         
        controller.doSave();
        controller.doDeleteFlexNotes(AnswersList);  
        controller.doCancel();
        //ApexPages.currentPage().getParameters().get('sfdc.tabName');
        list<FlexNote__c>newFNList=AnswersList.clone();
        controller.doDeleteFlexNotes(newFNList);
        controller.doClearOldDataCreateNewForm();
        
        
        List<SelectOption> selItemsList=controller.getServiceRequestItems();
       
        /*ApexPages.CurrentPage().getParameters().put('Id',caseRrd.Id);
        string caseId =ApexPages.currentPage().getParameters().get('Id');
        system.assertEquals(caseRrd.Id, caseId);
        //system.assertEquals(caseRrd.Id, tabId);
        */
       
       /* controller.setServiceType(serviceType.Id);
        controller.getServiceType();
        system.assertEquals(controller.getServiceType(),serviceType.Id);
        */
         
    }
    
    
}