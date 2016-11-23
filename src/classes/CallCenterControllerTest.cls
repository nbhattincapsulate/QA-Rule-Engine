@isTest 
public class CallCenterControllerTest { 

  public static testMethod void testCallCenterController() {
    CallCenterController ctrl = new CallCenterController();

    List<CallCenter> numOfCallCenters = [Select Id From CallCenter];

    System.assertNotEquals(null, ctrl.callcenters);

    Integer userCCAddition = (ctrl.currentCallCenter != null ? 1 : 0);
    System.assertEquals(numOfCallCenters.size(), ctrl.callcenters.size() + userCCAddition);

    String currentCallCenterId;

    if (numOfCallCenters.size() == 0) {
      System.assertEquals(null, ctrl.currentCallCenter);
      ctrl.newCallCenterId = null;
    } else {
      //System.assertNotEquals(null, ctrl.currentCallCenter);
      //currentCallCenterId = ctrl.currentCallCenter.Id;
      //ctrl.newCallCenterId = ctrl.callcenters.get(0).Id;
    }
    //ctrl.changeCallCenter();
    //System.assertNotEquals(currentCallCenterId, ctrl.currentCallCenter.Id);
  }
}