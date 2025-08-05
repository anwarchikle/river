public class TestDriveNotificationBatch implements Database.Batchable<sObject>, Schedulable {
    private Boolean isMorningNotification;
    
    public TestDriveNotificationBatch(Boolean isMorning) {
        this.isMorningNotification = isMorning;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime now = DateTime.now();
        String query;
        
        if (isMorningNotification) {
            // For morning notification: all test drives today
            return Database.getQueryLocator([
                SELECT Id, OwnerId, Test_Drive_Date__c, Lead__r.Name 
                FROM Test_Drive__c 
                WHERE Test_Drive_Date__c = TODAY 
                AND Test_Drive_Status__c NOT IN ('Completed', 'Cancelled')
            ]);
        } else {
            // For 1-hour prior notification
            DateTime startTime = now.addHours(1);
            DateTime endTime = startTime.addMinutes(5); // 5-minute buffer
            
            return Database.getQueryLocator([
                SELECT Id, OwnerId, Test_Drive_Date__c, Lead__r.Name 
                FROM Test_Drive__c 
                WHERE Test_Drive_Date__c >= :startTime 
                AND Test_Drive_Date__c <= :endTime
                AND Test_Drive_Status__c NOT IN ('Completed', 'Cancelled')
            ]);
        }
    }
    
    public void execute(Database.BatchableContext bc, List<Test_Drive__c> testDrives) {
        for (Test_Drive__c td : testDrives) {
            String title = 'Test Drive Reminder';
            String body;
            
            if (isMorningNotification) {
                body = 'Test Drive for ' + td.Lead__r.Name + ' is scheduled today';
            } else {
                body = 'Test Drive for ' + td.Lead__r.Name + ' is starting in 1 hour';
            }
            
            NotificationHelper.sendNotification(td.OwnerId, td.Id, title, body);
        }
    }
    
    public void finish(Database.BatchableContext bc) {}
    
    // Schedulable implementation
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new TestDriveNotificationBatch(isMorningNotification), 50);
    }
}