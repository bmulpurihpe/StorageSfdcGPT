public class CountAssetQueueable implements Queueable {
    private Set<Id> accountIds;

    public CountAssetQueueable(Set<Id> accountIds) {
        this.accountIds = accountIds;
    }

    public void execute(QueueableContext context) {
        List<Account> accountsToUpdate = [SELECT Id FROM Account WHERE Id IN :accountIds];
        Database.update(accountsToUpdate, false);
    }
}