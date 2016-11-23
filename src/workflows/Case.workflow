<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_SR_Creation_Email_Alert_DDOE_Bag_Law_bag_law_dc_gov</fullName>
        <ccEmails>yasmin.brown@dc.gov</ccEmails>
        <ccEmails>bag.law@dc.gov</ccEmails>
        <description>New SR Creation Email Alert - DDOE - Bag Law (bag.law@dc.gov)</description>
        <protected>false</protected>
        <senderAddress>311info@dc.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>OUC_SR_Main/Email_Notification_to_Agency_or_officer</template>
    </alerts>
    <alerts>
        <fullName>New_SR_Creation_Email_Alert_DDOE_Construction_Erosion_Runoff_iebscheduling_dc_go</fullName>
        <ccEmails>ieb.scheduling@dc.gov</ccEmails>
        <description>New SR Creation Email Alert - DDOE - Construction – Erosion Runoff (ieb.scheduling@dc.gov)</description>
        <protected>false</protected>
        <senderAddress>311info@dc.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>OUC_SR_Main/Email_Notification_to_Agency_or_officer</template>
    </alerts>
    <alerts>
        <fullName>New_SR_Creation_Email_Alert_DDS</fullName>
        <ccEmails>yasmin.brown@dc.gov</ccEmails>
        <ccEmails>dds.dutyofficer@dc.gov</ccEmails>
        <description>New SR Creation Email Alert - DDS (dds.dutyofficer@dc.gov)</description>
        <protected>false</protected>
        <senderAddress>311info@dc.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>OUC_SR_Main/Email_Notification_to_Agency_or_officer</template>
    </alerts>
    <alerts>
        <fullName>New_SR_Creation_Email_Alert_DOEE_Engine_Idling_engine_Idling_dc_gov</fullName>
        <ccEmails>engine.Idling@dc.gov</ccEmails>
        <description>New SR Creation Email Alert - DOEE - Engine Idling (engine.Idling@dc.gov)</description>
        <protected>false</protected>
        <senderAddress>311info@dc.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>OUC_SR_Main/Email_Notification_to_Agency_or_officer</template>
    </alerts>
    <alerts>
        <fullName>New_SR_Creation_Email_Alert_DOEE_General_Environmental_Concerns_DOEE_Emergency_d</fullName>
        <ccEmails>DOEE.Emergency@dc.gov</ccEmails>
        <ccEmails>yasmin.brown@dc.gov</ccEmails>
        <description>New SR Creation Email Alert - DOEE - General Environmental Concerns (DOEE.Emergency@dc.gov)</description>
        <protected>false</protected>
        <senderAddress>311info@dc.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>OUC_SR_Main/Email_Notification_to_Agency_or_officer</template>
    </alerts>
    <alerts>
        <fullName>New_SR_Creation_Email_Alert_DOEE_Nuisance_Odor_Complaints_nuisance_odor_dc_gov</fullName>
        <ccEmails>nuisance.odor@dc.gov</ccEmails>
        <description>New SR Creation Email Alert - DOEE - Nuisance Odor Complaints (nuisance.odor@dc.gov )</description>
        <protected>false</protected>
        <senderAddress>311info@dc.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>OUC_SR_Main/Email_Notification_to_Agency_or_officer</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_Alert</fullName>
        <description>Send Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>311info@dc.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>OUC_SR_Main/OUC_311_New_SR_Creation_Confirmation</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_On_Closure</fullName>
        <description>Send Email On Closure</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>311info@dc.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>OUC_SR_Main/SR_HTML_Closure_to_citizen</template>
    </alerts>
    <alerts>
        <fullName>Send_SR_Status_Update_Email</fullName>
        <description>Send SR Status Update Email</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>311info@dc.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>OUC_SR_Main/SR_Status_Update</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_contact_for_case_about_new_Case_Comment</fullName>
        <description>Send email to contact for case about new Case Comment</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>311info@dc.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>OUC_SR_Main/SR_HTML_Notify_Case_Comment_to_citizen</template>
    </alerts>
    <fieldUpdates>
        <fullName>SYSTEM_Clear_SR_Send_Update</fullName>
        <description>Clears flag on SR (Case) that indicates a citizen email event is needed</description>
        <field>Send_Update_Email_Flag__c</field>
        <name>SYSTEM: Clear SR Send Email Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_description</fullName>
        <field>Reason</field>
        <literalValue>6- Pended, item outside current budget</literalValue>
        <name>Update description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Case%3A Notify Customer about new comment</fullName>
        <actions>
            <name>Send_email_to_contact_for_case_about_new_Case_Comment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This will send an email to the Case contact to inform them of a new Case Comment.</description>
        <formula>AND(!ISBLANK(Last_Case_Comment_Added__c),  ISCHANGED(Last_Case_Comment_Added__c ), SR_Status__c != &apos;Closed&apos;, SR_Status__c != &apos;Duplicate (Closed)&apos;, SR_Status__c != &apos;Voided&apos;, SR_Status__c != &apos;Closed - Incomplete Information&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email Alert for DDS - SR Created</fullName>
        <actions>
            <name>New_SR_Creation_Email_Alert_DDS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Servicing_Agency__c</field>
            <operation>equals</operation>
            <value>DDS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.LegacyID__c</field>
            <operation>notContain</operation>
            <value>CSR-</value>
        </criteriaItems>
        <description>Send email alert to dutyofficer@dc.gov for new SR creation for DDS</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New SR Creation Email Alert - DDOE - Bag Law</fullName>
        <actions>
            <name>New_SR_Creation_Email_Alert_DDOE_Bag_Law_bag_law_dc_gov</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Service_Request_Name__c</field>
            <operation>equals</operation>
            <value>DDOE - Bag Law Tips; DOEE - Ban on Foam Food Containers</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.LegacyID__c</field>
            <operation>notContain</operation>
            <value>CSR-</value>
        </criteriaItems>
        <description>New SR Creation Email Alert - DDOE - Bag Law (bag.law@dc.gov)</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New SR Creation Email Alert - DDOE - Construction %E2%80%93 Erosion Runoff</fullName>
        <actions>
            <name>New_SR_Creation_Email_Alert_DDOE_Construction_Erosion_Runoff_iebscheduling_dc_go</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Service_Request_Name__c</field>
            <operation>equals</operation>
            <value>DDOE - Construction – Erosion Runoff,DOEE - Construction – Erosion Runoff</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.LegacyID__c</field>
            <operation>notContain</operation>
            <value>CSR-</value>
        </criteriaItems>
        <description>New SR Creation Email Alert - DDOE - Construction – Erosion Runoff (ieb.scheduling@dc.gov)</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New SR Creation Email Alert - DOEE - Engine Idling</fullName>
        <actions>
            <name>New_SR_Creation_Email_Alert_DOEE_Engine_Idling_engine_Idling_dc_gov</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Service_Request_Name__c</field>
            <operation>equals</operation>
            <value>DOEE - Engine Idling Tips</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.LegacyID__c</field>
            <operation>notContain</operation>
            <value>CSR-</value>
        </criteriaItems>
        <description>New SR Creation Email Alert - DOEE - Engine Idling (engine.Idling@dc.gov)</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New SR Creation Email Alert - DOEE - General Environmental Concerns</fullName>
        <actions>
            <name>New_SR_Creation_Email_Alert_DOEE_General_Environmental_Concerns_DOEE_Emergency_d</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Service_Request_Name__c</field>
            <operation>equals</operation>
            <value>DOEE - General Environmental Concerns</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.LegacyID__c</field>
            <operation>notContain</operation>
            <value>CSR-</value>
        </criteriaItems>
        <description>New SR Creation Email Alert - DOEE - General Environmental Concerns</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New SR Creation Email Alert - DOEE - Nuisance Odor Complaints</fullName>
        <actions>
            <name>New_SR_Creation_Email_Alert_DOEE_Nuisance_Odor_Complaints_nuisance_odor_dc_gov</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Service_Request_Name__c</field>
            <operation>equals</operation>
            <value>DOEE - Nuisance Odor Complaints</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.LegacyID__c</field>
            <operation>notContain</operation>
            <value>CSR-</value>
        </criteriaItems>
        <description>New SR Creation Email Alert - DOEE - Nuisance Odor Complaints</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SYSTEM%3A CASE Email on Closure</fullName>
        <actions>
            <name>Send_Email_On_Closure</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Send_Email_On_SR_Closed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.LegacyID__c</field>
            <operation>notContain</operation>
            <value>CSR-</value>
        </criteriaItems>
        <description>Send email on Case Closure</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SYSTEM%3A CASE Email on Create</fullName>
        <actions>
            <name>Send_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Send_Email_On_SR_Creation__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.LegacyID__c</field>
            <operation>notContain</operation>
            <value>CSR-</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Service_Request_Name__c</field>
            <operation>notEqual</operation>
            <value>Bulk Collection</value>
        </criteriaItems>
        <description>To send the email alerts on case create</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SYSTEM%3A SR - Send Citizen Email Update</fullName>
        <actions>
            <name>Send_SR_Status_Update_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SYSTEM_Clear_SR_Send_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Send_Update_Email_Flag__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Service request to be visible in calendar</fullName>
        <actions>
            <name>Update_description</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Service_Request_Number__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Ability to view all SR&apos;s in calendar</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
