/*********************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     16 Sept 2015
Description :      Class for NXP community moderators to edit reply posted to a question in forum
****************************************************************************************************/

public class CommunityEditReplyController 
{
     public String strAnsBody{get;set;}
     public List<Reply> objReps{get;set;}

    public CommunityEditReplyController()
    {
        if(ApexPages.currentPage().getParameters().get('strAnsId')!=null)
        {
            objReps= [Select id,Body,question.id,question.title from reply where id=:ApexPages.currentPage().getParameters().get('strAnsId')];
            if(objReps.size()!=0 || objReps!=null)
            {
                strAnsBody= objReps[0].body;
            }
        }
    }
    
    //method to edit answer which has been posted
    public PageReference editAns()
    {
        PageReference pageRef;
        objReps= [Select id,Body,questionId,question.title from reply where id=:ApexPages.currentPage().getParameters().get('strAnsId')];
        if(objReps.size()!=0 || objReps!=null)
        {
            objReps[0].body= strAnsBody;
            if(objReps[0].Body=='' || objReps[0].Body==null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Description for your answer'));
                return null;
            }
            update objReps[0];
            try{
                pageRef=new PageReference('/CommunityQuestionView?id='+objReps[0].questionId);
                
            }
        
         catch (DMLException e) 
          {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in updating reply'));
              return null;
          } 
        }
        pageref.setRedirect(true);
        return pageref;
    }
}