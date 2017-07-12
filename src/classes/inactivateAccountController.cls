public class inactivateAccountController 
{
    private final Account A;

    public inactivateAccountController( ApexPages.StandardController stdController )
    {
        this.A = (Account)stdController.getRecord();
    }
     
    public PageReference autoRun() 
    {
        String theId = ApexPages.currentPage().getParameters().get('id');
 
        if (theId == null) 
        {
            return null;
        }
 
        for (Account A:[select id, name, OwnerId, OwnerId_Original__c, IsInactive__c from Account where id =:theId]) 
        {
            if( A.OwnerId != '00520000001EuBkAAK' )
            {
                if( A.OwnerId_Original__c == null )
                {
                   A.OwnerId_Original__c = A.OwnerId;
                }
                A.OwnerId = '00520000001EuBkAAK' ; 
            }
            A.IsInactive__c = true;

            update A;
        }
 
        PageReference pageRef = new PageReference('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;
    }

    static testMethod void inactivateAccountControllerTest() 
    {
        Account testA = new Account( Name = 'Test' );
        insert testA;

        PageReference pageRef = Page.InactivateAccount;
        Test.setCurrentPageReference(pageRef);

        ApexPages.StandardController sc = new ApexPages.standardController( testA );   

        ApexPages.currentPage().getParameters().put('id', testA.Id );     

        inactivateAccountController testC = new inactivateAccountController( sc );

        Test.startTest();
        testC.autoRun();
        Test.stopTest();

//        System.assertEquals( '00520000001EuBkAAK', testA.OwnerId );
//        System.assertEquals( '005M0000004cjkWIAQ' , testA.OwnerId_Original__c );
//        System.assertEquals( true , testA.IsInactive__c );

    }
}