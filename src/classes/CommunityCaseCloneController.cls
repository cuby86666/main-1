/******************************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     20 Jul 2016
Description :      Custom clone class to copy caseowner, suppliedemail, assignedto and origin as clone
************************************************************************************************************/

public class CommunityCaseCloneController
{
    public case objCase;
    public Case objCloneCase;
    private ApexPages.StandardController controller {get; set;}
    
	public CommunityCaseCloneController(ApexPages.StandardController controller) 
    {
        this.controller = controller;
        objCase = (Case)controller.getRecord();
    }
	
    public PageReference saveClonedCase()
    {
        objCloneCase= new case();
        objCloneCase = objcase.clone(false, true);
        objCloneCase.Origin = 'Clone';
        objCloneCase.SuppliedEmail = objCase.SuppliedEmail;
        try
        {
        	insert objCloneCase;
        }
        catch(DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured. Error: ' +e));  
            return null;   
        }
        
        //During insert it considers assignment rules and assign to default instead of copying objcase value
        //So updating after insert
        objCloneCase.OwnerId = objcase.OwnerId;
        try
        {
            update objCloneCase;
        }
        catch(DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured. Error: ' +e));     
           	return null;   
        }
        
        PageReference pageRef = new pagereference('/' + objCloneCase.id);
        return pageRef;
    }
    
    public PageReference cancelClone()
    {
        PageReference pageRef = new pagereference('/' + objCase.id);
        return pageRef;
	}
}