<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SR_Open_Inspection_Complete</fullName>
        <description>SR Open Inspection Complete</description>
        <protected>false</protected>
        <recipients>
            <field>SR_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>311info@dc.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>OUC_SR_Main/SR_HTML_Open_Inspection_Complete</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_on_Complete</fullName>
        <description>Send Email on SR Activity Completion</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Name__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>311info@dc.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>OUC_SR_Main/SR_HTML_Activity_SR_Closure_Notice_to_Citizen</template>
    </alerts>
    <fieldUpdates>
        <fullName>SR_Contact_Email</fullName>
        <field>SR_Contact_Email__c</field>
        <formula>Contact_Email__c</formula>
        <name>SR Contact Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SR_Status</fullName>
        <field>SR_Case_Status__c</field>
        <formula>SR_Status__c</formula>
        <name>SR Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TESTActivity</fullName>
        <field>External_Comments__c</field>
        <name>TESTActivity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SR_Email</fullName>
        <field>Email__c</field>
        <formula>Contact_Email__c</formula>
        <name>Update SR Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>SR Activity Inspection Complete Email</fullName>
        <actions>
            <name>SR_Open_Inspection_Complete</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SR_Contact_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>OUC_Activity__c.Final_Task_Short_Name__c</field>
            <operation>equals</operation>
            <value>Inspection</value>
        </criteriaItems>
        <criteriaItems>
            <field>OUC_Activity__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>OUC_Activity__c.External_Comments__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>OUC_Activity__c.Completion_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>OUC_Activity__c.Citizen_Email_On_Complete__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Agency has completed an initial inspection on the service request, and has a better sense of the work that will need to be completed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SYSTEM%3A OUCAct%3A Email on complete</fullName>
        <actions>
            <name>Send_Email_on_Complete</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>OUC_Activity__c.External_Comments__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>OUC_Activity__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>OUC_Activity__c.Citizen_Email_On_Complete__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>To send the Email Alert on Service request- complete</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
