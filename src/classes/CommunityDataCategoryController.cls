/******************************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     18 Jul 2015
Description :      Class for NXP community users to redirect to list of question-
                   CommunityDataCategoryComponent
************************************************************************************************************/

public class CommunityDataCategoryController 
{
    public String strCategory{get;set;}
    
    public PageReference categorySelected()
    {
        PageReference lstQuePage = new PageReference('/community/CommunityForumQuestionList');
        lstQuePage.getParameters().put('category',strCategory);
        return lstQuePage.setRedirect(true);
    }

}