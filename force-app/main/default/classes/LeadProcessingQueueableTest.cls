@isTest(seeAlldata=true)
private class LeadProcessingQueueableTest {
    @isTest
    static void testLeadProcessingQueueable() {
        List<UserRole> UserRoleType = [Select Id,Name from UserRole  Where PortalType ='Partner' LIMIT 1 ];
        List<User> userList = [SELECT Id FROM User Where UserRoleId =: UserRoleType[0].Id AND isActive = true AND contactId != null];
        Id UserId = userList[0].Id;
        
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 3; i++) {
            leads.add(UtilityTestClass.createTestLead('Test Lead'+i, 'Test Company'+i,'New','903524442'+i,'560076','Telephone', 'Telephone'));
        }
        
        List<Id> leadIds = new List<Id>();
        for (Lead l : leads) {
            leadIds.add(l.Id);
        }
        
        Assignment_Group__c AssiGroup = new Assignment_Group__c(
            Name__c = 'Out of Business Hours',
            isActive__c = true,
            Business_Hours_Morning__c = Time.newInstance(1, 0, 0, 0),
            Business_Hours_End_Time__c = Time.newInstance(23, 0, 0, 0),
            Last_Allocated_RRid__c = 0
        );
        insert AssiGroup;
        
        Assignment_Group_Member__c member = new Assignment_Group_Member__c(
            Assignment_Group__c = AssiGroup.Id,
            Group_Member__c = userList[0].Id,
            Active__c = true,
            Assignment_Id__c = 1
        );
        insert member;
        
        Group hqQueue = new Group(DeveloperName = 'Head_Quarter1', Name = 'HQ Queue', Type = 'Queue');
        Group oobQueue = new Group(DeveloperName = 'Out_of_Business_Hours1', Name = 'OOB Queue', Type = 'Queue');
        insert new List<Group>{ hqQueue, oobQueue };
                
        Account acc = UtilityTestClass.createTestAccount('Partner Store', 'D001', 'Demo Partner Store','560076', 'Dealer');
        
        City__c city = new City__c(Name = 'Test City');
        insert city;
        
        Pin_Code__c pincode = new Pin_Code__c(
            Area_Pincode__c = '560076',
            Dealer_Service_Center__c = acc.Id,
            City__c = city.Id
        );
        insert pincode;
        
        Lead ld1 = UtilityTestClass.createTestLead('OOB Lead 1', 'Test Co', 'New', '9999999999', '560076', 'Telephone', 'Telephone');
        ld1.Dealer_Allocation__c = true;
        update ld1;
        
        Lead ld2 = UtilityTestClass.createTestLead('OOB Lead 2', 'Test Co', 'New', '9999999998', '560076', 'Telephone', 'Telephone');
        ld2.Dealer_Allocation__c = false;
        update ld2;
        
        AssiGroup.Business_Hours_Morning__c = Time.newInstance(9, 0, 0, 0);
        AssiGroup.Business_Hours_End_Time__c = Time.newInstance(17, 0, 0, 0);
        update AssiGroup;
        
        LeadProcessingQueueable job1 = new LeadProcessingQueueable(leadIds, userList[0].Id);
        LeadProcessingQueueable job2 = new LeadProcessingQueueable(leadIds, userList[0].Id);
        LeadProcessingQueueable job3 = new LeadProcessingQueueable(new List<Id>{ld1.Id, ld2.Id}, userList[0].Id);
        
        System.runAs(userList[0]) {
            System.enqueueJob(job1);
            System.enqueueJob(job2);
            System.enqueueJob(job3);
        }
        
    }
}