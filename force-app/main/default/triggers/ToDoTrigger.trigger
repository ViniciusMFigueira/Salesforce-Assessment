/******************************
* Trigger Name:  ToDoTrigger
* Version     : 1.0 
* Created Date    : 10 Apr 2025
* Function    : Trigger on To-Do  ( To_Do__c) to call handler method
*
* Modification Log :
* Developer                 Date                Description
* ----------------------------------------------------------------------------                 
* Vinicius Figueira            10 Apr 2025         Initial version created
*****************************/

trigger ToDoTrigger on To_Do__c (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            ToDoTriggerHandler.handleToDoChange(Trigger.newMap.keySet());
        } else if (Trigger.isDelete) {
            ToDoTriggerHandler.handleToDoChange(Trigger.oldMap.keySet());
        }
    }
}