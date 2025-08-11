@IsTest(seeAllData=true)
public class TestDriveTriggerHandlerTest {  

    @isTest
    public static void testDriveClass(){
        
        Lead objLead = new Lead( FirstName = 'Test', LastName = 'Sample', Company = 'Testing Sample Co',PostalCode = '560068',LeadSource='Telephone',Secondary_Sources__c ='Telephone',Phone='9876543210' );  
        insert objLead;  

        List<Test_Drive__c> listOftestDrive = new List<Test_Drive__c>();
        Map<Id,Test_Drive__c> mapOftestDrive = new Map<Id,Test_Drive__c>();
        Test_Drive__c testDrive1 = new Test_Drive__c(Name='Drive 1', Lead__c = objLead.Id, Ride_Type__c= 'HTR',Test_Ride_Date__c=System.Now(),Test_Drive_Status__c = 'New',
                                                     Address__Street__s = 'ABCD',Address__City__s = 'HIJK',Address__PostalCode__s = '560068',Address__StateCode__s = 'KA');
        Insert testDrive1;
        listOftestDrive.add(testDrive1);
        
        testDrive1.Test_Drive_Status__c = 'Scheduled';
        update testDrive1;
        mapOftestDrive.put(testDrive1.Id,testDrive1);
        
        
        Lead objLead1 = new Lead( FirstName = 'Test', LastName = 'Sample', Company = 'Testing Sample Co',PostalCode = '560068',LeadSource='Online',Secondary_Sources__c ='River Website',Phone='9876823210',Instore_Test_drive__c =true);  
        insert objLead1;  

        List<Test_Drive__c> listOftestDrive1 = new List<Test_Drive__c>();
        Map<Id,Test_Drive__c> mapOftestDrive1 = new Map<Id,Test_Drive__c>();
        Test_Drive__c testDrive2 = new Test_Drive__c(Name='Drive 1', Lead__c = objLead1.Id, Ride_Type__c= 'STR',Test_Ride_Date__c=System.Now(),Test_Drive_Status__c = 'New',
                                                     Address__Street__s = 'ABCD',Address__City__s = 'HIJK',Address__PostalCode__s = '560068',Address__StateCode__s = 'KA');
        Insert testDrive2;
        listOftestDrive.add(testDrive2);
        
        testDrive2.Test_Drive_Status__c = 'Completed';
        update testDrive2;
        mapOftestDrive.put(testDrive2.Id,testDrive2);

        Database.LeadConvert lc = new database.LeadConvert();  
        lc.setLeadId( objLead1.Id );  
        lc.setDoNotCreateOpportunity( false );  
        lc.setConvertedStatus( 'Converted' );  
        
        Database.LeadConvertResult lcr = Database.convertLead(lc, false);  
        
        //TestDriveTriggerHandler.updateTestDriveStatus(testDrive2.Id,'Canceled','Not Interested / Not Serious Casual enquiry','Customer not enquired','NA');
        
    }
    
}