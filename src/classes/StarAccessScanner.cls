global class StarAccessScanner implements Database.Batchable<sObject>, Database.Stateful
{
    global String query;

    static List<STAR_Access__c> listStarAccess = new List<STAR_Access__c>();
    static Map<String,STAR_Access__c> mapStarAccess = new Map<String,STAR_Access__c>();
    static Set<String> setStarAccessUniqueKeys = new Set<String>(); //OpportunityId + UserId
    global Map<Id,Id> mapUserRoleId = new Map<Id,Id>();
    global Map<Id,Id> mapRoleParentId = new Map<Id,Id>();
    global Map<Id, List<Id>> mapRoleUserIdList = new Map<Id,List<Id>>();
    static Map<Id,List<Id>> mapPublicGroupMembers = new Map<Id,List<Id>>();
    
    global StarAccessScanner()
    {
        query = 'SELECT Name, OpportunityId__c, UserId__c, UserRoleId__c, ';
        query +='      OpportunityAccessLevel__c, RowCause__c ';
        query +='FROM STAR_Access__c ';
        query +='WHERE NOT( RowCause__c = \'Role Hierarchy\') ';        

        listStarAccess = new List<STAR_Access__c>([SELECT Id FROM STAR_Access__c]);
        Database.delete( listStarAccess );
        listStarAccess = null;

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
        
        for( OpportunityShare theShare:
            [
                SELECT  OpportunityId, 
                        UserOrGroupId, 
                        OpportunityAccessLevel, 
                        RowCause 
                FROM OpportunityShare 
                WHERE Opportunity.Account.Name = 'STAR'
                ORDER BY Opportunity.Name
            ])
        {
            if( String.valueOf(theShare.UserOrGroupId).left(3) == '005' )
            {
                mapStarAccess.put( String.valueOf(theShare.OpportunityId)+String.valueOf(theShare.UserOrGroupId) , 
                    new STAR_Access__c
                    (
                        Name = String.valueOf(theShare.OpportunityId)+String.valueOf(theShare.UserOrGroupId),
                        OpportunityId__c = theShare.OpportunityId,
                        UserId__c = theShare.UserOrGroupId,
                        OpportunityAccessLevel__c = theShare.OpportunityAccessLevel,
                        RowCause__c = theShare.RowCause
                    )
                );
                setStarAccessUniqueKeys.add( String.valueOf(theShare.OpportunityId)+String.valueOf(theShare.UserOrGroupId) );
            }
            else if( String.valueOf(theShare.UserOrGroupId).left(3) == '00G' )
            {
                if( mapPublicGroupMembers.containsKey(theShare.UserOrGroupId) )
                {
                    for( Id theUserId : mapPublicGroupMembers.get(theShare.UserOrGroupId) )
                    {
                        mapStarAccess.put( String.valueOf(theShare.OpportunityId)+String.valueOf(theUserId) , 
                            new STAR_Access__c
                            (
                                Name = String.valueOf(theShare.OpportunityId)+String.valueOf(theUserId),
                                OpportunityId__c = theShare.OpportunityId,
                                UserId__c = theUserId,
                                OpportunityAccessLevel__c = theShare.OpportunityAccessLevel,
                                RowCause__c = theShare.RowCause
                            )
                        );
                        setStarAccessUniqueKeys.add( String.valueOf(theShare.OpportunityId)+String.valueOf(theUserId) );
                    }
                }
            }
        }
        
//      mapPublicGroupMembers = null;
/*        
        for( UserRole theRole : [SELECT Id, ParentRoleId FROM UserRole] )
        {
            mapRoleParentId.put( theRole.Id, theRole.ParentRoleId );    
            System.debug('STAN DEBUG: constructor: mapRoleParentId.size() = ' + mapRoleParentId.size()); 
        }
        
        for( User theUser : [SELECT Id, UserRoleId FROM User WHERE NOT(Profile.Name LIKE '%Chatter%')] )
        {
            mapUserRoleId.put( theUser.Id, theUser.UserRoleId ); 
            
            if( mapRoleUserIdList.containsKey(theUser.UserRoleId) )
            {
                mapRoleUserIdList.get(theUser.UserRoleId).add(theUser.Id);
            }
            else
            {
                mapRoleUserIdList.put( theUser.UserRoleId, new List<Id>{theUser.Id} );
            }
        }
*/
/*        
        for( STAR_Access__c theUserAccess : mapStarAccess.values() )
        {
            if( getUsersBosses(theUserAccess.UserId__c).size() > 0 )
            {
                for( Id theBossId : getUsersBosses(theUserAccess.UserId__c)  )
                {
                    if( !(mapStarAccess.containsKey( String.valueOf(theUserAccess.OpportunityId__c)+String.valueOf(theBossId) )) ) 
                    {
                        mapStarAccess.put( String.valueOf(theUserAccess.OpportunityId__c)+String.valueOf(theBossId) , new STAR_Access__c(
                            OpportunityId__c = theUserAccess.OpportunityId__c,
                            UserId__c = theBossId,
                            OpportunityAccessLevel__c = theUserAccess.OpportunityAccessLevel__c,
                            RowCause__c = 'Role Hierarchy'
                        ));
                    }
                } 
            }
        }
*/        
        Database.insert( mapStarAccess.values() );
        mapStarAccess = null;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        for( UserRole theRole : [SELECT Id, ParentRoleId FROM UserRole] )
        {
            mapRoleParentId.put( theRole.Id, theRole.ParentRoleId );    
            System.debug('STAN DEBUG: start: mapRoleParentId.size() = ' + mapRoleParentId.size()); 
        }
        
        
    for( User theUser : [SELECT Id, UserRoleId FROM User WHERE Profile.UserLicense.Name = 'Salesforce'])
        {
            mapUserRoleId.put( theUser.Id, theUser.UserRoleId ); 
            
            if( mapRoleUserIdList.containsKey(theUser.UserRoleId) )
            {
                mapRoleUserIdList.get(theUser.UserRoleId).add(theUser.Id);
            }
            else
            {
                mapRoleUserIdList.put( theUser.UserRoleId, new List<Id>{theUser.Id} );
            }
        }

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<STAR_Access__c> listSBoss = new List<STAR_Access__c>();
        for( sObject theScoped : scope  )
        {
            STAR_Access__c sUser = (STAR_Access__c)theScoped;
            System.debug('STAN DEBUG: sUser.UserRoleId__c = ' + sUser.UserRoleId__c); 
            System.debug('STAN DEBUG: mapRoleParentId.size() = ' + mapRoleParentId.size()); 
            if( mapRoleParentId.containsKey(sUser.UserRoleId__c) ) 
            {   
                for( Id bossId : mapRoleUserIdList.get(mapRoleParentId.get(sUser.UserRoleId__c)) )
                {    
                    System.debug('STAN DEBUF: bossId = ' + bossId); 
                    if( !setStarAccessUniqueKeys.contains(String.valueOf(sUser.OpportunityId__c)+String.valueOf(bossId)) )
                    {    
                        STAR_Access__c sBoss = sUser;
                        sBoss.Name = String.valueOf(sUser.OpportunityId__c) + String.valueOf(bossId);
                        sBoss.UserId__c = bossId;
                        sBoss.RowCause__c = 'Role Hierarchy';
                        listSBoss.add( sBoss );
                    }    

                }
            }    
        }
        System.debug('STAN DEBUG: listSBoss.size() = ' + listSBoss.size()); 
        Database.insert( listSBoss );
    }

    global void finish(Database.BatchableContext BC)
    {
        
    }
// The following codes are ugly, but thats the only way I can think of....
/*
    List<Id> getUsersBosses( Id theUserId )
    {
        List<Id> theBossesIds = new List<Id>();

        if( mapUserRoleId.containsKey(theUserId) )
        {
            if( mapRoleParentId.containsKey(mapUserRoleId.get(theUserId)) )    
            {
                if( mapRoleUserIdList.get(mapRoleParentId.get(mapUserRoleId.get(theUserId))).size() > 0 )
                {
                    theBossesIds.addAll( mapRoleUserIdList.get(mapRoleParentId.get(mapUserRoleId.get(theUserId)))); 
                }
                if( mapRoleParentId.containsKey(mapRoleParentId.get(mapUserRoleId.get(theUserId))))    
                {
                    if( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId)))).size() > 0 )
                    {
                        theBossesIds.addAll( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId))))); 
                    }
                    if( mapRoleParentId.containsKey(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId)))))    
                    {
                        if( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId))))).size() > 0 )
                        {
                            theBossesIds.addAll( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId)))))); 
                        }
                        if( mapRoleParentId.containsKey(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId))))))    
                        {
                            if( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId)))))).size() > 0 )
                            {
                                theBossesIds.addAll( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId))))))); 
                            }
                        }
                    }
                }
            }

            if( mapRoleParentId.containsKey(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId)))))))    
            {
                if( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId))))))).size() > 0 )
                {
                    theBossesIds.addAll( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId)))))))); 
                }
            }

            if( mapRoleParentId.containsKey(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId))))))))   
            {
                if( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId)))))))).size() > 0 )
                {
                    theBossesIds.addAll( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId))))))))); 
                }
            }

            if( mapRoleParentId.containsKey(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId)))))))))    
            {
                if( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId))))))))).size() > 0 )  
                {
                    theBossesIds.addAll( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId)))))))))); 
                }
            }                

            if( mapRoleParentId.containsKey(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId))))))))))    
            {
                if( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId)))))))))).size() > 0 )
                {
                    theBossesIds.addAll( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId))))))))))); 
                }
            }

            if( mapRoleParentId.containsKey(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId)))))))))))    
            {
                if( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId))))))))))).size() > 0 )  
                {
                    theBossesIds.addAll( mapRoleUserIdList.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapRoleParentId.get(mapUserRoleId.get(theUserId)))))))))))); 
                }
            }
        }

        return theBossesIds;
    }
*/
}