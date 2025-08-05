@isTest(seeAlldata=true)
public class MobileApp_LeadTotalLeadsTest {
    @isTest
    static void testUpdate1() {
        
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha@testorg.com');
        insert userInstant;
        
        Account acc = new Account();
        acc.Name = 'Testing';
        acc.OwnerId = userInstant.Id;
        Insert acc;
        
        Opportunity Opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Testing';
        opp.StageName = 'New';
        opp.Closedate = system.today();
        opp.OwnerId = userInstant.Id;
        Insert opp;
        
        MobileApp_Wrapper.MobileApp_LeadTotalLeadsWrapper wrapperObj = new MobileApp_Wrapper.MobileApp_LeadTotalLeadsWrapper();
        wrapperObj.UserId = userInstant.Id;
        wrapperObj.FilterDate = 'THIS_WEEK';
        wrapperObj.FilterEndRange = '2025-05-13';
        
        String requestBody = JSON.serialize(wrapperObj);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/LeadData';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MobileApp_LeadTotalLeads.LeadTotalLeads();
        MobileApp_LeadTotalLeads.mytest();
    }
    
    @isTest
    static void testUpdateFollowUp_EmptyBody() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/LeadData';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MobileApp_LeadTotalLeads.LeadTotalLeads();
        
    }
}