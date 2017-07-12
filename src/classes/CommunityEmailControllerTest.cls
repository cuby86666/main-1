/*********************************************************************************************
@Created By :      Amit Rajan
@CreatedDate :     06 May 2016
Description :      Test Class for Email custom related list
****************************************************************************************************/
@isTest(seeAllData = false)
Public class CommunityEmailControllerTest{
    
    static Case caseRecord;

    /*
    * @name         : saveRecord
    * @description  : saves the Case record with updated owner
    * @ Input param : Null
    * @ return type : Null
    */
    public static testmethod void caseTest(){
        
        loadData();
        System.runAs(new User (Id = UserInfo.getUserId())){
        
            CommunityEmailController controller = new CommunityEmailController(new ApexPages.standardController(caseRecord));
            controller.sendAnEmail();
            
            EmailMessage message = new EmailMessage();
            message.fromAddress ='avs@ts.com';
            message.Toaddress = 'hg@fjj.com';
            message.subject ='Test';
            message.parentId = caseRecord.id;
           insert message;
            
            System.assert( message.id != null);
            
            controller = new CommunityEmailController(new ApexPages.standardController(caseRecord));
            
            ApexPages.currentPage().getParameters().put('emailId', [SELECT id from EmailMessage LIMIT 1].id);
            controller.getSortedEmails();
            controller.sendAnEmail();
            controller.deleteEmail();
            controller.replyEmail();
            controller.replyAllEmail();
           
        }
        Test.stopTest();
        
        
    } 
    
    static void loadData(){
        
        
        
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
           
            caseRecord = new Case();
            caseRecord.Subject = 'Test';
            caseRecord.Type = 'Problem';
            caseRecord.ownerId = UserInfo.getUserid();
            
            insert caseRecord;
            
        }
        
        
    }

    
}