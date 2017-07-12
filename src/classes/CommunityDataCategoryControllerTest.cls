/******************************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     05 Aug 2015
Description :      Test class for CommunityDataCategoryController
************************************************************************************************************/

@istest
public class CommunityDataCategoryControllerTest 
{
    //Single case to redirect to question list page
    static testmethod void CommunityDataCategoryControllerTest1()
    {
        Test.startTest();
        CommunityDataCategoryController comDataCatContrl= new CommunityDataCategoryController();
        comDataCatContrl.strCategory='Automotive';
        PageReference homePageRef= new PageReference('/community/CommunityForumQuestionList?category=Automotive');
        PageReference ForumPageref =comDataCatContrl.categorySelected();
		system.assertEquals(homePageRef.getUrl(), ForumPageref.getUrl());
        Test.stopTest();
    }

}