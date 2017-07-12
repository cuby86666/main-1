trigger CMD_Request_BeforeInsert on CMD_Request__c (before insert) {
    if( Trigger.isInsert || Trigger.isUpdate ) {
		CMD_Request_Trigger.eraseRequestFields( Trigger.New );
    }
}