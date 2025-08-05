trigger triggerOnAccount on Account (before insert,before update) {
    if(trigger.isBefore && trigger.isInsert) {
        //accountTriggerHelper.dontCreateDuplicateAccount(Trigger.new);
    }
    if(trigger.isBefore && trigger.isupdate) {
        //accountTriggerHelper.dontCreateDuplicateAccount(Trigger.new);
    }
}