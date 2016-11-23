/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Loggly {
    global static Boolean BATCH_LOGS {
        get;
        set;
    }
    global static Incapsulate_Log.Loggly.LogCache cache;
    global static String DATE_FORMAT;
    global static String DEFAULT_LEVEL;
    global static String DEFAULT_SETTING_NAME;
    global static String EXCEPTION_LEVEL;
    global static String EXCEPTION_STACK_TRACE;
    global static String EXCEPTION_TYPE_NAME;
    global static String HOSTNAME {
        get;
    }
    global static Boolean INCLUDE_HOSTNAME {
        get;
    }
    global static Boolean INCLUDE_USERINFO {
        get;
    }
    global static String KEY_DATETIME;
    global static String KEY_HOST;
    global static String KEY_LEVEL;
    global static String KEY_MESSAGE;
    global static String KEY_USERID;
    global static String KEY_USERNAME;
    global static String LOGGLY_ENDPOINT {
        get;
    }
    global static String SETTING_NAME {
        get;
        set;
    }
    global static Incapsulate_Log__LogglySettings__c SETTINGS {
        get;
    }
    global static Boolean TEST_NOCACHE;
    global static Boolean THROW_TEST_EXCEPTION {
        get;
        set;
    }
    global Loggly() {

    }
    global void add(String logValue, Datetime logDate) {

    }
    global void add(String logValue, Datetime logDate, String logLevel) {

    }
    global void add(String logValue, Datetime logDate, String logLevel, Map<String,String> additionalValues) {

    }
    global void flush() {

    }
    global static String gifUrl(String logValue, Datetime logDate) {
        return null;
    }
    global static String gifUrl(String logValue, Datetime logDate, String logLevel) {
        return null;
    }
    global static String gifUrl(String logValue, Datetime logDate, String logLevel, Map<String,String> additionalValues) {
        return null;
    }
    @Future(callout=true)
    global static void sendLogs(Set<String> logs) {

    }
    global static void singleLog(Exception except) {

    }
    global static void singleLog(String logValue) {

    }
    global static void singleLog(String logValue, Datetime logDate) {

    }
    global static void singleLog(Exception except, Datetime logDate, String logLevel) {

    }
    global static void singleLog(String logValue, Datetime logDate, Incapsulate_Log.Loggly.LogCache logCache) {

    }
    global static void singleLog(String logValue, Datetime logDate, String logLevel) {

    }
    global static void singleLog(String logValue, Datetime logDate, String logLevel, Incapsulate_Log.Loggly.LogCache logCache) {

    }
    global static void singleLog(String logValue, Datetime logDate, String logLevel, Map<String,String> additionalValues) {

    }
    global static void singleLog(String logValue, Datetime logDate, String logLevel, Map<String,String> additionalValues, Incapsulate_Log.Loggly.LogCache logCache) {

    }
global class Log {
}
global class LogCache {
}
global class TestException extends Exception {
}
}
