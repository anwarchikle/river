@isTest
public class MobileAPP_DropLeadTest {
    @isTest
    static void testUpdate1() {
        
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha@testorg.com');
        insert userInstant;
        
        Lead ledRec = new Lead();
        ledRec.Company = 'Testing';
        ledRec.LastName = 'Testing';
        Insert ledRec;
        
        MobileApp_Wrapper.MobileApp_DropLead wrapperObj = new MobileApp_Wrapper.MobileApp_DropLead();
        wrapperObj.UserId = userInstant.Id;
        wrapperObj.LeadId = ledRec.Id;
        wrapperObj.DropOutReason = 'Test';
        wrapperObj.Comments = 'Testing';
        
        String requestBody = JSON.serialize(wrapperObj);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/DropLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MobileAPP_DropLead.DropLead();
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
        
        Account acc = new Account();
        acc.Name = 'River Testing';
        acc.Center_Code__c = '291008';
        acc.Store_Type__c = 'COCO';
        acc.Type = 'Dealer';
        Insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = acc.Name;
        opp.CloseDate = System.today();
        opp.AccountId = acc.Id;
        opp.StageName = 'Test Ride Scheduled';
        insert opp;
        
        MobileApp_Wrapper.MobileApp_DropLead wrapperObj = new MobileApp_Wrapper.MobileApp_DropLead();
        wrapperObj.UserId = userInstant.Id;
        wrapperObj.LeadId = opp.Id;
        wrapperObj.DropOutReason = 'Test';
        wrapperObj.Comments = 'Testing';
        
        String requestBody = JSON.serialize(wrapperObj);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/DropLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        MobileAPP_DropLead.DropLead();  
    }
    
    @isTest
    static void testUpdate3() {
        
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha@testorg.com');
        insert userInstant;
        
        Lead ledRec = new Lead();
        ledRec.Company = 'Testing';
        ledRec.LastName = 'Testing';
        Insert ledRec;
        
        MobileApp_Wrapper.MobileApp_DropLead wrapperObj = new MobileApp_Wrapper.MobileApp_DropLead();
        wrapperObj.LeadId = ledRec.Id;
        wrapperObj.DropOutReason = 'Test';
        wrapperObj.Comments = 'Testing';
        
        String requestBody = JSON.serialize(wrapperObj);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/DropLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        MobileAPP_DropLead.DropLead();
        
    }
    
    @isTest
    static void testUpdateFollowUp_EmptyBody() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/DropLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MobileAPP_DropLead.DropLead();
        
    }
}