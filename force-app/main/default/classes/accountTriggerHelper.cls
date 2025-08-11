public class accountTriggerHelper {
    public static void dontCreateDuplicateAccount(List<Account> newAccounts) {
        Set<String> phoneNumbers = new Set<String>();

        for (Account acc : newAccounts) {
            if (!String.isBlank(acc.Phone)) {
                phoneNumbers.add(acc.Phone);
            }
        }

        if (phoneNumbers.isEmpty()) return;

        Map<String, Account> existingPhoneToAccountMap = new Map<String, Account>();
        for (Account acc : [SELECT Id, Phone FROM Account WHERE Phone IN :phoneNumbers]) {
            if (!String.isBlank(acc.Phone)) {
                existingPhoneToAccountMap.put(acc.Phone, acc);
            }
        }

        for (Account acc : newAccounts) {
            if (!String.isBlank(acc.Phone)) {
                if (existingPhoneToAccountMap.containsKey(acc.Phone) &&
                    acc.Id != existingPhoneToAccountMap.get(acc.Phone).Id) {
                    acc.addError('An account with this phone number already exists: ' + acc.Phone);
                }
            }
        }
    }
}