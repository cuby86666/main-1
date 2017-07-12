public without sharing class AptsAgreementActionAsync {
@future

    public static void removeSharing( List<Id> agmtIds)
    {
		try{
		//delete the shares not needed anymore
	    if(agmtIds.size()>0){
	    	System.debug('Deleted Ids'+ agmtIds);
	    	List <Apttus__APTS_Agreement__Share> delAgmtShares = [select id from  Apttus__APTS_Agreement__Share where parentId in :agmtIds and RowCause='Approval_Sharing__c'];
	    	System.debug('Deleted shares'+ delAgmtShares);
	    	if(delAgmtShares != null && delAgmtShares.size()>0){
		    	Database.DeleteResult[] agmtShareDelResult = Database.delete(delAgmtShares);
		    	System.debug('Agreement share delete results'+agmtShareDelResult);
	    	}
	    		
	    }
		}catch(exception e){
			System.debug('Exception when deleting custom shares. '+e);
		}

    }

}