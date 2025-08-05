@isTest
public class MobileAPP_CreateLead_Test {
    @isTest
    static void testUpdate1() {
        
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha@testorg.com');
        insert userInstant;
        
        
        MobileApp_Wrapper.MobileApp_CreateLead wrapperObj = new MobileApp_Wrapper.MobileApp_CreateLead();
        wrapperObj.UserId = userInstant.Id;
        wrapperObj.Salutation = 'Mr.';
        wrapperObj.FirstName = 'Anwar';
        wrapperObj.LastName = 'Chikle';
        wrapperObj.Email = 'anwar.chikle@utilitarianlabs.com';
        wrapperObj.Phone = '8880899982';
        wrapperObj.LeadStatus = 'New';
        wrapperObj.LeadSource = 'Walk-In';
        wrapperObj.DirectBooking = false;
        wrapperObj.bookATestRide = false;
        
        String requestBody = JSON.serialize(wrapperObj);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MobileAPP_CreateLead.createLead();
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
        
        
        MobileApp_Wrapper.MobileApp_CreateLead wrapperObj = new MobileApp_Wrapper.MobileApp_CreateLead();
        wrapperObj.UserId = userInstant.Id;
        wrapperObj.Salutation = 'Mr.';
        wrapperObj.FirstName = 'Anwar';
        wrapperObj.LastName = 'Chikle';
        wrapperObj.Email = 'anwar.chikle@utilitarianlabs.com';
        wrapperObj.Phone = '8880899982';
        wrapperObj.LeadStatus = 'New';
        wrapperObj.LeadSource = 'Walk-In';
        wrapperObj.bookATestRide = true;
        wrapperObj.TestDriveDate = '2025-05-13';
        wrapperObj.TestDriveTime = '9:45';
        
        wrapperObj.RideType = 'Home Test Ride';
        wrapperObj.HomeTestDriveAddress = 'Vakil Square Bannerghatta Road Utilitarian labs';
        
        String requestBody = JSON.serialize(wrapperObj);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MobileAPP_CreateLead.createLead();
        
    }
    
    @isTest
    static void testUpdate3(){
        
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha@testorg.com');
        insert userInstant;
        
        
        MobileApp_Wrapper.MobileApp_CreateLead wrapperObj = new MobileApp_Wrapper.MobileApp_CreateLead();
        wrapperObj.UserId = userInstant.Id;
        wrapperObj.Salutation = 'Mr.';
        wrapperObj.FirstName = 'Anwar';
        wrapperObj.LastName = 'Chikle';
        wrapperObj.Email = 'anwar.chikle@utilitarianlabs.com';
        wrapperObj.Phone = '8880899982';
        wrapperObj.LeadStatus = 'New';
        wrapperObj.LeadSource = 'Walk-In';
        wrapperObj.bookATestRide = true;
        wrapperObj.TestDriveDate = '2025-05-13';
        wrapperObj.TestDriveTime = '9:45';
        wrapperObj.RideType = 'Store Test Ride';
        
        String requestBody = JSON.serialize(wrapperObj);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MobileAPP_CreateLead.createLead();
        
    }
    
    @isTest
    static void testUpdate4() {
        
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha@testorg.com');
        insert userInstant;
        
        
        MobileApp_Wrapper.MobileApp_CreateLead wrapperObj = new MobileApp_Wrapper.MobileApp_CreateLead();
        wrapperObj.UserId = userInstant.Id;
        wrapperObj.Salutation = 'Mr.';
        wrapperObj.FirstName = 'Anwar';
        wrapperObj.LastName = 'Chikle';
        wrapperObj.Email = 'anwar.chikle@utilitarianlabs.com';
        wrapperObj.Phone = '8880899982';
        wrapperObj.LeadStatus = 'New';
        wrapperObj.LeadSource = 'Walk-In';
        wrapperObj.DirectBooking = true;
        wrapperObj.country = 'India';
        wrapperObj.state = 'Karnataka';
        wrapperObj.RideType = 'Store Test Ride';
        
        String requestBody = JSON.serialize(wrapperObj);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MobileAPP_CreateLead.createLead();
        
    }
    
    @isTest
    static void testUpdate5() {
        MobileApp_Wrapper.MobileApp_CreateLead wrapperObj = new MobileApp_Wrapper.MobileApp_CreateLead();
        wrapperObj.Salutation = 'Mr.';
        wrapperObj.FirstName = 'Anwar';
        wrapperObj.Email = 'anwar.chikle@utilitarianlabs.com';
        wrapperObj.Phone = '8880899982';
        wrapperObj.LeadStatus = 'New';
        wrapperObj.LeadSource = 'Walk-In';
        
        String requestBody = JSON.serialize(wrapperObj);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        MobileAPP_CreateLead.createLead();
        
    }
    
    @isTest
    static void testUpdateFollowUp_EmptyBody() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MobileAPP_CreateLead.createLead();
        
    }
}