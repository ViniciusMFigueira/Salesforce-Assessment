/******************************
*  Class Name  :  MilestoneTriggerHandler
* Version          : 1.0 
* Created Date     : Apr 10, 2025
* Function         : Handler class of MilestoneTrigger
* Modification Log :

* Developer                         Date                   Description
* ----------------------------------------------------------------------------                 
* Vinicius FIGUEIRA            10/Apr/2025            First Version
*****************************/

public with sharing class MilestoneTriggerHandler {
    /**
     * Handles project progress update when Milestones are changed.
     * @param milestones - List of Milestones affected by insert/update/delete/undelete
     */
    public static void handleMilestoneChange(List<Milestone__c> milestones) {
        Set<Id> projectIds = new Set<Id>();

        // Extract all associated Project Ids from the changed milestones
        for (Milestone__c ms : milestones) {
            if (ms.Project__c != null) {
                projectIds.add(ms.Project__c);
            }
        }

        // Trigger project percent update only if we have related projects
        if (!projectIds.isEmpty()) {
            MilestoneService.updateProjectProgress(projectIds);
        }
    }
}