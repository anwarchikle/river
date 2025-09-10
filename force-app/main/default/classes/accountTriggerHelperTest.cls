@isTest
public class accountTriggerHelperTest {
    @isTest
    static void testAccountTriggerHelper() {
		List<Account> accToInsert = new List<Account>();
        for(Integer i = 0; i<3;i++){
            Account acc = new Account(Name = 'Test acc'+i, Center_Code__c = 'D003'+i, Store_Name__c = 'Test StoreName'+i , BillingPostalCode = '10001'+i, Type = 'Dealer',Phone='3344778866' );
            accToInsert.add(acc);
        }
        insert accToInsert;
        accountTriggerHelper.dontCreateDuplicateAccount(accToInsert);
    }
}