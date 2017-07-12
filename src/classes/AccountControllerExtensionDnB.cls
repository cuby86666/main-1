public class AccountControllerExtensionDnB 
{
    private final Account A;
    public boolean ButtonsActive {get;set;}
    public Account theAccount {get;set;}
    
    public AccountControllerExtensionDnB( ApexPages.StandardController stdController )
    {
        this.A = (Account)stdController.getRecord( ) ;
        theAccount = this.A ;    
    }
     
    public pageReference Accept( )
    { 
        theAccount.Status_of_D_B_Cleansing__c = 'D&B Accepted' ;
        theAccount.DUNS_Number__c = theAccount.D_B_Number__c;
        theAccount.Sic = theAccount.D_B_SIC_Code__c;
        theAccount.SicDesc = theAccount.D_B_SIC_Code_Description__c;
        if( theAccount.D_B_SIC_Code_Description__c != NULL )
            theAccount.SIC_Code__c = theAccount.D_B_SIC_Code__c + ' - ' + theAccount.D_B_SIC_Code_Description__c;
        else
            theAccount.SIC_Code__c = theAccount.D_B_SIC_Code__c ;
        theAccount.NAICS__c = theAccount.D_B_NAICS_Code__c;
        theAccount.NAICS_Description__c = theAccount.D_B_NAICS_Code_Description__c;
        if( theAccount.D_B_NAICS_Code_Description__c != NULL )
            theAccount.NAICS_Code__c = theAccount.D_B_NAICS_Code__c + ' - ' + theAccount.D_B_NAICS_Code_Description__c;
        else
            theAccount.NAICS_Code__c = theAccount.D_B_NAICS_Code__c ;
        theAccount.Country__c = theAccount.D_B_Country__c ;
        theAccount.State_Province__c = theAccount.D_B_State_Province__c ;
        theAccount.City__c = theAccount.D_B_City__c ;
        theAccount.Street__c = theAccount.D_B_Street__c ;
        theAccount.ZIP_Postal_Code__c = theAccount.D_B_ZIP_Postal_Code__c ;
        update theAccount ;

        pageReference PR = new ApexPages.StandardController(A).view( ) ;
        PR.getParameters( ).put( 'inline' , '0' );   
        return PR;
    }
    
    public pageReference Reject( )
    {
        theAccount.Status_of_D_B_Cleansing__c = 'D&B Rejected: Address Retained' ;
        update theAccount ;

        pageReference PR = new ApexPages.StandardController(A).view() ;
        PR.getParameters( ).put( 'inline' , '0' ) ;   
        return PR ;
    }
}