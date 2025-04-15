/******************************
*  Class Name  :  ToDoTriggerHandler
* Version          : 1.0 
* Created Date     : Apr 10, 2025
* Function         : Handler class of ToDoTrigger
* Modification Log :

* Developer                         Date                   Description
* ----------------------------------------------------------------------------                 
* Vinicius FIGUEIRA            10/Apr/2025            First Version
*****************************/

public class ToDoTriggerHandler {
    public static void handleToDoChange(Set<Id> toDoIds) {
        // Query Milestone Ids from affected To-Dos
        Set<Id> milestoneIds = new Set<Id>();
        for (To_Do__c todo : [SELECT Id, Milestone__c FROM To_Do__c WHERE Id IN :toDoIds]) {
            if (todo.Milestone__c != null) {
                milestoneIds.add(todo.Milestone__c);
            }
        }

        if (!milestoneIds.isEmpty()) {
            MilestoneService.updateMilestoneProgress(milestoneIds);
        }
    }
}
