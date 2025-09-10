@isTest
public class SobjectLoadAssignmentHelperTest {
    @isTest
    static void testExecuteSobjectOwnerAssignment() {
        User testUser = UtilityTestClass1.createSalesManagerUser1();

        Assignment_Group__c ag = new Assignment_Group__c(
            Name__c = 'Out of Business Hours',
            isActive__c = true,
            Business_Hours_Morning__c = Time.newInstance(1, 0, 0, 0),
            Business_Hours_End_Time__c = Time.newInstance(23, 0, 0, 0),
            Last_Allocated_RRid__c = 0
        );
        insert ag;

        Assignment_Group_Member__c agm = new Assignment_Group_Member__c(
            Assignment_Group__c = ag.Id,
            Group_Member__c = testUser.Id,
            Active__c = true,
            Assignment_Id__c = 1,
            Max_Case_Per_Day__c = 5
        );
        insert agm;
        Account acc = UtilityTestClass1.createTestAccount( 'Demo Account', 'C001', 'Main Store', '560076', 'Dealer' );

        UtilityTestClass1.createTestPinCode(acc.Id, '560076', 'Bangalore');

        Lead testLead = UtilityTestClass1.createTestLead(  'TestLead', 'Demo Company', 'Open', '9999999999', '560076', 'Telephone', 'Telephone'   );

        Opportunity testOpp = UtilityTestClass1.createTestOpportunity( 'Demo Opportunity', acc.Id, 'Prospecting', Date.today().addDays(10), 5000 );

        List<SObject> recordsToAssign = new List<SObject>{ testLead, testOpp };
        SobjectLoadAssignmentHelper.ExecuteSobjectOwnerAssignment(recordsToAssign, ag.Id, null);
    }
}