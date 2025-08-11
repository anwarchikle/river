@isTest
public class DynamicUploaderControllerTest {
    @isTest
    public static void testUploadController(){
        
        String objectName = 'Lead';
        Map<String, String> fieldMapping = new Map<String, String>{'FirstName' => 'First Name', 'LastName' => 'Last Name', 'Email' => 'Email'};
		List<String> csvRows = new List<String>{'John, Doe, john.doe@example.com', 'Jane,Smith,jane.smith@example.com' };
            
        DynamicUploaderController.getObjectList();
        DynamicUploaderController.getFieldList('Lead');
        DynamicUploaderController.getFieldList('Opportunity');
        DynamicUploaderController.getFieldList('Account'); 
        DynamicUploaderController.getFieldList('InvalidObject__c'); 
        DynamicUploaderController.getProfileName();
        DynamicUploaderController.uploadData(objectName, fieldMapping, csvRows);
    }

}