@isTest
public class UtilityTestClassTest {
	@isTest
    public static void testUtil(){
        UtilityTestClass.createSalesManagerUser();
        UtilityTestClass.createSalesManagerUser1();
        UtilityTestClass.createTestDriver();
        Lead l = UtilityTestClass.createTestLead('Test Lead', 'Test Company','New','9035244425','560076','Telephone', 'Telephone');
        Account testAccount = UtilityTestClass.createTestAccount('Test Account', 'C001', 'Test Store', '560076', 'Dealer');            
        Opportunity opp = UtilityTestClass.createTestOpportunity( 'Test Opportunity', testAccount.Id, 'New', System.today().addDays(30), 10000);
        UtilityTestClass.createFollowUp('Test - Follow-Up', l.Id , opp.Id );
        UtilityTestClass.createTestPinCode(testAccount.Id, '800001', 'Patna');
        UtilityTestClass.createTestTask(l.Id, 'New', Date.Today());
        UtilityTestClass.createTest1Driver('Test Drive Existing', opp.Id, 'Scheduled');
        
        
    }
}