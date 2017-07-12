/*****************************************************************************
* Created By   : Shridevi badiger
* Created Date : 20 May 2016
* Description  : To test the functionality of SendRejectionEmail method.
********************************************************************************************
* Modified By   : Shridevi badiger
* Created Date : 20 June 2016
* Description  : To test the functionality of NewUserRegistration page-SIR 848.
********************************************************************************************
* Last Modified By : Baji
* Last Modified Date : 19 Dec 2016
* Description : Modified BU 511 and BU 52R description as part of YE activities
********************************************************************************************
@Last Modified By     : Baji
@Last Modified Date   : 16 Feb, 2017
@Description : Obsoleted BU 511 related test data
********************************************************************************************/
@isTest
public class NewUserRegistrationTest{

 
public static New_User_Registeration__c NewRequest=new New_User_Registeration__c();
public static list<New_User_Registeration__c> listNewRequest=new list<New_User_Registeration__c>();
public static User testUser; 
public static map<id,string> mapApprovalResult=new map<id,string>();
Private Static Final string TYPE_New_User_Reg='New_User_Registeration';
Private Static Final String TYPE_Apttus_New_User_Reg='Apttus_New_User_Registeration';
Public static Id newUserReg_Id;
Public static Id apptusNewUserReg_Id;
Public static pageReference pageRef{get;set;}
//To create test user   
public static user createNewUser()
{
   Profile theProfile = [Select p.Name, p.Id From Profile p where Name = 'NXP Sales Read Only'];
   testUser = new User
        (
         Firstname='test',
         alias = 'tempt', 
         email='shridevi.badiger@nxp.com',
         emailencodingkey='UTF-8', 
         lastname='Testing123', 
         languagelocalekey='en_US',
         localesidkey='en_US', 
         profileid = theProfile.Id,
         timezonesidkey='America/Los_Angeles', 
         username='test@nxp.com'+'.test',
         Signed_Aria__c=True
         );
        return testUser;
    

}
//To create test record for newUserRegistration object.
public static New_User_Registeration__c createNewUserRegistration(string catagory,id recordTypeId,id testUserId)
{

    NewRequest=new New_User_Registeration__c();
    NewRequest.First_Name__c='Test';
    NewRequest.Last_Name__c='test';
    NewRequest.Email_Address__c='shridevi.badiger@nxp.com';
    NewRequest.Region__c='EMEA';
    NewRequest.Country__c='India';
    NewRequest.Job_Title__c='test';
    NewRequest.Phone_Number__c='123456781';
    NewRequest.Manager_Name__c='test';
    NewRequest.Manager_s_email__c='shridevi.badiger@nxp.com';
    NewRequest.RequestforAccountin__c=catagory;
    NewRequest.Role__c='NXP BU/BL';
    //NewRequest.BU__c = 'test';
    //NewRequest.BL__c = 'test';
    NewRequest.Status__c='In Progress';
    NewRequest.RecordTypeId = recordTypeId;
    NewRequest.OwnerId=testUserId;
    NewRequest.Are_you_a_DW_Approver__c='No';
    System.debug('test Owner id1::'+NewRequest.OwnerId);
    return NewRequest;
}

// to create test Approval process which in turn creates process instances.
public static void createApprovalProcess(id registrationRequestId)
{
     Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest(); 
     request .setComments('Submitting request for approval.'); 
     request .setNextApproverIds(new Id[] {UserInfo.getUserId()});
     request .setObjectId(registrationRequestId); 
     Approval.ProcessResult result = Approval.process(request ); 
     system.debug('status for approval::'+result.getInstanceStatus()); 
     List<Id> newWorkItemIds = result.getNewWorkitemIds(); 
     Approval.ProcessWorkitemRequest request2 = new Approval.ProcessWorkitemRequest(); 
     request2 .setComments('Rejecting test request.'); 
     request2 .setAction('Reject'); 
     request2 .setNextApproverIds(new Id[] {UserInfo.getUserId()});
     request2 .setWorkitemId(newWorkItemIds.get(0)); 
     // Submit the request for approval 
     Approval.ProcessResult result2 = Approval.process(request2 ); 
     // Verify the results
     system.debug(':Result Status::'+result2); 
     listNewRequest=[select Status__c from New_User_Registeration__c where id in: listNewRequest];
     system.debug(':request::'+listNewRequest); 
    //return result2.getInstanceStatus();
    mapApprovalResult.put(result2.getEntityId(),result2.getInstanceStatus());
}

@isTest 
public static void newRequestRejectionEmailTest()
  {
      testUser=createNewUser();
      insert testUser;
      List<recordType> listRecordType=[Select Id, Name,DeveloperName From RecordType 
                        Where IsActive=true AND (SobjectType = 'New_User_Registeration__c' and 
                        (DeveloperName =:TYPE_New_User_Reg OR DeveloperName =:TYPE_Apttus_New_User_Reg))];
  
      System.debug('listRecordType::'+listRecordType);
      listNewRequest.add(createNewUserRegistration('Box',listRecordType[0].id,testUser.id));
      listNewRequest.add(createNewUserRegistration('Brainshark',listRecordType[1].id,testUser.id));
      insert listNewRequest;
      Test.startTest();
      for(New_User_Registeration__c request:listNewRequest)
        createApprovalProcess(request.id);

      for(New_User_Registeration__c request:listNewRequest)
      {
        System.assert(mapApprovalResult.get(request.id)==request.Status__c); 
        System.debug('id:'+request.id+'---result:'+mapApprovalResult.get(request.id)+'---status:'+request.Status__c);
      }
      Test.stopTest();
  }
 //Added by shridevi- SIR 848
public static String processRequest(New_User_Registeration__c request)
{

    date trainingDate=Date.newInstance(2010, 07, 15);
    NewUserRegisterationController newUser=new NewUserRegisterationController();
    newUser.user=request;
    newUser.user.Available_Date_for_Training__c=trainingDate;
    // newUser.user.Are_you_a_DW_Approver__c='No';
    newUser.getdisplayFields();
    newUser.backToStep1();
    newUser.goToStep2();
    newUser.save();
    pageRef=newUser.register();
    if(string.valueOf(pageRef)==null || string.valueOf(pageRef)=='')
        return 'salesforce';
    else
        return pageRef.getUrl();

}
//Added by Shridevi- SIR 848- Separating the Box,Brainshark,GoToMeeting,Training App registartion pages.
@isTest 
public static void newAUserRegistrationControllerTest()
{
    NewUserRegisterationController registration=new NewUserRegisterationController();
    testUser=createNewUser();
    insert testUser;
    String stringUrl;
    listNewRequest=new list<New_User_Registeration__c>();
    list<recordType> listRecordType=[Select Id, Name,DeveloperName From RecordType 
                                    Where IsActive=true AND (SobjectType = 'New_User_Registeration__c' and 
                                    (DeveloperName =:TYPE_New_User_Reg OR DeveloperName =:TYPE_Apttus_New_User_Reg))];
    System.debug('listRecordType::'+listRecordType);
    listNewRequest.add(createNewUserRegistration('Box',listRecordType[1].id,testUser.id));
    listNewRequest.add(createNewUserRegistration('Brainshark',listRecordType[1].id,testUser.id));
    listNewRequest.add(createNewUserRegistration('GoToMeeting',listRecordType[1].id,testUser.id));
    listNewRequest.add(createNewUserRegistration('Training App',listRecordType[1].id,testUser.id));
    listNewRequest.add(createNewUserRegistration('salesforce',listRecordType[1].id,testUser.id));
    listNewRequest.add(createNewUserRegistration('salesforce',listRecordType[1].id,testUser.id));
    listNewRequest.add(createNewUserRegistration('salesforce',listRecordType[1].id,testUser.id));
    listNewRequest[5].Role__c='NXP Sales';  
    listNewRequest[5].BU__c=null;
    listNewRequest[5].BL__c=null;
    listNewRequest[1].Role__c='NXP Sales';  
    listNewRequest[1].BU__c=null;
    listNewRequest[1].BL__c=null;
    listNewRequest[6].Specify_Mags__c='R33';
    listNewRequest[6].Are_you_a_DW_Approver__c = 'Yes';
  //  listNewRequest[0].BU__c='511 - BU Nexperia Business';
  //  listNewRequest[0].BL__c='BL07 - BL STANDARD PRODUCTS UNDIVIDED';
    listNewRequest[3].BU__c='525 - BU AUTOMOTIVE';
    listNewRequest[3].BL__c='BL04 - BL CATENA';
    listNewRequest[4].BU__c='52R - BU RF power';
    listNewRequest[4].BL__c='BLRF - BL RF';
    
 
    System.debug('reg1 step1:'+registration.step1+'--'+registration.step2);
  
    listNewRequest[2].BU__c='52R - BU RF power';
    listNewRequest[2].BL__c='BLRF - BL RF';
    registration.user=listNewRequest[2];
    registration.goToStep2();
    System.assert(registration.step1==false);
    System.assert(registration.step2==true);
         
      
    for(New_User_Registeration__c request:listNewRequest)
    {
    
        System.debug('test Owner id::'+request.ownerId);
        stringUrl=processRequest(request);
        System.debug('pageRef::'+stringUrl);
        System.debug('stringUrl::'+stringUrl);
     
        if(request.RequestforAccountin__c=='Brainshark')
         { 
           System.assert(string.valueOf(stringUrl)=='/newuser/NewUserRegisteration?userRequestparam=Brainshark');
           
         }
        if(request.RequestforAccountin__c=='GoToMeeting')
         {
          System.assert(string.valueOf(stringUrl)=='/newuser/NewUserRegisteration?userRequestparam=GoToMeeting');
         
         }
       /* if(request.RequestforAccountin__c=='Training App')
          {
            System.assert(string.valueOf(stringUrl)=='/newuser/NewUserRegisteration?userRequestparam=Training+App');
          
          }*/
    }
 
}

}