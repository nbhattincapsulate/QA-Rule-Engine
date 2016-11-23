public class ServiceReportsExtension {
    private final Case c;
	private final List<Case> selectedCases;
    
    public ServiceReportsExtension(ApexPages.StandardController controller) {
        controller.addFields(new List<String> {'Id'});
        this.c = (Case) controller.getRecord();
    }
    
    public ApexPages.StandardSetController caseRecords {
        get {
            if (caseRecords == null) {
                return new ApexPages.StandardSetController(Database.getQueryLocator(
                  [Select Id From Case]
                ));
            }
            return caseRecords;
        }
        private set;
    }
}