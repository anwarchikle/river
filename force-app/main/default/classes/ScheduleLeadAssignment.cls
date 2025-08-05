public class ScheduleLeadAssignment implements Schedulable {
    public void execute(SchedulableContext sc) {
        SobjectLoadAssignment.ExecuteLoadAssignment(2);
        Database.executeBatch(new batchForLead());
    }
    
    public static void scheduleJob() {
          
        String cronExp10AM = '0 0 10 * * ?';
        System.schedule('DailyLeadAssignment_10AM', cronExp10AM, new ScheduleLeadAssignment());

        //12PM
        String cronExp12PM = '0 0 12 * * ?';
        System.schedule('DailyLeadAssignment_12PM', cronExp12PM, new ScheduleLeadAssignment());
    }
}