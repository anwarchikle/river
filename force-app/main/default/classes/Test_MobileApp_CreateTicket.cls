@isTest
private class Test_MobileApp_CreateTicket {

    @isTest
    static void testCreateTicketWithScreenshots() {
        User u = [SELECT Id FROM User WHERE Profile.Name='Standard User' LIMIT 1];

        Blob imgBlob = Blob.valueOf('TestImageContent');
        String base64Img = EncodingUtil.base64Encode(imgBlob);
        
        MobileApp_Wrapper.MobileApp_CreateTicket input = new MobileApp_Wrapper.MobileApp_CreateTicket();
        input.UserId = u.Id;
        input.description = 'Test ticket description';
        input.SS1 = base64Img;
        input.SS2 = base64Img;
        input.SS3 = null;
        input.SS4 = '';
        input.SS5 = '';

        String requestBody = JSON.serialize(input);

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestUri = '/services/apexrest/CreateTicket';
        req.requestBody = Blob.valueOf(requestBody);

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        MobileApp_CreateTicket.CreateTicket();
        Test.stopTest();

        RestResponse res = RestContext.response;
        System.assertEquals(200, res.statusCode);

       
        String resBody = res.responseBody.toString();
        
    }
}