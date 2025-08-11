@isTest
public class TaskLeadControllerTest {
    @isTest
    public static void testGetFieldDependencies(){
        Lead lead = UtilityTestClass.createTestLead('Test Lead', 'Test Company','RNR','9035244542','560076','Telephone', 'Telephone');
        Task tsk = UtilityTestClass.createTestTask(lead.Id, 'RNR', Date.today());
        TaskLeadController.getFieldDependencies('Lead', 'LeadSource', 'Secondary_Sources__c');
        TaskLeadController.statusPicklistValues('Lead', 'LeadSource');
        TaskLeadController.leadThreshold('lead.Id');
        TaskLeadController.getRecentCallTask(lead.Id);
        TaskLeadController.handleTaskCompletion(tsk.Id , lead.Id,'Drop Out', 'RNR', tsk.ActivityDate,' Some Lost Reason','Some Lost Reason Feedback' );
        Lead lead2 = UtilityTestClass.createTestLead('Test Lead', 'Test Company','RNR','9035574542','560076','Telephone', 'Telephone');
        
        Task tsk2 = UtilityTestClass.createTestTask(lead2.Id, 'In Progress', Date.today().addDays(2));
        TaskLeadController.handleTaskCompletion(tsk2.Id, lead2.Id, 'In Progress', 'Callback', tsk2.ActivityDate, '', '');

        Task tsk3 = UtilityTestClass.createTestTask(lead2.Id, 'In Progress', Date.today());
        TaskLeadController.handleTaskCompletion(tsk3.Id, lead2.Id, 'In Progress', 'Disconnected', Date.today(), 'Lost', 'Feedback');
        
    }
}