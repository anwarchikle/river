@isTest
public class MobileAPP_UpdateFollowUp_Test {
    
    @isTest
    static void testUpdateFollowUp_Success() {
        Follow_Up__c followUp = new Follow_Up__c(Name = 'Test FollowUp',Follow_Up_Date__c = system.today());
        insert followUp;

        MobileApp_Wrapper.MobileApp_UpdateFollowUp wrapperObj = new MobileApp_Wrapper.MobileApp_UpdateFollowUp();
        wrapperObj.FollowUpId = followUp.Id;
        wrapperObj.FollowUpStatusCompleted = true;

        String requestBody = JSON.serialize(wrapperObj);

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/UpdateFollowUp';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        MobileAPP_UpdateFollowUp.UpdateFollowUp();
        Test.stopTest();
    }

    @isTest
    static void testUpdateFollowUp_MissingId() {
        MobileApp_Wrapper.MobileApp_UpdateFollowUp wrapperObj = new MobileApp_Wrapper.MobileApp_UpdateFollowUp();
        wrapperObj.FollowUpId = null;
        wrapperObj.FollowUpStatusCompleted = true;

        String requestBody = JSON.serialize(wrapperObj);

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/UpdateFollowUp';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        MobileAPP_UpdateFollowUp.UpdateFollowUp();
        Test.stopTest();
    }

    @isTest
    static void testUpdateFollowUp_EmptyBody() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/UpdateFollowUp';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        MobileAPP_UpdateFollowUp.UpdateFollowUp();
        Test.stopTest();
    }
}