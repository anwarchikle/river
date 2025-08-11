@isTest(seealldata = true)	
public class CSVUploadQueueableTest {
    @isTest
    static void testCSVUploadQueueableBasic() {        
        User usr = UtilityTestClass.createSalesManagerUser1();
        
        List<String> csvRows = new List<String>{ 'lastname,Phone', 'Test Account 1,1234567890', 'Test Account 2,9876543210' };
            
            Map<String, String> fieldMapping = new Map<String, String>{ 'Name' => 'Name',  'Phone' => 'Phone' };
                List<lead> leads = new List<Lead>();
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Contact> conList = new List<Contact>();
        String commonPhone = '9876543210';
        String commonPhone1 = '9876543211';
        
        Lead testLead1 = UtilityTestClass.createTestLead('Test Lead0', 'Test Company0', 'New', commonPhone, '560076', 'Online', 'Google');
        Lead testLead2 = UtilityTestClass.createTestLead('Test Lead1', 'Test Company1', 'New', commonPhone1, '560076', 'Online', 'Google');
        //Lead testLead3 = UtilityTestClass.createTestLead('Test Lead1', 'Test Company1', 'New', commonPhone1, '560076', 'Online', 'Google');
        leads.addAll(new List<Lead>{ testLead1, testLead2 });
        
        Account acc1 = UtilityTestClass.createTestAccount('Partner Store0', 'D0010', 'Demo Partner Store0', '560070', 'Dealer');
        Account acc2 = UtilityTestClass.createTestAccount('Partner Store1', 'D0011', 'Demo Partner Store1', '560071', 'Dealer');
        Account acc3 = UtilityTestClass.createTestAccount('Partner Store1', 'D0011', 'Demo Partner Store1', '560071', 'Dealer');
        acc1.Phone = commonPhone;
        acc2.Phone = commonPhone1;
        update new List<Account>{ acc1, acc2 };
            accList.addAll(new List<Account>{ acc1, acc2 });
        
        Opportunity opp1 = UtilityTestClass.createTestOpportunity('Opp Test0', acc1.Id, 'RNR', Date.today(), 15000);
        Opportunity opp2 = UtilityTestClass.createTestOpportunity('Opp Test1', acc2.Id, 'RNR', Date.today().addDays(1), 15000);
        Opportunity opp3 = UtilityTestClass.createTestOpportunity('Opp Test1', acc3.Id, 'RNR', Date.today().addDays(1), 15000);
        
        
        opp1.Phone__c = commonPhone;
        opp2.Phone__c = commonPhone1;
        opp3.StageName = 'Drop Out';
        opp3.Drop_Out_Reasons__c = 'Not Interested / Not Serious Casual enquiry';
        opp3.Drop_Out_Sub_Reasons__c = 'RNR';
        update new List<Opportunity>{ opp1, opp2 };
            oppList.addAll(new List<Opportunity>{ opp1, opp2 });
        
        Test_Drive__c testDrive1 = UtilityTestClass.createTest1Driver('Test Drive Existing0', opp1.Id, 'new');
        Test_Drive__c testDrive2 = UtilityTestClass.createTest1Driver('Test Drive Existing1', opp2.Id, 'new');
        
        Contact con1 = UtilityTestClass.createTestContact('Partner0', 'Manager0', 'partner.manager@example.com', commonPhone, acc1.Id, 'Sales');
        Contact con2 = UtilityTestClass.createTestContact('Partner1', 'Manager1', 'partner.manager@example.com', commonPhone1, acc2.Id, 'Sales');
        conList.addAll(new List<Contact>{ con1, con2 });
        
        
        CSVUploadQueueable job = new CSVUploadQueueable(Usr.Id,'Account', fieldMapping, csvRows);
        CSVUploadQueueable job1 = new CSVUploadQueueable(Usr.Id,'Lead', fieldMapping, csvRows);
        CSVUploadQueueable job2 = new CSVUploadQueueable(Usr.Id,'Opportunity', fieldMapping, csvRows);
        System.runAs(usr) {
            System.enqueueJob(job);
            System.enqueueJob(job1);
            System.enqueueJob(job2);
            job.processLeadsWithAccountCheckHQInsert(leads); 
            job.mapOpportunityFields(accList[0], conList[0], oppList[0], 'name', 'Test Name');
            job.mapOpportunityFields(accList[0], conList[0], oppList[0], 'phone__c', '1234567890');
            job.mapOpportunityFields(accList[0], conList[0], oppList[0], 'closedate', '2025-08-01');
            
            job.mapOpportunityFields(accList[0], conList[0], oppList[0], 'Enquiry_Source__c', 'Telephone');
            job.mapOpportunityFields(accList[0], conList[0], oppList[0], 'enquiry_primary_source__c', 'Telephone');
            job.mapOpportunityFields(accList[0], conList[0], oppList[0], 'secondary_sources__c', 'Telephone');
            job.mapLeadFields(leads[0], 'LastName', 'Test');
            job.processOpportunitiesWithAccountCheckDMSInsert(accList, conList, oppList);
            
        }        
    }
    
    
}