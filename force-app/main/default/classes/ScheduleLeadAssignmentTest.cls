@isTest
public class ScheduleLeadAssignmentTest {

    @isTest
    static void testScheduleLeadAssignmentExecute() {
        Test.startTest();
        ScheduleLeadAssignment.scheduleJob();
        Test.stopTest();
    }

    @isTest
    static void testExecuteMethod() {
        ScheduleLeadAssignment sla = new ScheduleLeadAssignment();
        sla.execute(null);
    }

    @isTest
    static void testManualCronSchedule() {
        String cron = '0 0 12 * * ?';
        System.schedule('Manual_LeadAssignment', cron, new ScheduleLeadAssignment());
    }
}