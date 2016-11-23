/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global abstract class BaseAddressLookupExtension {
    global IncapsulateDCM__DcMarConfig__c config {
        get;
        set;
    }
    global IncapsulateDCM.BaseAddressLookupExtension ctrl {
        get;
        set;
    }
    global IncapsulateDCM.DcMarLocation selectedLocation {
        get;
        set;
    }
    global ApexPages.StandardController stdCtrl {
        get;
        set;
    }
    global BaseAddressLookupExtension() {

    }
    global void cancelAddressSelect() {

    }
    global abstract String getObjectId();
    global abstract String getObjectName();
    global System.PageReference onAddressConfirmed() {
        return null;
    }
    global void updateObjectAddressField(String fieldName, SObject obj) {

    }
}
