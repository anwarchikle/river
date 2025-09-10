@isTest(seeAllData = true)
public class oppoOrdPaymentHelperTest {
    @isTest
    static void testOppoOrdPaymentHelper() {
        Account testAccount = UtilityTestClass.createTestAccount('Test Account', 'C001', 'Test Store', '560076', 'Customer');
        Opportunity testOpp = UtilityTestClass.createTestOpportunity( 'Test Opportunity', testAccount.Id, 'New', System.today().addDays(30), 10000);
        List<Object> sampleData = new List<Object>();
        Map<String, Object> sampleMap = new Map<String, Object>{'productName' => 'Test Product','productId' => 'prod123','quantity' => '2' };
        sampleData.add(sampleMap);
        Map<String, String> paymentDetails = new Map<String, String>{ 'paymentStatus' => 'Paid', 'transactionId' => 'txn123'};
            
		oppoOrdPaymentHelper.getLookupValues('a', 'Opportunity', 'StageName IN (', 'StageName', 1);
		oppoOrdPaymentHelper.getinitRecord(testOpp.Id, 'Opportunity', 'StageName');
        oppoOrdPaymentHelper.gerRecentlyCreatedRecords( 'Opportunity', 'StageName', 'StageName IN (', 1);
       	oppoOrdPaymentHelper.updatePayment(sampleData, paymentDetails);
    }
}