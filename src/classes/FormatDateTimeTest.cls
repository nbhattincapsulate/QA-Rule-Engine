@isTest
public class FormatDateTimeTest {
  public static testMethod void testGetTimeZoneValue() {
    FormatDateTime ctrl = new FormatDateTime();
    DateTime dt = System.Now();
    ctrl.dateTimeValue = dt;
    ctrl.getTimeZoneValue();
    ctrl.dateTimeValue = null;
    System.assertEquals(' ', ctrl.getTimeZoneValue());
  }
    
  public static testMethod void testIsDST() {
    FormatDateTime ctrl = new FormatDateTime();
    DateTime dtSavingsTime = DateTime.parse('4/4/2015 12:00 AM');      
    DateTime dtNotSavingsTime = DateTime.parse('12/12/2015 12:00 AM');

    System.assert(ctrl.isDST(dtSavingsTime));
    System.assert(!ctrl.isDST(dtNotSavingsTime));
  }
}