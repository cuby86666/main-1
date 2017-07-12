/**************************************************************
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 @LastModified By :     Manoj
 @Modified Date :   11 Mar 2015
 @Description :     Modified to improve the code coverage
********************************************************************************/

@IsTest public with sharing class CommunitiesLandingControllerTest {
    @IsTest(SeeAllData=true) public static void testCommunitiesLandingController() {
        // Instantiate a new controller with all parameters in the page
        CommunitiesLandingController controller = new CommunitiesLandingController();
        controller.forwardToStartPage();
        controller.forwardToCustomAuthPage();
      }
}