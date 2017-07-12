/******************************************************************************************************
@Created By :      Amrutha R
@Created Date :    06 Nov 2015
Description :      Used in communityCaseController, this code is separated because it must be executed 
                   without sharing
*********************************************************************************************************/

/******************************************************************************************************
@Created By :      Avichal Kumar
@Created Date :    17 feb 2016
Description :      code is modified for inserting multiple attachment for cases.
*********************************************************************************************************/


public without sharing class CommunityCaseAttachmentController 
{
    public PageReference caseAttachment(Attachment myAttachment,Id caseId)
    {
        myAttachment.ParentId=caseId; 
         
        try 
        {
            insert myAttachment;
        } 
        catch (DMLException e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
            return null;
        } 
        
        return null;
    }
}