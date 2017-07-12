@isTest
public class AccountControllerExtensionDnBTest
{
    static testMethod void accountControllerExtensionDnBTest() 
    {
        Account testA = new Account( 
            Name = 'Test' ,
            Status_of_D_B_Cleansing__c = null ,
            D_B_Number__c = 'Test DUNS' ,
            D_B_SIC_Code__c = 'Test SIC' ,
            D_B_SIC_Code_Description__c = 'Test SIC Desc' ,
            D_B_NAICS_Code__c = 'Test NAICS' ,
            D_B_NAICS_Code_Description__c = 'Test NAICS Desc' ,
            D_B_Country__c = 'Test Country' ,
            D_B_State_Province__c = 'Test Province' ,
            D_B_City__c = 'Test City' ,
            D_B_Street__c = 'Test Street' ,
            D_B_ZIP_Postal_Code__c = 'Test ZIP'
        );
        insert testA;

        PageReference pageRef = Page.Account_DnB;
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController( testA );   
        ApexPages.currentPage().getParameters().put('id', testA.Id );     
        AccountControllerExtensionDnB testCE = new AccountControllerExtensionDnB( sc );

        testCE.Reject();
        System.assertEquals( testA.Status_of_D_B_Cleansing__c , 'D&B Rejected: Address Retained' );

        testCE.Accept();
        System.assertEquals( testA.Status_of_D_B_Cleansing__c , 'D&B Accepted' );
        System.assertEquals( testA.DUNS_Number__c , testA.D_B_Number__c );
        System.assertEquals( testA.Sic , testA.D_B_SIC_Code__c );
        System.assertEquals( testA.SicDesc , testA.D_B_SIC_Code_Description__c );
        System.assertEquals( testA.SIC_Code__c , testA.D_B_SIC_Code__c + ' - ' + testA.D_B_SIC_Code_Description__c );
        System.assertEquals( testA.NAICS__c , testA.D_B_NAICS_Code__c );
        System.assertEquals( testA.NAICS_Description__c , testA.D_B_NAICS_Code_Description__c );
        System.assertEquals( testA.NAICS_Code__c , testA.D_B_NAICS_Code__c + ' - ' + testA.D_B_NAICS_Code_Description__c );
        System.assertEquals( testA.Country__c , testA.D_B_Country__c );
        System.assertEquals( testA.State_Province__c , testA.D_B_State_Province__c );
        System.assertEquals( testA.City__c , testA.D_B_City__c );
        System.assertEquals( testA.Street__c , testA.D_B_Street__c );
        System.assertEquals( testA.ZIP_Postal_Code__c , testA.D_B_ZIP_Postal_Code__c );
    }
}