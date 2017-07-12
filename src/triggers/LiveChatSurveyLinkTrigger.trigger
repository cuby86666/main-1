/*********************************************************************************************
@Created By :      Venkateshwar G
@Created Date :    3 Oct 2016
Description :      Community Live Chat survey link trigger to link the Chat surveys given by the user
                   to the respective chat transcript and also all the related surveys are deleted when the trancript is deleted.                   
****************************************************************************************************/

trigger LiveChatSurveyLinkTrigger on LiveChatTranscript (after insert, before delete) {
// Method call to link the respective surveys to respective Transcripts records
   if (Trigger.isAfter && Trigger.isInsert) {
      CommunityLiveAgentChatSurveyController.linkChatSurveyToTranscript(Trigger.new); 
   }
// Method call to delete the all the related chat suveys answers when the chat transcript is deleted
  if (Trigger.isBefore && Trigger.isDelete) { 
     CommunityLiveAgentChatSurveyController.deleteChatSurveyOfTranscript(Trigger.old);   
  }           


}