@isTest
public class ExceptionHelperTest {
    @isTest
    static void testExceptionHelper() {
		 try {
            Integer x = 1 / 0;
        } catch (Exception e) {
            Exception_Log__c logRec = ExceptionHelper.createExceptionLog(e);
            Exception_Log__c logRec1 = ExceptionHelper.createExceptionLog(null);
        }
    }
    
    @isTest
    static void testCreateAPICalloutLog() {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://testendpoint.com');
        req.setBody('{"sample":"request"}');

        HttpResponse res = new HttpResponse();
        res.setBody('{"status":"success"}');
        res.setStatusCode(200);

        ExceptionHelper.createAPICalloutLog(req, res, 'Ref123');
    }
    
    
    
}