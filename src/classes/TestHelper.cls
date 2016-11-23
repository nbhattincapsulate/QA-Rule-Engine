public with sharing class TestHelper{
    
    public static contact cont;
    public static ServiceRequestType__c serviceType1;
    public static case caseRrd;
    public static list<case> caseRrdList;
    public static list<FlexNoteQuestion__c> flexNoteQuestList;
    public static list<FlexNote__c>AnswersList;
    public static list<ServiceRequestTypeFlexNote__c>sRTypeJunc;   
    public static string APIKey;
    
    
    public static void createData(){

        Contact con=new Contact(FirstName='Mars',LastName='bruno', email='testContact@abc.com',Phone='1234567890');
        insert con;
        cont=con;
        
        Decode_Object__c obj = new Decode_Object__c(code__c='A123',value__c='this is a test ans');
        insert obj;
        
        
        ServiceRequestType__c sRT=new ServiceRequestType__c(Name='DMV19',Object__c='Case',Service_Name__c='Abandoned Vehicle- On Private Property',Default_Status__c='New',Default_Priority__c='Standard',Default_Method__c='Phone',SR_Alert_Message__c='Test Message');
        insert sRT;
        serviceType1=sRT;
        
        flexNoteQuestList=new list<FlexNoteQuestion__c>();
        
        FlexNoteQuestion__c fNQuestion=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='This is the test Question',Answer_Type__c='MultiPicklist' ,Name='Test1',AnswerValues__c='test1:a1,test2:a2');//,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test Question'
         
        FlexNoteQuestion__c fNQuestion1=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='This is the test',Answer_Type__c='Text' ,Name='Test2');//,Answer_Values__c='test1:a1,test2:a2');//,Question__c='This is the test'
       
        FlexNoteQuestion__c fNQuestion2=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='This is the test picklist',Answer_Type__c='Picklist' ,Name='Test3',AnswerValues__c='test1:a1,test2:a2');//,Answer_Values__c='test1:a1,test2:a2');//Question__c='This is the test picklist'
       
        
        flexNoteQuestList.add(fnQuestion);
        flexNoteQuestList.add(fnQuestion1);
        flexNoteQuestList.add(fnQuestion2);
        
        insert flexNoteQuestList;
        
        sRTypeJunc=new list<ServiceRequestTypeFlexNote__c>();
        
        
        ServiceRequestTypeFlexNote__c sRTypeFNRelation=new ServiceRequestTypeFlexNote__c(Service_Request_Type__c=sRT.Id,FlexNote_Question__c=fnQuestion.Id,Order__c='1',IsRequired__c=true);
        
        ServiceRequestTypeFlexNote__c sRTypeFNRelation1=new ServiceRequestTypeFlexNote__c(Service_Request_Type__c=sRT.Id,FlexNote_Question__c=fNQuestion2.Id,Order__c='1');
      
        sRTypeJunc.add(sRTypeFNRelation);
        sRTypeJunc.add(sRTypeFNRelation1);
        
        
        insert sRTypeJunc;
        
        caseRrdList=new list<case>();
       
        Case c=new Case(Origin='Phone',Status='New',ContactId=con.Id,SRType__c=sRT.Id);
        insert c;      
        caseRrd=c;
        
        caseRrdList.add(caseRrd);

        Case c2=new Case(Origin='Phone',Status='Open',LegacyID__c='CSR-test',ContactId=con.Id,SRType__c=sRT.Id);
        insert c2;      
        
        //caseRrdList.add(c2);
        
        AnswersList=new list<FlexNote__c>();
        
        FlexNote__c fn=new FlexNote__c(Case__c=c.Id,FlexNote_Question__c=fNQuestion.Id,Answer__c='test1:a1',Questions__c=fNQuestion.Question__c);//Question__c=fNQuestion.Question__c //Is_Answer__c='test1:a1',
        FlexNote__c fn1=new FlexNote__c(Case__c=c.Id,FlexNote_Question__c=fNQuestion1.Id,Answer__c='test1:a1',Questions__c=fNQuestion1.Question__c);//,Is_Answer__c='test1:a1'..,Question__c=fNQuestion.Question__c,

        FlexNote__c fn2=new FlexNote__c(Case__c=c2.Id,FlexNote_Question__c=fNQuestion.Id,LegacyId__c='CSR-test1',Answer__c='test1:a1',CodeDescriptionSourcePart1__c='CODE1,CODE2',CodeDescriptionSourcePart2__c='value1,othervalue',Questions__c=fNQuestion.Question__c);//Question__c=fNQuestion.Question__c //Is_Answer__c='test1:a1',
        FlexNote__c fn3=new FlexNote__c(Case__c=c2.Id,FlexNote_Question__c=fNQuestion1.Id,LegacyId__c='CSR-test2422',Answer__c='otherwanswertest1:a1',Questions__c=fNQuestion1.Question__c);//,Is_Answer__c='test1:a1'..,Question__c=fNQuestion.Question__c,
       
        AnswersList.add(fn);
        AnswersList.add(fn1);    
        AnswersList.add(fn2);
        AnswersList.add(fn3);    
        insert AnswersList;
        
        OUC_Activity__c oucActivity= new OUC_Activity__c(Case__c=c.Id);
      	insert oucActivity;
      
         
        Service_Request_History__c h = new Service_Request_History__c(Origin__c='Phone',Status__c='New',DateTimeOpened__c=DateTime.valueofGMT('2015-01-01 00:01:02'),IsClosed__c=true);
        insert h;
        Service_Request_History__c h2 = new Service_Request_History__c(Origin__c='Phone',Status__c='New',DateTimeOpened__c=DateTime.valueofGMT('2015-01-01 00:02:03'),IsClosed__c=false);
        insert h2;
        
        Map<String,String> code = new Map<String,String>();
        code.put('FYTRS','This is a test');
        List<Flex_Note_History__c> hL= new List<Flex_Note_History__c>();
        Flex_Note_History__c fnh=new Flex_Note_History__c(CodeDescription__c= JSON.serialize(code),Service_Request_History__c=h.Id,Flex_Note_Id__c=fNQuestion.Id,Answer__c='test1:a1',Questions__c=fNQuestion.Question__c);//Question__c=fNQuestion.Question__c //Is_Answer__c='test1:a1',
        Flex_Note_History__c fnh1=new Flex_Note_History__c(CodeDescription__c= JSON.serialize(code),Service_Request_History__c=h.Id,Flex_Note_Id__c=fNQuestion1.Id,Answer__c='test1:a1',Questions__c=fNQuestion.Question__c);//,Is_Answer__c='test1:a1'..,Question__c=fNQuestion.Question__c,
        Flex_Note_History__c fnh2=new Flex_Note_History__c(CodeDescriptionSourcePart1__c='CODE1,CODE2',CodeDescriptionSourcePart2__c='value1,Value22',Service_Request_History__c=h.Id,Flex_Note_Id__c='CSR-test1234',Answer__c='test1:a1',Questions__c=fNQuestion.Question__c);//,Is_Answer__c='test1:a1'..,Question__c=fNQuestion.Question__c,
        
        hL.add(fnh);
        hL.add(fnh1);
        hl.add(fnh2);
        
        insert hL; 
        
        OUC_Activity_History__c oucActivity2= new OUC_Activity_History__c(Service_Request_History__c=h.Id);
      	insert oucActivity2;
      	
        OUC_Activity_History__c oucActivity3= new OUC_Activity_History__c(Service_Request_History__c=h2.Id);
      	insert oucActivity3;

      	string thisKey = 'class2Private';
      	Open311ApiKeyConfig__c key = new Open311ApiKeyConfig__c(ApiKey__c=thisKey,Private__c=true,Usage_Limit_Allocation__c=1000);
      	insert key;
        System.debug('----> Test Api Key: ' + key);
      	APIKey = thisKey;
         
    }
      
}