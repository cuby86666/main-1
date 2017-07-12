/********************************************************************
Name          : TestNewCase
Trigger       : NewCase
Date          : 2011-04-20
Author        :      
Description   : Test class to test trigger NewCase

  
   @Last Modified By     : Manoj 
   @Last Modified Date   : 09 Mar, 2015 
   @Description : Added @isTest annotation at class level. 
********************************************************************/
  
@isTest
public class TestNewCase{
    @isTest
    
    private static void testNewCase(){
        Community cm = [Select Id From Community limit 1];
        
        Idea id = new Idea();
        id.Title = 'test12341234';
        id.CommunityId = cm.Id;
        insert id;
        
        List<Case> csList = [select id,Subject from Case where Subject =: id.Title]; 
        System.assert(csList.size()>0,'No records found');
    }
}