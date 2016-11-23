public class FormatDateTime {
  public DateTime dateTimeValue { get; set; }
    
  public String getTimeZoneValue() {
    if( dateTimeValue != null ) { 
      String timezone = (isDST(dateTimeValue) ? 'EDT' : 'EST');
      String localeFormatDT = dateTimeValue.format('MMM dd, yyyy h:mm:ss a', 'America/New_York');
      return localeFormatDT;
    }
    return ' ';
  }
    
  public Boolean isDST(datetime dtDateTime) {
    date dtDate = dtDateTime.Date();
    date dtWeekStart = dtDate.toStartofWeek();
    integer yy = dtDateTime.Year();
     
    if (dtWeekStart >=(date.newInstance(yy,03,08)) && dtWeekStart <= (date.newInstance(yy,11,01))) {
      return true;
    } else {
      return false;
    }
  }
}