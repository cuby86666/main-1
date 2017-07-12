/*********************************************************************************************
@Created By :       Prakhar Gupta
@Created Date : 	09 Jan 2015
Description : 		Test Class data for submitCaseController
********************************************************************************************/

/*********************************************************************************************
@Modified By :      Amrutha R
@Modified Date : 	15 Jan 2015
Description : 		code cleaned up/ modified as per best practices
********************************************************************************************/
@isTest
                        
global class MockHttpResponseGenerator implements HttpCalloutMock 
{
       global HTTPResponse respond(HTTPRequest request) 
       {
       		// Optionally, only send a mock response for a specific endpoint and method.
       		System.assertEquals('POST', request.getMethod());
       		String strPrivateKey = '6LfGGgATAAAAADJaNz3XRVqx8JYHO_cDoSF7ivOO';
       		String strRemoteHost = '127.0.0.1';
       		String strRecaptchaChallenge = '111';
       		String strRecaptchaResponse = '111';
       		String strBody = 'true privatekey=' + strPrivateKey +'&remoteip='  + StrRemoteHost +
	            		'&challenge=' + strRecaptchaChallenge +'&response='  + strRecaptchaResponse;
        	HttpResponse response = new HttpResponse();
        	response.setHeader('Content-Type', 'application/json');
        	response.setBody(strBody);
        	response.setStatusCode(200);
        	return response;
    }
}