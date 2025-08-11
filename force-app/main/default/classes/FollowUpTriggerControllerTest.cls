@isTest
public class FollowUpTriggerControllerTest {
    
    @isTest
    public static void testupdateFollowUpName(){
        Lead l = UtilityTestClass.createTestLead('Test Lead', 'Test Company','New','9035244425','560076','Telephone', 'Telephone');
        Account acc = UtilityTestClass.createTestAccount('Partner Store', 'D001', 'Demo Partner Store','560076', 'Dealer');
        Opportunity opp = UtilityTestClass.createTestOpportunity('Test Opp', acc.Id, 'RNR', Date.today().addDays(10), 100.0);
        List<Follow_Up__c> followUpList = new List<Follow_Up__c>();
        for(Integer i = 0; i<3 ;i++ ){
            Follow_Up__c followUp = UtilityTestClass.createFollowUp('Test - Follow-Up'+i, l.Id , opp.Id );
            followUpList.add(followUp);
        }
        
        List<Follow_Up__c> oldFollowUpList = [SELECT Id, Name, Opportunity__c, Lead__c FROM Follow_Up__c];
        Map<Id, Follow_Up__c> followUpMap = new Map<Id, Follow_Up__c>(oldFollowUpList);
        
        Lead testLead = UtilityTestClass.createTestLead('Test Lead1', 'Test Company1','New','9035244427','560276','Telephone', 'Telephone');
        Map<String, Object> inputMap = new Map<String, Object>{
            'FollowUpDate' => DateTime.now().addDays(1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
                'Status' => 'New',
                'recordId' => testLead.Id
                };
                    
        FollowUpTriggerController.updateFollowUpName(followUpList);
        FollowUpTriggerController.assignSameOwnerOfLeadAndOppToTestDriveOwner(followUpList);
        FollowUpTriggerController.updateleadstatus(followUpList);
        FollowUpTriggerController.previousfeedback(followUpList);
        FollowUpTriggerController.folowuptype(followUpList);
        FollowUpTriggerController.updateFeedBack(followUpList, followUpMap);   
        FollowUpTriggerController.createFollowup(inputMap);
    }
    
    @isTest
    public static void testCreateFollowup() {
        Account acc = UtilityTestClass.createTestAccount('Test Account', 'C001', 'Test Store', '560076', 'Dealer');
        Opportunity testOpp = UtilityTestClass.createTestOpportunity('Test Opp', acc.Id, 'Prospecting', Date.today().addDays(10), 1000);
        Map<String, Object> oppInputMap = new Map<String, Object>{'FollowUpDate' => DateTime.now().addDays(1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''), 'Status' => 'New', 'recordId' => testOpp.Id };            
        FollowUpTriggerController.createFollowup(oppInputMap);
        
        Lead testLead = UtilityTestClass.createTestLead('Test Lead2', 'Test Company3','New','9039244427','560276','Telephone', 'Telephone');
        Follow_Up__c existingFollowup = new Follow_Up__c( Lead__c = testLead.Id, Status__c = 'New', Follow_Up_Date__c = DateTime.now().addDays(1));
        insert existingFollowup;
        Map<String, Object> leadInputMap = new Map<String, Object>{ 'FollowUpDate' => DateTime.now().addDays(2).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''), 'Status' => 'New', 'recordId' => testLead.Id};
        FollowUpTriggerController.createFollowup(leadInputMap);
    }
    
    @isTest
    public static void testCreateNewFollowUpIfTheNextFollowUpIsNotNullOrChanged() {
        Lead testLead = UtilityTestClass.createTestLead('Test Lead', 'Test Company', 'New', '9035244425', '560076', 'Telephone', 'Telephone');
        
        Follow_Up__c initialFollowUp = UtilityTestClass.createFollowUp('Initial Follow-Up', testLead.Id,  null);
        initialFollowUp.Status__c = 'New';
        initialFollowUp.Next_Follow_Up_Date__c = null;
        update initialFollowUp;
        
        Map<Id, Follow_Up__c> oldFollowUps = new Map<Id, Follow_Up__c>();
        oldFollowUps.put(initialFollowUp.Id, initialFollowUp);
        Follow_Up__c updatedFollowUp = initialFollowUp.clone(true, true, true, true);
        updatedFollowUp.Next_Follow_Up_Date__c = DateTime.now().addDays(3);
        
        FollowUpTriggerController.createNewFollowUpIfTheNextFollowUpIsNotNullOrChanged( new List<Follow_Up__c>{updatedFollowUp}, oldFollowUps);
    }
    
    @isTest
    public static void testCreateNewFollowUpForOpportunity() {
        Account acc = UtilityTestClass.createTestAccount('Test Account', 'C001', 'Test Store', '560076', 'Dealer');
        Opportunity testOpp = UtilityTestClass.createTestOpportunity('Test Opp', acc.Id, 'Prospecting', Date.today().addDays(10), 1000);
        
        Follow_Up__c initialFollowUp = UtilityTestClass.createFollowUp('Initial Opp Follow-Up', null,  testOpp.Id);
        initialFollowUp.Status__c = 'New';
        initialFollowUp.Next_Follow_Up_Date__c = null;
        update initialFollowUp;
        
        Map<Id, Follow_Up__c> oldFollowUps = new Map<Id, Follow_Up__c>();
        oldFollowUps.put(initialFollowUp.Id, initialFollowUp);
        Follow_Up__c updatedFollowUp = initialFollowUp.clone(true, true, true, true);
        updatedFollowUp.Next_Follow_Up_Date__c = DateTime.now().addDays(3);
        
        FollowUpTriggerController.createNewFollowUpIfTheNextFollowUpIsNotNullOrChanged( new List<Follow_Up__c>{updatedFollowUp}, oldFollowUps);
    }
        
}