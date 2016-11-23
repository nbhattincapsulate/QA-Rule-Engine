@IsTest
public class FlexNoteQuestionAdminCntrlTest {
	public static testMethod void testFlexNoteQuestionCntrl(){
       //Use the PageReference Apex class to instantiate a page
       PageReference pageRef = Page.FlexNoteQuestionAdminPge;
       
       //In this case, the Visualforce page named 'FlexNoteQuestionAdminPge' is the starting point of this test method. 
       Test.setCurrentPage(pageRef);
       ApexPages.currentPage().getParameters().put('isInvokedFrmSRType', 'True');
       
       
       //Instantiate and construct the controller class.   
       FlexNoteQuestionAdminCntrl controller = new FlexNoteQuestionAdminCntrl();
       controller.firstPage();
       //boolean hasNextPge=controller.hasNextPage();
       controller.doCancelFlexNoteQuestion();
       //boolean previousPage=controller.hasPreviousPage();
       
       controller.lastPage();
       
       controller.nextPage();
       controller.previousPage();
       controller.doCreateFlexNoteQuestion();
       
       FlexNoteQuestion__c fNQuestion=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='TestQuestion',Answer_Type__c='Text' ,Name='Test');
       insert fnQuestion;
      
       /*FlexNoteQuestion__c tempflexNoteQuestion=[select id,Name,Question__c,Answer_Type__c,Answer_Values__c,Hint_Text__c,List__c,
        Access_Classification__c,Start_Date__c,Stop_Date__c,Object_Name__c from FlexNoteQuestion__c where id=:fNQuestion.id];*/
       string invokedFrmSRType=ApexPages.currentPage().getParameters().get('isInvokedFrmSRType');
       system.assertEquals('True', invokedFrmSRType);
       
       controller.flexNoteQuestionId=fnQuestion.Id;
       controller.flexNoteQuestion=fnQuestion;
       
       controller.doEditFlexNoteQuestion();
       controller.doUpdateFlexNoteQuestion();
       
       controller.flexNoteQuestionId=fnQuestion.Id;
       controller.doDeleteFlexNoteQuestion();
       FlexNoteQuestion__c fNQuestion1=new FlexNoteQuestion__c(Object_Name__c='Case',Questions__c='TestQuestion',Answer_Type__c='Text' ,Name='Test1');
       controller.flexNoteQuestion=fNQuestion1;
       controller.doSaveFlexNoteQuestion();
       
       controller.conditionalRequired=false;
       controller.doConditionalRequiredRender();
       
	}
	
	
	
	public static testMethod void testNegativeValues(){
       //Use the PageReference Apex class to instantiate a page
       PageReference pageRef = Page.FlexNoteQuestionAdminPge;
       
       //In this case, the Visualforce page named 'FlexNoteQuestionAdminPge' is the starting point of this test method. 
       Test.setCurrentPage(pageRef);
       ApexPages.currentPage().getParameters().put('isInvokedFrmSRType', 'True');
       
       
       //Instantiate and construct the controller class.   
       FlexNoteQuestionAdminCntrl controller = new FlexNoteQuestionAdminCntrl();
       controller.firstPage();
       //boolean hasNextPge=controller.hasNextPage();
       controller.doCancelFlexNoteQuestion();
       //boolean previousPage=controller.hasPreviousPage();
       
       controller.lastPage();
       
       controller.nextPage();
       controller.previousPage();
       controller.doCreateFlexNoteQuestion();
       
        // creating data we have to move this to testhelper class
       FlexNoteQuestion__c fNQuestion=new FlexNoteQuestion__c(Object_Name__c='',Questions__c='',Answer_Type__c='Picklist', Name='TEST2' ,AnswerValues__c=Null);
       insert fnQuestion;
       
      
       /*FlexNoteQuestion__c tempflexNoteQuestion=[select id,Name,Question__c,Answer_Type__c,Answer_Values__c,Hint_Text__c,List__c,
        Access_Classification__c,Start_Date__c,Stop_Date__c,Object_Name__c from FlexNoteQuestion__c where id=:fNQuestion.id];*/
       
       string invokedFrmSRType=ApexPages.currentPage().getParameters().get('isInvokedFrmSRType');
       
       system.assertEquals('True', invokedFrmSRType);
       
       
       controller.showPopUp=true;
       controller.isEditMode=false;
       controller.doSaveFlexNoteQuestion();
       controller.conditionalRequired=true;
       controller.doConditionalRequiredRender();
       
       controller.isEditMode=true;
       controller.flexNoteQuestionId=fnQuestion.Id;
       controller.doEditFlexNoteQuestion(); 
       controller.doUpdateFlexNoteQuestion();
    
       controller.doDeleteFlexNoteQuestion();
       controller.filterStr='A';
       controller.doSearchByAlphabet();
	}
	
	
}