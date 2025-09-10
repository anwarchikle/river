@isTest
public class UserTrackingcontrollerTest {
    static testMethod void testOnpageLoad_CheckinExists_CheckoutNull() {
        User testUser = UtilityTestClass1.createSalesManagerUser1();
        User_Tracking__c ut = new User_Tracking__c( Member__c = testUser.Id,  Checkin_Datetime__c = DateTime.now()  );
        insert ut;
        UserTrackingcontroller.OnpageLoad(testUser.Id);
    }
    
    static testMethod void testOnpageLoad() {
        User testUser = UtilityTestClass1.createSalesManagerUser1();
        UserTrackingcontroller.OnpageLoad(testUser.Id);
        UserTrackingcontroller.UserCheckout(testUser.Id);
    }
    
    static testMethod void testUserCheckin_NewCheckin() {
        User testUser = UtilityTestClass1.createSalesManagerUser1();
        Group leadQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Head_Quarter' LIMIT 1];
        Assignment_Group__c aGroup = new Assignment_Group__c(
            Name = 'Testing',
            Supported_Sobject__c = 'Lead',
            Round_Robin_Queue_Name__c = 'Head_Quarter',
            Max_Sobject_Assignment_Count__c = 9999,
            Max_Lead_Per_Day__c = 50,
            Case_to_Assign_in_Single_Transaction__c = 999999,
            Case_Stage_Exceed_Count__c = 999999,
            Minimum_Case_Volume__c = 999999,
            Last_Allocated_RRid__c = 0,
            Execution_SOQL__c = 'SELECT Id, Name, OwnerId FROM Lead WHERE Status IN (\'New\',\'Test Ride\') AND Future_Lead__c = false',
            isActive__c = true
        ); 
        insert aGroup;
        
        Assignment_Group_Member__c agm = new Assignment_Group_Member__c(
            Group_Member__c = testUser.Id,
            Out_Of_Office__c = true,
            Active__c = true,
            Assignment_Id__c = 1,
            Max_Case_Per_Day__c = 50,
            Assignment_Group__c = aGroup.Id
        );
        insert agm;
        
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) { 
            testLeads.add(new Lead( LastName = 'Test No Conversion'+i, Company = 'Test Company', Status = 'New', Phone = '900924445'+i,  PostalCode = '123456', LeadSource = 'Online',  Secondary_Sources__c = 'Google'));
        }
        insert testLeads; 
        UserTrackingcontroller.UserTrackWrapperAfterCheckin result = UserTrackingcontroller.UserCheckin(testUser.Id);
    }
    
    static testMethod void testUserCheckin_AlreadyCheckedIn() {
        User testUser = UtilityTestClass1.createSalesManagerUser1(); 
        insert new User_Tracking__c(
            Member__c = testUser.Id,
            Checkin_Datetime__c = DateTime.now()
        );
        UserTrackingcontroller.UserTrackWrapperAfterCheckin result = UserTrackingcontroller.UserCheckin(testUser.Id);
    }
    
    static testMethod void testUserCheckout() {
        User testUser = UtilityTestClass1.createSalesManagerUser1();
        insert new User_Tracking__c(
            Member__c = testUser.Id,
            Checkin_Datetime__c = DateTime.now()
        );
        Assignment_Group__c aGroup = new Assignment_Group__c(
            Name = 'Testing',
            Supported_Sobject__c = 'Lead',
            Round_Robin_Queue_Name__c = 'Head_Quarter',
            Max_Sobject_Assignment_Count__c = 9999,
            Max_Lead_Per_Day__c = 50,
            Case_to_Assign_in_Single_Transaction__c = 999999,
            Case_Stage_Exceed_Count__c = 999999,
            Minimum_Case_Volume__c = 999999,
            Execution_SOQL__c = 'SELECT Id, Name, OwnerId FROM Lead WHERE OwnerId IN (SELECT Id FROM Group WHERE Type = \'Queue\' AND Name=\'Head_Quarter\') AND Status IN (\'New\',\'Test Ride\') AND Future_Lead__c = false',
            isActive__c = true
        ); 
        insert aGroup;
        
        Assignment_Group_Member__c agm = new Assignment_Group_Member__c(
            Group_Member__c = testUser.Id,
            Out_Of_Office__c = false,
            Active__c = true,
            Assignment_Id__c = 1,
            Max_Case_Per_Day__c = 50,
            Assignment_Group__c = aGroup.Id
        );
        insert agm;

        UserTrackingcontroller.UserCheckout(testUser.Id);
    }
}