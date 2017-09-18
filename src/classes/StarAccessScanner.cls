/**************************************************************************************
@Modified By    Nisha Agrawal
@Modified Date    Aug 29,2017
@Description    To resolve error 'Too many DML rows' and move the code to execute 
          method from constructor
***************************************************************************************/

global class StarAccessScanner implements Database.Batchable<sObject>, Database.Stateful
{
    static Map<String,STAR_Access__c> mapStarAccess = new Map<String,STAR_Access__c>();
    static Map<Id,List<Id>> mapPublicGroupMembers = new Map<Id,List<Id>>();
    
    global StarAccessScanner()
    {
        //generating group members maps
        for( GroupMember theGroupMember : [SELECT GroupId, UserOrGroupId FROM GroupMember] )
        {
            if( mapPublicGroupMembers.containsKey(theGroupMember.GroupId) )
            {
                if( String.valueOf(theGroupMember.UserOrGroupId).left(3) == '005' )
                {
                    mapPublicGroupMembers.get(theGroupMember.GroupId).add(theGroupMember.UserOrGroupId);
                }
            }
            else
            {
                if( String.valueOf(theGroupMember.UserOrGroupId).left(3) == '005' )
                {
                    mapPublicGroupMembers.put( theGroupMember.GroupId, new List<Id>{theGroupMember.UserOrGroupId} );
                }
            }
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String strQuery = 'SELECT  OpportunityId,UserOrGroupId, OpportunityAccessLevel, RowCause FROM OpportunityShare ' + 
                    'WHERE Opportunity.Account_Name__c = \'STAR\' ORDER BY Opportunity.Name';
        return Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        String strKey ='';
        
        for( sObject s : scope)
        {
            OpportunityShare theShare = (OpportunityShare)s;
            if( String.valueOf(theShare.UserOrGroupId).left(3) == '005' )
            {
                strKey = String.valueOf(theShare.OpportunityId)+ String.valueOf(theShare.UserOrGroupId);
                
                mapStarAccess.put( strKey, 
                    new STAR_Access__c (Name = strKey, OpportunityId__c = theShare.OpportunityId,
                        UserId__c = theShare.UserOrGroupId,OpportunityAccessLevel__c = theShare.OpportunityAccessLevel,
                        RowCause__c = theShare.RowCause )  );
            }
            else if( String.valueOf(theShare.UserOrGroupId).left(3) == '00G' )
            {
                if( mapPublicGroupMembers.containsKey(theShare.UserOrGroupId) )
                {
                    for( Id theUserId : mapPublicGroupMembers.get(theShare.UserOrGroupId) )
                    {
                        strKey = String.valueOf(theShare.OpportunityId) + String.valueOf(theUserId);
                        mapStarAccess.put( strKey , new STAR_Access__c (Name = strKey,OpportunityId__c = theShare.OpportunityId,
                                UserId__c = theUserId, OpportunityAccessLevel__c = theShare.OpportunityAccessLevel,
                                RowCause__c = theShare.RowCause));
                    }
                }
            }
        }
        
        Database.insert( mapStarAccess.values() );
        mapStarAccess = null;
    }

    global void finish(Database.BatchableContext BC)
    {
        //code block added by Nisha on Aug 29,2017
        //NOTE: This class's report is monitered via dashboard so not critically required to notify admins for success/failures
        //invoke batch class to delete old records
        Database.executeBatch(new MassDeleteStarAccessDataBatch(), 2000);
    }
}