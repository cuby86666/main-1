/*  
   @Last Modified By     : Manoj 
   @Last Modified Date   : 09 Mar, 2015 
   @Description : Added @isTest annotation at class level. 
*/

@isTest
public class TestUpdateOwnerInfo{
    @isTest
    private static void TestUpdateOwnerInfo(){
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE isactive =true and Name = 'Sales CRM' Limit 1];
        
        Case cas = new Case();
        cas.Subject = 'Testing Record';
        cas.Description = 'Testing Record';
        if(recordTypes.size() > 0 ){
            cas.RecordTypeId = recordTypes.get(0).Id;
        }
        insert cas;
        
    }
}