public class NotificationScheduler {
    public static void scheduleAllNotifications() {
        // Morning notifications at 8 AM daily
        String morningCron = '0 0 10 * * ?';
        System.schedule('Test Drive Morning Notifications', morningCron, new TestDriveNotificationBatch(true));
        System.schedule('Follow-up Morning Notifications', morningCron, new FollowUpNotificationBatch(true));
        
        // Hourly notifications for 1-hour prior
        String hourlyCron = '0 0 * * * ?';
        System.schedule('Test Drive Hourly Notifications', hourlyCron, new TestDriveNotificationBatch(false));
        System.schedule('Follow-up Hourly Notifications', hourlyCron, new FollowUpNotificationBatch(false));
    }
}