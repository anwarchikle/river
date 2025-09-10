@isTest(seeAllData = true)
public class OpportunityTriggerHandlerTest {
    
    @isTest
    static void testCreateOrderIfOppIsClosedWon() {
        User salesManager = UtilityTestClass.createSalesManagerUser();
        Account testAccount = UtilityTestClass.createTestAccount('Test Account', 'C001', 'Test Store', '560076', 'Customer');
        
        System.runAs(salesManager) {
            
            Opportunity testOpp = UtilityTestClass.createTestOpportunity( 'Test Opportunity', testAccount.Id, 'New', System.today().addDays(30), 10000);
            testOpp.StageName = 'Closed Won';
            testOpp.Booking_Amount__c=100;
            
            Product2 testProduct = new Product2(
                Name = 'Test Product',
                IsActive = true,
                ProductCode = 'TEST1001',
                HSN_Code__c = '1234',
                Type__c = 'Accessory'
            );
            insert testProduct;
            
            Id standardPricebookId = Test.getStandardPricebookId();
            
            PricebookEntry standardPbe = new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = testProduct.Id,
                UnitPrice = 100,
                IsActive = true
            );
            insert standardPbe;
            
            
            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = testOpp.Id,
                Quantity = 1,
                UnitPrice = 100,
                PricebookEntryId = standardPbe.Id
            );
            insert oli;
            
            
            Opportunity oldOpp = testOpp.clone(false);
            oldOpp.StageName = 'New';
            update testOpp;
            
           OpportunityTriggerHandler.createOrderIfOppIsClosedWon(
                new List<Opportunity>{ testOpp },
                new Map<Id, Opportunity>{ testOpp.Id => oldOpp }
            );
        }
    }
    
    @isTest
    static void testCreateEvent() {
        Lead testLead = UtilityTestClass.createTestLead('Test Lead','Test Company','New','9035244425','660087','Online','Google');
        
        Map<String, Object> testData = new Map<String, Object>{'StartDate' => System.now().addDays(1), 'EndDate' => System.now().addDays(1).addHours(1), 'Status' => 'Scheduled',
                'rideType' => 'HTR', 'recordId' => testLead.Id, 'street' => '123 Test St', 'city' => 'Test City', 'country' => 'US', 'province' => 'CA', 'postalCode' => '12345'};          
        OpportunityTriggerHandler.createEvent(testData);
    }
    
    @isTest
    static void testCreateEvent_FallbackBranch() {
        Lead testLead = UtilityTestClass.createTestLead('Test Lead 2', 'Test Company', 'New', '9870003210', '660087', 'Online', 'Google' );
        
        Map<String, Object> testData = new Map<String, Object>{ 'StartDate' => System.now().addDays(2),'EndDate' => System.now().addDays(2).addHours(1),'Status' => 'Planned',
                'rideType' => 'HTR', 'recordId' => testLead.Id, 'street' => '456 Test Rd', 'city' => 'New City', 'country' => 'US', 'province' => 'NY', 'postalCode' => '54321' };
                    
        OpportunityTriggerHandler.createEvent(testData);
    }

    @isTest
    static void testConvertLeadAndShowTheOpportunity() {
        OpportunityTriggerHandler.ConvertLeadAndShowTheOpportunity( UtilityTestClass.createTestLead('Lead One', 'Company A', 'New', '9011111111', '111111', 'Online', 'Google').Phone );
        
        Lead lead2 = UtilityTestClass.createTestLead('Lead Two', 'Company B', 'New', '9022222222', '222222', 'Online', 'Google');
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead2.Id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.convertLead(lc);
        OpportunityTriggerHandler.ConvertLeadAndShowTheOpportunity('9022222222');
        
        Lead lead3 = UtilityTestClass.createTestLead('Lead Three', 'Company C', 'New', '9033333333', '333333', 'Online', 'Google');
        lead3.Stores_Name__c = 'Out of Coverage'; lead3.Future_Lead__c = true; update lead3;
        OpportunityTriggerHandler.ConvertLeadAndShowTheOpportunity('9033333333');
        
        OpportunityTriggerHandler.ConvertLeadAndShowTheOpportunity('9044444444');
        
        Account acc = UtilityTestClass.createTestAccount('Demo Store', 'D002', 'Demo Store', '560076', 'Dealer');
        acc.Phone = '9055555555'; update acc;
        OpportunityTriggerHandler.ConvertLeadAndShowTheOpportunity('9055555555');
        
        acc.Phone = '9066666666'; update acc;
        Opportunity opp = UtilityTestClass.createTestOpportunity('Opp One', acc.Id, 'Prospecting', Date.today().addDays(10), 10000);
        opp.Phone__c = '9066666666'; update opp;
        Test_Drive__c testDrive = UtilityTestClass.createTest1Driver('Test Drive Existing', opp.Id, 'New');
        
        OpportunityTriggerHandler.ConvertLeadAndShowTheOpportunity('9066666666');
        
        Account acc2 = UtilityTestClass.createTestAccount('Another Store', 'D003', 'Another Store', '560078', 'Dealer');
        acc2.Phone = '9077777777'; update acc2;
        Opportunity opp2 = UtilityTestClass.createTestOpportunity('Opp Two', acc2.Id, 'Prospecting', Date.today().addDays(5), 15000);
        opp2.Phone__c = '9077777777'; update opp2;
        OpportunityTriggerHandler.ConvertLeadAndShowTheOpportunity('9077777777');
    }

    @isTest
    static void testCreateOpportunity() {
        List<UserRole> UserRoleType = [Select Id,Name from UserRole  Where PortalType ='Partner' LIMIT 1 ];
        List<User> userList = [SELECT Id FROM User Where UserRoleId =: UserRoleType[0].Id AND isActive = true AND contactId != null];
        Id UserId = userList[0].Id;
        Account testAccount = UtilityTestClass.createTestAccount('Demo Store', 'D001', 'Demo Store', '560076', 'Dealer');
        UtilityTestClass.createTestPinCode(testAccount.Id, '100003', 'Bangalore');
        
        System.runAs(userList[0]) {
            Map<String, Object> testData = new Map<String, Object>{'fName' => 'Test', 'lName' => 'User',  'phone' => '9876543210', 'pincode' => '560076', 
                'primSorceValue' => 'Walk-In', 'secSourceValue' => 'Referral' };
			OpportunityTriggerHandler.createOpportunity(testData);
        }
    }

    @isTest
    static void testOnClosedWonShowErrorIfOppLineItemsAreNotThere() {
        User salesManager = UtilityTestClass.createSalesManagerUser();
        Account testAccount = UtilityTestClass.createTestAccount('Test Account', 'C001', 'Test Store', '560076', 'Customer');
        
        System.runAs(salesManager) {
            Opportunity testOpp = UtilityTestClass.createTestOpportunity('Test Opportunity', testAccount.Id, 'New', System.today().addDays(30), 10000 );
            try {
                testOpp.StageName = 'Closed Won';
                update testOpp;
            } catch (Exception e) {
            }
        
        }
    }
    
    @isTest
    static void testCreateFollowUp() {
        Lead testLead = UtilityTestClass.createTestLead( 'Test Lead', 'Test Company', 'New', '9035244425', '123456', 'Online', 'Google' );
        
        Account testAccount = UtilityTestClass.createTestAccount('Test Account', 'C001', 'Test Store', '560076', 'Customer');
        Opportunity testOpp = UtilityTestClass.createTestOpportunity( 'Test Opportunity',    testAccount.Id, 'Prospecting', System.today().addDays(30),  10000 );
        Follow_Up__c followUpWithLead = UtilityTestClass.createFollowUp('Test Follow Up', testLead.Id, null);

        Follow_Up__c followUpWithOpp = UtilityTestClass.createFollowUp('Test Follow Up', null, testOpp.Id);
        
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id, Opportunity> oldOpp = new Map<Id, Opportunity>();
        for(Integer i = 0; i<6 ; i++){
            User salesManager = UtilityTestClass.createSalesManagerUser();
            
            if(i<3){
                Opportunity testOpp1 = new Opportunity(  Name ='Test Opportunity'+i, AccountId = testAccount.Id,StageName = 'Prospecting',CloseDate = System.today().addDays(30),Amount =  1000+i );
                testOpp1.OwnerId = salesManager.Id;
                insert testOpp1;
                oppList.add(testOpp1);
            }else{
                Opportunity testOpp1 = new Opportunity(  Name ='Test Opportunity'+i, AccountId = testAccount.Id,StageName = 'Prospecting',CloseDate = System.today().addDays(30),Amount =  1000+i );
                insert testOpp1;
                oldOpp.put(testOpp1.Id, testOpp1);
            }
            
            
        }
        
        OpportunityTriggerHandler.createFollowUpOnOppCreated(oppList);
        
        OpportunityTriggerHandler.changeOwnerOfTestDriveAndFollowUpIsOppOwnerIsChanged(oppList, oldOpp);
    }    
    
}