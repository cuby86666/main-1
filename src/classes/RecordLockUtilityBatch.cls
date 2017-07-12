global with sharing class RecordLockUtilityBatch implements Database.Batchable<sObject> {
    global String strType = ''; //lock: lock record; unlock: unlock record
    global boolean bCleanSuccessfulResult;
    global Map<String, RecordLockId__c> mapRecordLockResult;
    global RecordLockUtilityBatch(String pType) {
        if (pType != null) strType = pType;
        bCleanSuccessfulResult = true;
    }
    global RecordLockUtilityBatch(String pType, Boolean pCleanSuccessfulResult) {
        if (pType != null) strType = pType;
        if (pCleanSuccessfulResult != null) bCleanSuccessfulResult = pCleanSuccessfulResult;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strQuery = 'Select Id, Name, IsSuccess__c, Message__c from RecordLockId__c';
        return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext BC, list<sObject> scope) {
        if (strType == null) return;
        List<RecordLockId__c> lstRecordLockId = (List<RecordLockId__c>)scope;
        mapRecordLockResult = new Map<String, RecordLockId__c>();
        Integer i = 0;
        Id[] aryId = new Id[lstRecordLockId.size()];
        for(RecordLockId__c rec : lstRecordLockId) {
            aryId[i++] = (Id)rec.Name;
            mapRecordLockResult.put(rec.Name, rec);
        }
        
        List<RecordLockId__c> lstUpdate = new List<RecordLockId__c>();
        
        if (strType.equals('lock')) {
            Approval.LockResult[] lockResult = RecordLockUtility.lock(aryId);
            for(Approval.LockResult lr : lockResult) {
                String key = (String)lr.getId();
                System.debug('##### key = ' + key);
                RecordLockId__c rec = mapRecordLockResult.get(key);
                if (rec != null) {
                    rec.IsSuccess__c = lr.isSuccess();
                    if (!lr.isSuccess()) {
                        for(Database.Error err : lr.getErrors()) {
                            rec.Message__c += rec.Message__c + err.getMessage();
                        }
                    }
                    lstUpdate.add(rec);
                    System.debug('##### record id=' + rec.Name + ', is success=' + rec.IsSuccess__c);
                }
            }
            update lstUpdate;
        } else {
        	Approval.UnlockResult[] unlockResult = RecordLockUtility.unlock(aryId);
            for(Approval.UnlockResult lr : unlockResult) {
                String key = (String)lr.getId();
                System.debug('##### key = ' + key);
                RecordLockId__c rec = mapRecordLockResult.get(key);
                if (rec != null) {
                    rec.IsSuccess__c = lr.isSuccess();
                    if (!lr.isSuccess()) {
                        for(Database.Error err : lr.getErrors()) {
                            rec.Message__c += rec.Message__c + err.getMessage();
                        }
                    }
                    lstUpdate.add(rec);
                    System.debug('##### record id=' + rec.Name + ', is success=' + rec.IsSuccess__c);
                }
            }
            update lstUpdate;
        }
        //clean up data
        if (bCleanSuccessfulResult) {
            List<RecordLockId__c> lstDelete = [Select Id, Name, IsSuccess__c from RecordLockId__c Where IsSuccess__c = true];
            delete lstDelete;
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}