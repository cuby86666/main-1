/*------------------------------------------------------------------------------------------------------------------
 * Created By   : Baji
 * Created Date : 22 Jan,2017
 * Description   : To update file details on risk assessment based on the files uploaded, edited or deleted.
 ------------------------------------------------------------------------------------------------------------------*/
trigger ComplianceRiskAttachment on Attachment (after insert, after update, before delete) {
    if(trigger.isInsert || trigger.isUpdate)
      {
          ComplianceRiskAttachmentTrigger.captureFileDetailsRiskAssmt(trigger.new) ;
      }
  
    if(trigger.isDelete)
      {
          ComplianceRiskAttachmentTrigger.removeFileDetailsRiskAssmt(trigger.old) ;
      }
}