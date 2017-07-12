/**This is the utility class.**/
public class Utility {
	
    /** Retrieve the record from SObject **/
    public static List<SObject> retrieveObjectRecord(String sql) 
    {
        return Database.query(sql);
    }

    /**
     * Construct and build sql statement based on the fields name,
     * object name, and criteria.
     **/
    public static String buildSQLStatement(String fields, String objectName, String criteria) 
    {
        String sql = 'Select ' + fields + ' from ' + objectName + (criteria != null && !''.equals(criteria) ? criteria : '');
        return sql;
    } 
    
    /**
     * Retrieve meta-data fields name from SObject
     **/
    public static String getObjectFields(Map<String, Schema.SObjectField> fieldsMap) 
    {
        String ssql = '';
        Boolean bfirst = true;
        for(String fieldName:fieldsMap.keySet()) {
            if(bfirst) {
                ssql = fieldName;
                bfirst = false;
            } else {
                ssql = ssql + ',' + fieldName;
            } 
        }
        return ssql;        
    }
    public static map<String, map<Integer, Date>> DateSpanInQuarter(Integer targetYear) {
    	if(targetYear == null) targetYear = date.today().year();
    	map<String, map<Integer, Date>> rtnMap = new map<String, map<Integer, Date>> {
    		'Q1' => new map<Integer, Date> { 1 => date.newInstance(targetYear, 1, 1), 2 => date.newInstance(targetYear, 3, 31) },
    		'Q2' => new map<Integer, Date> { 1 => date.newInstance(targetYear, 4, 1), 2 => date.newInstance(targetYear, 6, 30) },
    		'Q3' => new map<Integer, Date> { 1 => date.newInstance(targetYear, 7, 1), 2 => date.newInstance(targetYear, 9, 30) },
    		'Q4' => new map<Integer, Date> { 1 => date.newInstance(targetYear, 10, 1), 2 => date.newInstance(targetYear, 12, 31) }
    	}; return rtnMap;
    }
    public static void SendEmail(String subject, list<String> toAddresses, String Body, String AttachmentName, String AttachmentType, String AttachmentBody) {
    	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setSubject(subject);
		email.setToAddresses(toAddresses);
		email.setCharset('UTF-8');
		email.setPlainTextBody(Body);
		if(AttachmentName != null && AttachmentType != null && AttachmentBody != null) {
			Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
			blob csvBlob = Blob.valueOf(AttachmentBody);
			csvAttc.setFileName(AttachmentName);
			if(AttachmentType == 'csv' || AttachmentType == 'excel')
				csvAttc.setContentType('application/vnd.ms-excel');
			csvAttc.setBody(csvBlob);
			email.setFileAttachments(new Messaging.EmailFileAttachment[]{ csvAttc });
		}
		Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}