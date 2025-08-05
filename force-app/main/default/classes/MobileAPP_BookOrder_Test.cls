@isTest
public class MobileAPP_BookOrder_Test {
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
        
        MobileApp_Wrapper.MobileAPP_BookOrder wrapperObj = new MobileApp_Wrapper.MobileAPP_BookOrder();
        wrapperObj.UserId = userInstant.Id;
        wrapperObj.OpportunityId = opp.Id;
        wrapperObj.OrderAmount = '2500';
        wrapperObj.PaymentMode = 'UPI';
        
        String requestBody = JSON.serialize(wrapperObj);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateOrder';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MobileAPP_BookOrder.createLead();
    }
    
    @isTest
    static void testUpdate2() {
        
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha@testorg.com');
        insert userInstant;
        
        
        
        Lead ledRec = new lead();
        ledRec.LastName = 'Testing';
        ledRec.Phone= '8880899982';
        ledRec.Company =  'Testing';
        ledRec.OwnerId = userInstant.Id;
        Insert ledrec;
        
        MobileApp_Wrapper.MobileAPP_BookOrder wrapperObj1 = new MobileApp_Wrapper.MobileAPP_BookOrder();
        wrapperObj1.UserId = userInstant.Id;
        wrapperObj1.OpportunityId = ledRec.Id;
        wrapperObj1.OrderAmount = '2500';
        wrapperObj1.PaymentMode = 'UPI';
        
        String requestBody1 = JSON.serialize(wrapperObj1);
        
        RestRequest req1 = new RestRequest();
        req1.requestUri = '/services/apexrest/CreateOrder';
        req1.httpMethod = 'POST';
        req1.requestBody = Blob.valueOf(requestBody1);
        RestContext.request = req1;
        
        RestResponse res1 = new RestResponse();
        RestContext.response = res1;
        
        MobileAPP_BookOrder.createLead();
        
    }
    
    @isTest
    static void testUpdate3() {
        
        MobileApp_Wrapper.MobileAPP_BookOrder wrapperObj = new MobileApp_Wrapper.MobileAPP_BookOrder();
        wrapperObj.OrderAmount = '2500';
        wrapperObj.PaymentMode = 'UPI';
        
        String requestBody = JSON.serialize(wrapperObj);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateOrder';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        MobileAPP_BookOrder.createLead();
        
    }
    
    @isTest
    static void testUpdateFollowUp_EmptyBody() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateOrder';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MobileAPP_BookOrder.createLead();
        
    }
}