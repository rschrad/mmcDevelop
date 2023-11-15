public class BuyerMemberManager {
    private final Account currentAccount;

    public BuyerMemberManager(Account currentAccount) {
        this.currentAccount = currentAccount;
    }

    public void createBuyerAccount() {
        BuyerAccount bAccount = new BuyerAccount(
            BuyerId = currentAccount.Id,
            Name = currentAccount.Name,
            IsActive = true
        );

        NLSQDMLServiceWS.insertRecord(bAccount);
    }

    public void createBuyerGroupMember() {
        BuyerGroup buyerGroup = getBuyerGroup();

        BuyerGroupMember groupMember = new BuyerGroupMember(BuyerId = currentAccount.Id, BuyerGroupId = buyerGroup.Id);

        NLSQDMLServiceWS.insertRecord(groupMember);
    }

    private static BuyerGroup getBuyerGroup() {
        List<BuyerGroup> buyersGroups = NLSQRegistrationUtils.getDefaultBuyerGroup();

        if (buyersGroups.isEmpty()) {
            buyersGroups.add(new BuyerGroup(Name = NLSQConstants.SETTING.Buyer_Group_Name__c));
            NLSQDMLServiceWS.insertRecords(buyersGroups);
        }

        return buyersGroups.get(0);
    }
}