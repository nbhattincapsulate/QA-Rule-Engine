public class CallCenterController {

  public User currentUser { get; Set; }
  public CallCenter currentCallCenter { get; set; }
  public List<CallCenter> callcenters { get; set; }
  public String newCallCenterId { get; set; }

  public CallCenterController() {
    currentUser = [Select Id, Name, CallCenterId From User Where Id = :UserInfo.getUserId() Limit 1];
    refreshCallCenter();
  }

  public PageReference changeCallCenter() {
    System.debug('----> New Call Centre Id: ' + newCallCenterId);
    // Update the users call centre.
    currentUser.CallCenterId = newCallCenterId;
    // NOTE: We currently cannot create Call Centers through DML. Due to this limitation if no call centers are available on an org we can't attempt to update.
    update currentUser;
    // Call a refresh on the current call centre data.
    refreshCallCenter();
    return null;
  }

  private void refreshCallCenter() {
    callcenters = new List<CallCenter>();

    try {
      if (currentUser.CallCenterId != null) {
        currentCallCenter = [Select Id, Name, InternalName From CallCenter Where Id = :currentUser.CallCenterId Limit 1];
      }
      String query = 'Select Id, Name, InternalName From CallCenter ';
      if (currentCallCenter != null) {
        query += ' Where Id != \'' + currentCallCenter.Id + '\'';
      }
      callcenters = Database.query(query);
    } catch(Exception e) {
      System.debug('----> Error: ' + e.getMessage());
    }
  }
}