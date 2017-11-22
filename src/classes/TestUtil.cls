/*********************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      10 August 2012
@Description:       Utility to prepare Test Data for Test Classes. 
------------------------------------------------------------------------------
@Last Modified By : 	Nisha Agrawal 
@Last Modified Date : 	26 Jul, 2017 
@Description : 			Removed methods for Object_Description class
--------------------------------------------------------------------------------
@Last Modified By :     Nisha Agrawal 
@Last Modified Date :   28 Sep, 2017 
@Description :          Removed methods for OAuth_Token object
*********************************************************************************/

@isTest(SeeAllData=false)
public class TestUtil 
{
	public static User createTestUser(String strEmail, String strAlias,  Id profileId)
	{
		User objUser = new User(alias = strAlias, email=strEmail, emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = profileId, timezonesidkey='America/Los_Angeles', username= strEmail);
                                 
		return objUser;
	}
	
	public static List<User> createTestUsers(Id profileId, integer intNumOfUsers)
	{
		List<User> lstUsers = new List<User>();
		
		for(Integer i = 100; i < intNumOfUsers + 100; i++) {
			User objUser = new User(alias = 'nUser' + i, email='newuser' + i +'@test.test', emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = profileId, timezonesidkey='America/Los_Angeles', username= 'newuser'+ i + '@test.test');
            lstUsers.add(objUser);                                          
		}
		return lstUsers;
	}
    
    public static List<User> createTestUsers(List<Profile> lstProfile, integer intNumOfUsers)
	{
		List<User> lstUsers = new List<User>();
		
		String strProfileName='';
		string strUserName='';
		Integer UserIndex = 0;
		for(Profile objProfile : lstProfile) {
			strProfileName =  objProfile.Name.replace(' ', '');
			strProfileName = ((strProfileName.length() >= 10 ) ? strProfileName.substring(0, 10): strProfileName) ;
			for(Integer i = 0; i < intNumOfUsers; i++) {
				//strUserName = strProfileName + '@test.test' + i ;
				strUserName = 'newuser' + UserIndex + '@test.test';
				User objUser = new User(alias = 'nu' + datetime.now().millisecond() + i, email= strUserName, emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US', localesidkey='en_US', 
	                                 profileid = objProfile.Id, timezonesidkey='America/Los_Angeles', username = strUserName);
	            lstUsers.add(objUser);   UserIndex++;                                       
			}
		}
		return lstUsers;
	}
	
    /*public static Course__c createTestCourse() 
    {
        Datetime startDate = Datetime.now().addDays(1);
    	Datetime endDate = startDate.addHours(1);
    	
    	Course__c objCourse = new Course__c(Name = 'UnitTest Course', Start_Date__c = startDate,End_Date__c = endDate, Time_zone__c = 'Europe/Amesterdam', Active__c = true, Training_Id__c ='somefakekey');
    	return objCourse;
    }
    
    public static List<Course__c> createTestCourses(integer intNumOfCourses) 
    {
    	List<Course__c> lstCourses = new List<Course__c>();
    	
    	integer i=0;
    	Datetime startDate;
    	Datetime endDate;
    	
    	for(i=0; i < intNumOfCourses; i++)
    	{
    		startDate = Datetime.now().addDays(i).addHours(i);
	    	endDate = startDate.addHours(1);
    		lstCourses.add(new Course__c(Name = 'UnitTest Course' + i, Start_Date__c = startDate,End_Date__c = endDate, Time_zone__c = 'Europe/Amesterdam', Active__c = true, Training_Id__c ='somefakekey', BrainShark_URL__c = 'www.brainshark.com/brainshark/viewpresentation?pi=z' + i));
    	}    	 
    	return lstCourses;
    }
    
    public static Course__c createTestCompletedCourse() 
    {
    	Datetime startDate = Datetime.now().addMinutes(- 970);
    	Datetime endDate = Datetime.now().addMinutes(-910); 
    	
    	Course__c objCourse = new Course__c(Name = 'UnitTest Course', Start_Date__c = startDate, End_Date__c = endDate, Time_zone__c = 'Europe/Amesterdam', Active__c = true, Training_Id__c ='somefakekey');	 
    	return objCourse;
    }
    
    public static List<Course__c> createTestCompletedCourses(integer intNumOfCourses) 
    {
    	List<Course__c> lstCourses = new List<Course__c>();
    	
    	integer i=0;
    	Datetime startDate;
    	Datetime endDate;
    	
    	for(i=0; i < intNumOfCourses; i++)
    	{
    		startDate = Datetime.now().addHours(i * (-1));
	    	endDate = Datetime.now();
    		lstCourses.add(new Course__c(Name = 'UnitTest Course' + i, Start_Date__c = startDate,End_Date__c = endDate, Time_zone__c = 'Europe/Amesterdam', Active__c = true, Training_Id__c ='somefakekey'));
    	}    	 
    	return lstCourses;
    }*/
          
   /* public static My_Training__c createTestMyTraining(Id courseId, Id attendeeId)
    {
    	My_Training__c objTraining = new My_Training__c(Name = 'Training' , Course__c = courseId , Status__c = 'Open', Registrant_Id__c = 'RegistrantKey', Attendee__c = attendeeId);
    	return objTraining;
    }
    
    public static List<My_Training__c> createTestMyTrainings(Id courseId, List<User> lstAttendees)
    {
    	List<My_Training__c> lstTrainings = new List<My_Training__c>();
    	
    	for(User objAttendee : lstAttendees)
		{
			lstTrainings.add(new My_Training__c(Name = 'Training' , Course__c = courseId , Status__c = 'Open', Registrant_Id__c = 'RegistrantKey', Attendee__c = objAttendee.Id));
		} 
    	return lstTrainings;
    }
    
    public static List<My_Training__c> createTestMyTrainings(List<Course__c> lstCourses, List<User> lstAttendees)
    {
    	List<My_Training__c> lstTrainings = new List<My_Training__c>();
    	    	
    	for(Course__c objCourse : lstCourses)
    	{
    		for(User objAttendee : lstAttendees)
    		{
    			lstTrainings.add(new My_Training__c(Name = 'Training' , Course__c = objCourse.Id , Status__c = 'Open', Registrant_Id__c = 'RegistrantKey', Attendee__c = objAttendee.Id));
    		}
    	}
    	return lstTrainings;
    }*/
}