@isTest
public class MobileAPP_UpdateLeadTest {
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
        
        MobileApp_Wrapper.MobileApp_UpdateLead wrapperObj = new MobileApp_Wrapper.MobileApp_UpdateLead();
        wrapperObj.UserId = userInstant.Id;
        wrapperObj.LeadId = ledRec.Id;
        
        String requestBody = JSON.serialize(wrapperObj);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/UpdateLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MobileAPP_UpdateLead.updateLead();
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
        
        MobileApp_Wrapper.MobileApp_UpdateLead wrapperObj = new MobileApp_Wrapper.MobileApp_UpdateLead();
        wrapperObj.LeadId = ledRec.Id;
        
        
        String requestBody = JSON.serialize(wrapperObj);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/UpdateLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        MobileAPP_UpdateLead.updateLead();
        
    }
    
    @isTest
    static void testUpdateFollowUp_EmptyBody() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/UpdateLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MobileAPP_BookOrder.createLead();
        
    }
}