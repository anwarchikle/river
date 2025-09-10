@isTest
public class batchForLeadTest {
    @isTest
    static void testBatchForLeadTest() {
        Group queue = new Group(  Name = 'Head_Quarter', Type = 'Queue' );
        insert queue;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tusr',
            Email = 'testuser@example.com',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert u;

        Assignment_Group__c ag = new Assignment_Group__c(
            Name__c = 'Head_Quarter',
            isActive__c = true,
            Business_Hours_Morning__c = Time.newInstance(9, 0, 0, 0),
            Business_Hours_End_Time__c = Time.newInstance(18, 0, 0, 0),
            Last_Allocated_RRid__c = 0
        );
        insert ag;

        Assignment_Group_Member__c agm = new Assignment_Group_Member__c(
            Assignment_Group__c = ag.Id,
            Active__c = true,
            Assignment_Id__c = 1,
            Max_Case_Per_Day__c = 5,
            Group_Member__c = u.Id
        );
        insert agm;
        Account testAccount = UtilityTestClass.createTestAccount('Test Account', 'C001', 'Test Store', '10001', 'Dealer');

        City__c city = new City__c(Name = 'Test City');
        insert city;

        Pin_Code__c pin = new Pin_Code__c( Area_Pincode__c = '123456', Dealer_Service_Center__c = testAccount.Id, City__c = city.Id);
        insert pin;

        Lead testLead =UtilityTestClass.createTestLead('OOB Lead 1', 'Test Co', 'New', '9900009999', '100021', 'Telephone', 'Telephone');

        Database.executeBatch(new batchForLead(), 100);

    }
}