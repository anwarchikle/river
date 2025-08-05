@isTest
public class OrderItemTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {
        Id stdPrBk = Test.getStandardPricebookId();

        Product2 vehicleProduct = new Product2(Name = 'Test Vehicle', Type__c = 'Vehicle', IGST_Percentage__c = 10, ProductCode = '123ir', HSN_Code__c = '1234');
        Product2 accessoryProduct = new Product2(Name = 'Test Accessory', Type__c = 'Accessories', IGST_Percentage__c = 5, ProductCode = '123ur', HSN_Code__c = '1234');
        Product2 merchandiseProduct = new Product2(Name = 'Test Merchandise', Type__c = 'Merchandise', IGST_Percentage__c = 8, ProductCode = '123yr', HSN_Code__c = '1234');

        insert new List<Product2>{ vehicleProduct, accessoryProduct, merchandiseProduct };

        PricebookEntry vehiclePriceEntry = new PricebookEntry(Product2Id = vehicleProduct.Id, Pricebook2Id = stdPrBk, UnitPrice = 100000, IsActive = true);
        PricebookEntry accessoryPriceEntry = new PricebookEntry(Product2Id = accessoryProduct.Id, Pricebook2Id = stdPrBk, UnitPrice = 5000, IsActive = true);
        PricebookEntry merchandisePriceEntry = new PricebookEntry(Product2Id = merchandiseProduct.Id, Pricebook2Id = stdPrBk, UnitPrice = 2000, IsActive = true);

        insert new List<PricebookEntry>{ vehiclePriceEntry, accessoryPriceEntry, merchandisePriceEntry };
            
        Account testAccount = new Account(Name = 'Test Account 1', Type = 'Customer');
        insert testAccount;

        Order testOrder = new Order(Name = 'Test Order', AccountId = testAccount.Id, Pricebook2Id = stdPrBk, Payment_Status__c = 'Completed', Status = 'Draft', EffectiveDate = Date.today());
        insert testOrder;

        OrderItem vehicleOrderItem = new OrderItem(OrderId = testOrder.Id, Product2Id = vehicleProduct.Id, PricebookEntryId = vehiclePriceEntry.Id, Quantity = 1, UnitPrice = 100000);
        OrderItem accessoryOrderItem = new OrderItem(OrderId = testOrder.Id, Product2Id = accessoryProduct.Id, PricebookEntryId = accessoryPriceEntry.Id, Quantity = 2, UnitPrice = 5000);
        OrderItem merchandiseOrderItem = new OrderItem(OrderId = testOrder.Id, Product2Id = merchandiseProduct.Id, PricebookEntryId = merchandisePriceEntry.Id, Quantity = 3, UnitPrice = 2000);

        insert new List<OrderItem>{ vehicleOrderItem, accessoryOrderItem, merchandiseOrderItem };
    }
    
    @isTest
    static void testHandleAfterInsert() {
        Test.startTest();
        List<Order> testOrders = [SELECT Id FROM Order LIMIT 1];
        Test.stopTest();
    }
    
    @isTest
    static void testCalculateRollupValues() {
        Test.startTest();
        List<OrderItem> testOrderItems = [SELECT Id FROM OrderItem LIMIT 1];
        Test.stopTest();
    }

    @isTest
    static void testHandleAfterDelete() {
        List<OrderItem> orderItemsToDelete = [SELECT Id FROM OrderItem LIMIT 1];

        Test.startTest();
        delete orderItemsToDelete;
        Test.stopTest();
    }
}