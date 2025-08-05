public class NotificationHelper {
    public static void sendNotification(Id userId, Id targetId, String title, String body) {
        try {
            CustomNotificationType notificationType = [SELECT Id FROM CustomNotificationType 
                                                       WHERE DeveloperName = 'Available_Quantity_is_Zero' LIMIT 1];
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(title);
            notification.setBody(body);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(targetId);
            notification.send(new Set<String>{userId});
        } catch (Exception e) {
            System.debug('Error sending notification: ' + e.getMessage());
        }
    }
}