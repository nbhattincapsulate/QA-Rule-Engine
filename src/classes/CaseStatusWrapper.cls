public class CaseStatusWrapper {
  public String saveStatus { get; set; }
  public String srNumber { get; set; }
  public String comments { get; set; }

  public CaseStatusWrapper(String srNumber, String comments, String saveStatus) {
    this.srNumber = srNumber;
    this.comments = comments;
    this.saveStatus = saveStatus;
  }
}