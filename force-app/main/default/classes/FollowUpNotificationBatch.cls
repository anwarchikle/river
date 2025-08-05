public class FollowUpNotificationBatch implements Database.Batchable<sObject>, Schedulable {
    private Boolean isMorningNotification;
    
    public FollowUpNotificationBatch(Boolean isMorning) {
        this.isMorningNotification = isMorning;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime now = DateTime.now();
        String query;
        
        if (isMorningNotification) {
            return Database.getQueryLocator([
                SELECT Id, OwnerId, Follow_Up_Date__c, Lead__r.Name 
                FROM Follow_Up__c 
                WHERE Follow_Up_Date__c = TODAY 
                AND Status__c NOT IN ('Completed', 'Cancelled')
            ]);
        } else {
            // For 1-hour prior notification
            DateTime startTime = now.addHours(1);
            DateTime endTime = startTime.addMinutes(20);
            
            return Database.getQueryLocator([
                SELECT Id, OwnerId, Follow_Up_Date__c, Lead__r.Name 
                FROM Follow_Up__c 
                WHERE Follow_Up_Date__c >= :startTime 
                AND Follow_Up_Date__c <= :endTime
                AND Status__c NOT IN ('Completed', 'Cancelled')
            ]);
        }
    }
    
    public void execute(Database.BatchableContext bc, List<Follow_Up__c> followUps) {
        for (Follow_Up__c fu : followUps) {
            String title = 'Follow-up Reminder';
            String body;
            
            if (isMorningNotification) {
                body = 'Follow-up for ' + fu.Lead__r.Name + ' is scheduled today';
            } else {
                body = 'Follow-up for ' + fu.Lead__r.Name + ' is due in 1 hour';
            }
            
            NotificationHelper.sendNotification(fu.OwnerId, fu.Id, title, body);
        }
    }
    
    public void finish(Database.BatchableContext bc) {}
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new FollowUpNotificationBatch(isMorningNotification), 50);
    }
}