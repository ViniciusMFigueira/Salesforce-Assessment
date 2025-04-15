/******************************
* Trigger Name:  MilestoneTrigger
* Version     : 1.0 
* Created Date    : 10 Apr 2025
* Function    : Trigger on Milestone  (Milestone__c) to call handler method
*
* Modification Log :
* Developer                 Date                Description
* ----------------------------------------------------------------------------                 
* Vinicius Figueira            10 Apr 2025         Initial version created
*****************************/

trigger MilestoneTrigger on Milestone__c (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        MilestoneTriggerHandler.handleMilestoneChange(Trigger.isDelete ? Trigger.old : Trigger.new);
    }
}