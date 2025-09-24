/**
* @description       : 
* @author            : Md Anwar Chikle
* @group             : Anurag Raichand
* @last modified on  : 05/sep/25
* @last modified by  : Md Anwar Chikle
**/
@isTest(SeeAllData = True)
public class LeadCreationAPIThinkResultTest {
	 @isTest
    static void testCreateLead() {
        Account dealerAcc = new Account(Name = 'Dealer Service Center', Phone = '9052222131', Type = 'Dealer',Center_Code__c='Doo1');
        insert dealerAcc;
        
        Pin_Code__c pin = UtilityTestClass.createTestPinCode(dealerAcc.Id ,'800001' , 'Patna');
        
        Schema.Location loc = new Schema.Location(Name = 'River Store - Indiranagar', LocationType= 'State');
        insert loc;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Dummmy', Email = 'Tests@test.com', Phone = '9052222131', AccountId = dealerAcc.Id, Role_Type__c = 'Sales', Location__c =loc.Id,Designation__c = 'WM');
        insert con;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Manager (Partner)' LIMIT 1];
        
        User wmUser = new User(
            FirstName = 'Partner', LastName = 'Manager', Alias = 'pmanag',  Email = 'partner.manager@example.com', Username = 'partner.manager.' + DateTime.now().getTime() + '@example.com',
            ProfileId = p.Id, TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', ContactId = con.Id
        );
        insert wmUser;
        Opportunity testOpp =  UtilityTestClass.createTestOpportunity( 'Test Opportunity', dealerAcc.Id, 'New', System.today().addDays(30), 10000);
        testOpp.StageName = 'Closed Won';
        testOpp.Booking_Amount__c=100;
        update testOpp;
        
        String reqBody = '{'+'"FullName":"Testing Record",'+'"Company":"N/A",'+'"Email":"aniket@example.com",'+'"Phone":"9052222131",'+'"City":"Other",'+'"PostalCode":"800001",'+'"HomeTestRide":true,'+'"InstoreTestdrive":false,'+'"verified":true,'+
            '"startDateTimeStr":"2025-08-15 10:00:00",'+'"endDateTimeStr":"2025-08-15 10:00:00",'+'"DealerCode":"321001",'+'"utm_source":"google"'+'}';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/createLeadRiverWebsite';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        LeadCreationAPIThinkResult.createLeadFromWebsite();
    }
    @isTest
    static void testCreateLead1() {
        Account dealerAcc = new Account(Name = 'Dealer Service Center', Phone = '9052222131', Type = 'Dealer',Center_Code__c='Doo1');
        insert dealerAcc;
        
        Pin_Code__c pin = UtilityTestClass.createTestPinCode(dealerAcc.Id ,'800001' , 'Patna');
        
        Schema.Location loc = new Schema.Location(Name = 'River Store - Indiranagar', LocationType= 'State');
        insert loc;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Dummmy', Email = 'Tests@test.com', Phone = '9052222131', AccountId = dealerAcc.Id, Role_Type__c = 'Sales', Location__c =loc.Id,Designation__c = 'WM');
        insert con;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Manager (Partner)' LIMIT 1];
        
        User wmUser = new User(
            FirstName = 'Partner', LastName = 'Manager', Alias = 'pmanag',  Email = 'partner.manager@example.com', Username = 'partner.manager.' + DateTime.now().getTime() + '@example.com',
            ProfileId = p.Id, TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', ContactId = con.Id
        );
        insert wmUser;
        Opportunity testOpp =  UtilityTestClass.createTestOpportunity( 'Test Opportunity', dealerAcc.Id, 'New', System.today().addDays(30), 10000);
        testOpp.StageName = 'New';
        testOpp.Booking_Amount__c=100;
        update testOpp;
        
        String reqBody = '{'+'"FullName":"Testing Record",'+'"Company":"N/A",'+'"Email":"aniket@example.com",'+'"Phone":"9052222131",'+'"City":"Other",'+'"PostalCode":"800001",'+'"HomeTestRide":true,'+'"InstoreTestdrive":false,'+'"verified":true,'+
            '"startDateTimeStr":"2025-08-15 10:00:00",'+'"endDateTimeStr":"2025-08-15 10:00:00",'+'"DealerCode":"321001",'+'"utm_source":"google"'+'}';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/createLeadRiverWebsite';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        LeadCreationAPIThinkResult.createLeadFromWebsite();
    }
    @isTest
    static void testCreateLead2() {
        Account dealerAcc = new Account(Name = 'Dealer Service Center', Phone = '2222222222', Type = 'Dealer',Center_Code__c='Doo1');
        insert dealerAcc;
        Lead leadWithRelatedRecords = UtilityTestClass.createTestLead('Test Lead', 'Test Company','New','9052222131','560076','Telephone', 'Telephone');
        Pin_Code__c pin = UtilityTestClass.createTestPinCode(dealerAcc.Id ,'800001' , 'Patna');
        
        Schema.Location loc = new Schema.Location(Name = 'River Store - Indiranagar', LocationType= 'State');
        insert loc;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Dummmy', Email = 'Tests@test.com', Phone = '9052222131', AccountId = dealerAcc.Id, Role_Type__c = 'Sales', Location__c =loc.Id,Designation__c = 'WM');
        insert con;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Manager (Partner)' LIMIT 1];
        
        User wmUser = new User(
            FirstName = 'Partner', LastName = 'Manager', Alias = 'pmanag',  Email = 'partner.manager@example.com', Username = 'partner.manager.' + DateTime.now().getTime() + '@example.com',
            ProfileId = p.Id, TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', ContactId = con.Id
        );
        insert wmUser;
        
        Opportunity testOpp =  UtilityTestClass.createTestOpportunity( 'Test Opportunity', dealerAcc.Id, 'New', System.today().addDays(30), 10000);
        testOpp.StageName = 'Closed Won';
        testOpp.Booking_Amount__c=100;
        update testOpp;
        
        String reqBody = '{'+'"FullName":"Testing Record",'+'"Company":"N/A",'+'"Email":"aniket@example.com",'+'"Phone":"9052222131",'+'"City":"Other",'+'"PostalCode":"800001",'+'"HomeTestRide":true,'+'"InstoreTestdrive":false,'+'"verified":true,'+
            '"startDateTimeStr":"2025-08-15 10:00:00",'+'"endDateTimeStr":"2025-08-15 10:00:00",'+'"DealerCode":"321001",'+'"utm_source":"google"'+'}';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/createLeadRiverWebsite';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        LeadCreationAPIThinkResult.createLeadFromWebsite();
    }
    
    @isTest
    static void testCreateLead3() {
        Account dealerAcc = new Account(Name = 'Dealer Service Center', Phone = '9052222131', Type = 'Dealer',Center_Code__c='Doo1');
        insert dealerAcc;
        
        Pin_Code__c pin = UtilityTestClass.createTestPinCode(dealerAcc.Id ,'800001' , 'Patna');
        
        Schema.Location loc = new Schema.Location(Name = 'River Store - Indiranagar', LocationType= 'State');
        insert loc;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Dummmy', Email = 'Tests@test.com', Phone = '9052222131', AccountId = dealerAcc.Id, Role_Type__c = 'Sales', Location__c =loc.Id,Designation__c = 'WM');
        insert con;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Manager (Partner)' LIMIT 1];
        
        User wmUser = new User(
            FirstName = 'Partner', LastName = 'Manager', Alias = 'pmanag',  Email = 'partner.manager@example.com', Username = 'partner.manager.' + DateTime.now().getTime() + '@example.com',
            ProfileId = p.Id, TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', ContactId = con.Id
        );
        insert wmUser;
        String uniquePhone = '999999' + String.valueOf(Math.mod(Crypto.getRandomInteger(), 9999));
        
        String reqBody = '{'+
            '"FullName":"Testing Record",'+'"Company":"N/A",'+'"Email":"aniket@example.com",'+'"Phone":"uniquePhone",'+'"City":"Other",'+'"PostalCode":"800001",'+'"HomeTestRide":true,'+'"InstoreTestdrive":false,'+'"verified":true,'+ '"startDateTimeStr":"2025-08-15 10:00:00",'+
            '"endDateTimeStr":"2025-08-15 10:00:00",'+'"DealerCode":"321001",'+'"utm_source":"google"'+'}';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/createLead91Wheels';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;

        LeadCreationAPIThinkResult.createLeadFromWebsite();
    }
    
    
    @istest
    static void testCreateLeadException() {
        String reqBody = '{'+
            '"FullName":"Testing Record"}';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/createLeadRiverWebsite';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        LeadCreationAPIThinkResult.createLeadFromWebsite();
    }
    
    
    
    @isTest
    static void testCreateLead4() {
        Pin_Code__c pin = UtilityTestClass.createTestPinCode(null, '800001', 'Patna');
        List<Lead> leadToConvert = [SELECT Id, Name , Phone, ConvertedAccountId  FROM Lead WHERE IsConverted = true Order By CreatedDate  DESC];
        
        Opportunity testOpp =  UtilityTestClass.createTestOpportunity( 'Test Opportunity', leadToConvert[0].ConvertedAccountId, 'New', System.today().addDays(30), 10000);
        testOpp.StageName = 'Closed Won';
        testOpp.Booking_Amount__c=100;
        update testOpp;
        
        String reqBody = '{'+'"FullName":"Testing Record",'+'"Company":"N/A",'+'"Email":"aniket@example.com",'+'"Phone":"1111122222",'+'"City":"Other",'+'"PostalCode":"800001",'+'"HomeTestRide":true,'+'"InstoreTestdrive":false,'+'"verified":true,'+
            '"startDateTimeStr":"2025-08-15 10:00:00",'+'"endDateTimeStr":"2025-08-15 10:00:00",'+'"DealerCode":"321001",'+'"utm_source":"google"'+'}';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/createLead91Wheels';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        LeadCreationAPIThinkResult.createLeadFromWebsite();
        
    }
    
    @isTest
    static void testCreateLead5() {      
        Pin_Code__c pin = UtilityTestClass.createTestPinCode(null, '800001', 'Patna');
        List<Lead> leadToConvert = [SELECT Id, Name , Phone, ConvertedAccountId  FROM Lead WHERE IsConverted = true Order By CreatedDate  DESC];
        Opportunity testOpp =  UtilityTestClass.createTestOpportunity( 'Test Opportunity', leadToConvert[0].ConvertedAccountId, 'New', System.today().addDays(30), 10000);
      
        String reqBody = '{"FullName":"Test User","Company":"Comp","Email":"t2@example.com","Phone":"1111122222","City":"City","PostalCode":"800001","HomeTestRide":true,"InstoreTestdrive":false,"startDateTimeStr":"2025-08-15 10:00:00","endDateTimeStr":"2025-08-15 11:00:00"}';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/createLead91Wheels';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        LeadCreationAPIThinkResult.createLeadFromWebsite();
        
    }
}