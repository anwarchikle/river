@isTest
public class MobileApp_EventFollowUpTest {
    @isTest
    public static void testGetFollowUps(){
        User usr = UtilityTestClass.createSalesManagerUser();
        
        Account acc = UtilityTestClass.createTestAccount('Test Account', 'C001', 'Test Store', '560076', 'Customer');

        Lead lead = UtilityTestClass.createTestLead('Test Lead', 'Test Company','New','9035244421','560076','Telephone', 'Telephone');

        Opportunity opp = UtilityTestClass.createTestOpportunity( 'Test Opportunity', acc.Id, 'RNR', System.today().addDays(30), 10000 );
        

        Follow_Up__c followUp = UtilityTestClass.createFollowUp('Test Follow Up',  lead.Id, opp.Id);
        followUp.Feedback__c = 'Test Feedback';
        followUp.Follow_Up_Date__c = Date.today();
        followUp.Next_Follow_Up_Date__c = Date.today().addDays(2);
        followUp.Status__c = 'New';
        followUp.FollowUpType__c = 'booking call';
        update followUp;

        MobileApp_Wrapper.MobileApp_LeadTotalLeadsWrapper wrapper = new MobileApp_Wrapper.MobileApp_LeadTotalLeadsWrapper();
        wrapper.UserId = UserInfo.getUserId();
        wrapper.FilterDate = 'TODAY'; 
        wrapper.FilterEndRange = null;

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/EventFollowUp';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(wrapper));
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        MobileApp_EventFollowUp.getFollowUps();
    }
    @isTest
    public static void testGetFollowUps1(){
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/EventFollowUp';
        req.httpMethod = 'POST';
        req.requestBody = null;
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        MobileApp_EventFollowUp.getFollowUps();
        Test.stopTest();
    }
    @isTest
    static void testGetFollowUps2() {
        MobileApp_Wrapper.MobileApp_LeadTotalLeadsWrapper wrapper = new MobileApp_Wrapper.MobileApp_LeadTotalLeadsWrapper();
        wrapper.UserId = '';
        wrapper.FilterDate = 'TODAY';

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/EventFollowUp';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(wrapper));
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MobileApp_EventFollowUp.getFollowUps();

    }
}