public with sharing class RecordLockUtility {
    public static Approval.LockResult[] lock(Id[] aryId) {
        return Approval.lock(aryId, false);
    }
    
    public static Approval.UnlockResult[] unlock(Id[] aryId) {
        return Approval.unlock(aryId, false);
    }
}