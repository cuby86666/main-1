/***********************************************************************************************
Dev: Stan
For: Landing_Page.page
------------------------------------------------------------------------------------------------
@LastModified By :  Scarlett Kang
@Modified For :   Release 2016.01 SIR#566
@Description :    New field with picklist for Case Service_Category__c
************************************************************************************************/
public without Sharing class CaseControllerAttachment{
    public String strMessage {get;set;}
    
    public caseControllerAttachment(){
        if (ApexPages.currentPage().getParameters().get('success') == '1')
            strMessage = 'Thank you, your case has been submitted to GSAS.';
        
        
    }

    public Case theCase{
        get{
            if (theCase == null){
                theCase = new Case( 
                    RecordTypeId = '012D0000000gXOPIA2',
                    Origin='Web',
                    Type='Question'
                );
            }
            return theCase ;
        }
        set;
    }
    
    public Attachment theAttachment{
        get{
            if (theAttachment == null){
                theAttachment = new Attachment();
            }
            return theAttachment ;
        }
        set;
    }
 
    public PageReference Submit(){
        strMessage = '';
        try{
    /**1601 Release - SIR 522, Modified by Scarlett**/
            if (theCase.Case_Owner_Name__c == '' || theCase.Email__c == '' || theCase.Application__c == '' || theCase.Application__c == NULL ||
                theCase.Subject == '' || theCase.Description == '' || theCase.Service_Category__c == '' || theCase.Service_Category__c == NULL) {
     /**1601 Release - SIR 522, Modified by Scarlett**/                
                    strMessage = 'Please check required fields';
                    return null;
                } else {
                    insert theCase;
                    strMessage = 'Thank you, your case has been submitted to GSAS.';
                }
        } 
        catch (DMLException e){
			strMessage = 'Error: ' + e.getMessage();
        } 

        if (theAttachment.Body != null) {
		    try{
                System.debug('GSAS TRY ATTACH');
		        theAttachment.OwnerId = UserInfo.getUserId();
		        theAttachment.ParentId = theCase.Id; // the case record the file is attached to
		        theAttachment.IsPrivate = false;
	            insert theAttachment;
	        } 
	        catch (DMLException e){
                System.debug('GSAS ERROR ATTACH');
	        } 
	        finally{
	            theAttachment = new Attachment(); 
	        }
        }
        PageReference pg = new PageReference('/Landing_Page?success=1');
        pg.setRedirect(true);
        return pg;
    }
}