/******************************************************************************
@Created By :       Balaji Gunasekaran
@Created Date:      11 July 2016
@Description:       Extension class for VF Page AccountTracker - (Top 30 Accounts) - SIR#960
*******************************************************************************/
public class AccountTrackerController
{
    final static String PARENT_ACCOUNT = 'Parent_Account'; 
    public static Account theParentAccount;
    Recordtype rt=[Select Id, DeveloperName From RecordType Where IsActive=true AND (SobjectType = 'Account' and (DeveloperName =:PARENT_ACCOUNT))];
    public String selectedAccountName {get; set;}
    public static Account a;
    public PageReference launchTracker()
    {
        theParentAccount=[Select id,name from Account where name=:selectedAccountName and recordtypeid=:rt.id];
        PageReference retURL = new PageReference('/apex/TrackingSheet?id=' + theParentAccount.id);
        retURL.setRedirect(true);
        return retURL;
    }
    public List<SelectOption> getlstAccountName()
    {
        List<SelectOption> options = new List<SelectOption>();
        List<String> AccountNames = new List<String>();
        List<Top_Accounts__c> listAccounts= Top_Accounts__c.getAll().values();
        for (Top_Accounts__c ltAct : listAccounts)        
        {
            options.add(new SelectOption(ltAct.Name,ltAct.Account_Name__c));
        }
        options.sort();
        return options;
    }
}