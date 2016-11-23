@IsTest
public class ServiceRequestAdminCntrlTest {
    
    public static testMethod void testServiceAdminCntrl(){
        
        // this as to move to helper class
        ServiceRequestType__c srType=new ServiceRequestType__c(Name='Test',Object__c='Case',Service_Name__c='Abandon on Private Vechicle');
        insert srType;
        
         // creating data we have to move this to testhelper class
        FlexNoteQuestion__c fNQuestion=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='TestQuestion',Answer_Type__c='Text' ,Name='Test');
        insert fnQuestion;
        
        ServiceRequestTypeFlexNote__c sRTypeFNRelation=new ServiceRequestTypeFlexNote__c(Service_Request_Type__c=srType.Id,FlexNote_Question__c=fnQuestion.Id,Order__c='1');
        insert sRTypeFNRelation;
        
        
        //Use the PageReference Apex class to instantiate a page
           PageReference pageRef = Page.ServiceRequestAdminPge;
           
           //In this case, the Visualforce page named 'ServiceRequestAdminCntrl' is the starting point of this test method. 
           Test.setCurrentPage(pageRef);
           ApexPages.currentPage().getParameters().put('isInvokedFrmFNQuestion', 'True');
           ApexPages.currentPage().getParameters().put('isEdit', 'true');
           ApexPages.currentPage().getParameters().put('sRTypeId', srType.Id);
           
           //Instantiate and construct the controller class.   
           ServiceRequestAdminCntrl controller = new ServiceRequestAdminCntrl();
           
           // flex note question and relation wrap
           ServiceRequestAdminCntrl.FlexNoteQuestionRelationWrapper fNQuestionRelWrap=new ServiceRequestAdminCntrl.FlexNoteQuestionRelationWrapper(fNQuestion,sRTypeFNRelation);
           // service request flex note question and relation wrap
           ServiceRequestAdminCntrl.SRTFlexNoteQuestionRelationWrapper SRTypeFlexNoteRel=new ServiceRequestAdminCntrl.SRTFlexNoteQuestionRelationWrapper(srType);
           SRTypeFlexNoteRel.flexNoteRelationList.add(fNQuestionRelWrap);
           
           list<ServiceRequestAdminCntrl.SRTFlexNoteQuestionRelationWrapper>serviceTypeQuestionRelationList=new list<ServiceRequestAdminCntrl.SRTFlexNoteQuestionRelationWrapper>();
           
           serviceTypeQuestionRelationList.Add(SRTypeFlexNoteRel);
           
           
           string invokedFrmSRType=ApexPages.currentPage().getParameters().get('isInvokedFrmFNQuestion');
           string isEditMode=ApexPages.currentPage().getParameters().get('isEdit');
           string selSRTypeId=ApexPages.currentPage().getParameters().get('sRTypeId');
           system.assertEquals('True', invokedFrmSRType);
           system.assertEquals('true', isEditMode);
           system.assertEquals(srType.Id, selSRTypeId);
           
           
           controller.sRTFlexNoteRelation=SRTypeFlexNoteRel;
           
           
           controller.firstPage();
           controller.lastPage();
           controller.nextPage();
           controller.previousPage();
           
           controller.retriveObjectName(); 
           controller.serviceRequestToDeleteId=srType.Id;
           controller.doDeleteServiceRequestType();
           
           controller.doCancel();
           controller.doRelationSave();
           controller.doRelationPopCancel();
           
           
           
           controller.isEditMode=true;
           //controller.doCreateFlexNoteQuestions();  //11/10
           
           controller.filterStr='A';
           controller.doSearchByAlphabet();

           list<FlexNoteQuestion__c>fnQuestionsList=controller.getFlexNoteQuestions();
           
          // controller.doNewSRType();
           
           
           controller.selQuestionIds=SRTypeFlexNoteRel.flexNoteRelationList[0].flexNoteQuestion.Id+':'+SRTypeFlexNoteRel.flexNoteRelationList[0].sRFlexNoteRelation.Id;
           
           //.flexNoteRelationList[0].flexNoteQuestion.Id+':'+sRTypeFNRelation.flexNoteRelationList[0].sRFlexNoteRelation.Id;
           controller.addSelectedQuestions();
            
           
           // not needed to remove later
         //  controller.unSelQuestionIds=controller.selQuestionIds=SRTypeFlexNoteRel.flexNoteRelationList[0].flexNoteQuestion.Id;
          // controller.removeSelectedQuestion();
           
           controller.serviceTypeName=srType.Service_Name__c;
           controller.relationQuestion='Test Question';
           controller.flexNoteDataType='Text';
           
           
           
           controller.isShowPopUpRelation=true;
           controller.showPopUpRelation();
           
           controller.selectedSRTypeId=srType.id;
           controller.getSRTypesOptions();
           
           //controller.doUpdateSRType();
           controller.doUpdateServiceRequestType();
           
           controller.sRTFlexNoteRelation=SRTypeFlexNoteRel;
           
           
           
           
           
           
          // controller.doSaveSRType();
            controller.doSaveServiceRequestType();
           
           controller.sRTypeId=srType.id;
           controller.doCloneSRType();
           
           
           //controller.doSaveServiceRequestType();
           
    }
    
    
    
    public static testMethod void testSaveMethods(){
        // this as to move to helper class
        ServiceRequestType__c srTypeToSave=new ServiceRequestType__c(name='Test1',Object__c='Case',Service_Name__c='Abandon on Private Vechicle');
        //insert srTypeToSave;
        // creating data we have to move this to testhelper class
        FlexNoteQuestion__c fNQuestion=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='TestQuestion',Answer_Type__c='Text' ,name='Test');
        //insert fNQuestion;
        ServiceRequestTypeFlexNote__c sRTypeFNRelation=new ServiceRequestTypeFlexNote__c(Service_Request_Type__c=srTypeToSave.Id,FlexNote_Question__c=fnQuestion.Id,Order__c='1');
        //insert sRTypeFNRelation;
        //Use the PageReference Apex class to instantiate a page
           PageReference pageRef = Page.ServiceRequestAdminPge;
        //Instantiate and construct the controller class.   
           ServiceRequestAdminCntrl controller = new ServiceRequestAdminCntrl();
           
           // flex note question and relation wrap
           ServiceRequestAdminCntrl.FlexNoteQuestionRelationWrapper fNQuestionRelWrap=new ServiceRequestAdminCntrl.FlexNoteQuestionRelationWrapper(fNQuestion,sRTypeFNRelation);
           // service request flex note question and relation wrap
           ServiceRequestAdminCntrl.SRTFlexNoteQuestionRelationWrapper SRTypeFlexNoteRel=new ServiceRequestAdminCntrl.SRTFlexNoteQuestionRelationWrapper(srTypeToSave);
           SRTypeFlexNoteRel.flexNoteRelationList.add(fNQuestionRelWrap);
           
           
           controller.sRTFlexNoteRelation=SRTypeFlexNoteRel;
           
           
           // 20.09
           FlexNoteQuestion__c fN=fNQuestion;
           controller.flexNoteQuestion=fN;
           
           controller.showQuestionPopUp=true;
           controller.doCreateFlexNoteQuestion();
           
           
           system.debug('flexnote question--'+fN);
           controller.doCancelFlexNoteQuestion();
           //controller.conditionalRequired=true;
           controller.doConditionalRequiredRender();
           controller.doSaveFlexNoteQuestion();
           
           
         //  controller.doSaveSRType();
           controller.doSaveServiceRequestType();
           controller.sRTypeId=null;
           controller.doCloneSRType();
           controller.doNewSRType();
           
           controller.doDeleteServiceRequestType();
           //insert srTypeToSave ;
           //delete srTypeToSave;
           //controller.serviceRequestToDeleteId=srTypeToSave.Id;
           //controller.doDeleteServiceRequestType();
           
    }
    
    
     public static testMethod void testServiceAdminCntrl3(){
        
                // this as to move to helper class
        ServiceRequestType__c srTypeToSave=new ServiceRequestType__c(name='Test1',Object__c='Case',Service_Name__c='Abandon on Private Vechicle');
        insert srTypeToSave;
        // creating data we have to move this to testhelper class
        FlexNoteQuestion__c fNQuestion=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='TestQuestion',Answer_Type__c='Text' ,Name='Test');
        insert fNQuestion;
        ServiceRequestTypeFlexNote__c sRTypeFNRelation=new ServiceRequestTypeFlexNote__c(Service_Request_Type__c=srTypeToSave.Id,FlexNote_Question__c=fNQuestion.Id,Order__c='1');
        insert sRTypeFNRelation;
        
        //Use the PageReference Apex class to instantiate a page
           PageReference pageRef = Page.ServiceRequestAdminPge;
           
           ApexPages.currentPage().getParameters().put('isInvokedFrmFNQuestion', 'True');
           ApexPages.currentPage().getParameters().put('isEdit', 'false');
           ApexPages.currentPage().getParameters().put('sRTypeId', srTypeToSave.Id);
           
           
           string invokedFrmSRType=ApexPages.currentPage().getParameters().get('isInvokedFrmFNQuestion');
           string isEditMode=ApexPages.currentPage().getParameters().get('isEdit');
           string selSRTypeId=ApexPages.currentPage().getParameters().get('sRTypeId');
           
           
           
           system.assertEquals('True', invokedFrmSRType);
           system.assertEquals('false', isEditMode);
           system.assertEquals(selSRTypeId, srTypeToSave.Id);
           
           AddressValidationResponseWrapper aVRW= new AddressValidationResponseWrapper();
           
        //Instantiate and construct the controller class.   
          ServiceRequestAdminCntrl controller = new ServiceRequestAdminCntrl();
           controller.TotalNumber=10;
           controller.hasPreviousPage=false;
           controller.PageNum=10;
           controller.isClone=false;
            
           controller.filterStr='A';
           controller.doSearchByAlphabet();
         
         
           controller.showPopUp=false;
           
           // flex note question and relation wrap
           ServiceRequestAdminCntrl.FlexNoteQuestionRelationWrapper fNQuestionRelWrap=new ServiceRequestAdminCntrl.FlexNoteQuestionRelationWrapper(fNQuestion,sRTypeFNRelation);
           // service request flex note question and relation wrap
           ServiceRequestAdminCntrl.SRTFlexNoteQuestionRelationWrapper SRTypeFlexNoteRel=new ServiceRequestAdminCntrl.SRTFlexNoteQuestionRelationWrapper(srTypeToSave);
           SRTypeFlexNoteRel.flexNoteRelationList.add(fNQuestionRelWrap);
           
           
           controller.sRTFlexNoteRelation=SRTypeFlexNoteRel;
           
           controller.selQuestionIds=SRTypeFlexNoteRel.flexNoteRelationList[0].flexNoteQuestion.Id+':'+SRTypeFlexNoteRel.flexNoteRelationList[0].sRFlexNoteRelation.Id;
           
           //.flexNoteRelationList[0].flexNoteQuestion.Id+':'+sRTypeFNRelation.flexNoteRelationList[0].sRFlexNoteRelation.Id;
           controller.getFlexNoteQuestions();  
           
           controller.sRTypeId=srTypeToSave.Id;
           controller.doCloneSRType();
         
           
           controller.addSelectedQuestions();
           controller.flexNoteQuestionId=fNQuestion.Id;
           controller.isShowPopUpRelation=true;
           controller.showPopUpRelation();
           controller.doCreateFlexNoteQuestion();
           controller.doRelationSave();
           controller.doRelationPopCancel();
           controller.serviceRequestToDeleteId=srTypeToSave.Id;
           controller.doDeleteServiceRequestType();
           FlexNoteQuestion__c fNQ=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='TestQuestion',Answer_Type__c='Text' ,Name='Test');

         
           controller.flexNoteQuestion=fNQ;
           controller.doSaveFlexNoteQuestion();
           
         
           controller.doSaveServiceRequestType();
           controller.doCancel();
           controller.selectedSRTypeId=srTypeToSave.Id;
           controller.getSRTypesOptions();
           
           controller.sRTFlexNoteRelation=SRTypeFlexNoteRel;
           controller.doEditSRType();
          // controller.doUpdateServiceRequestType();
           
           
    }
    
    
    
    
}