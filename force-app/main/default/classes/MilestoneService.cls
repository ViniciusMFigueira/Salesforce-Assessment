/******************************
*  Class Name  :  MilestoneService
* Version          : 1.0 
* Created Date     : Apr 10, 2025
* Function         : Handles business logic to update Project and Milestone percentage complete
* Modification Log :

* Developer                         Date                   Description
* ----------------------------------------------------------------------------                 
* Vinicius FIGUEIRA            10/Apr/2025            First Version
*****************************/

public with sharing class MilestoneService {

    /**
     * Updates the Percent_Complete__c of Milestones based on their related To_Do__c records.
     * Accepts a Set of Milestone__c IDs that need recalculation.
     */
    public static void updateMilestoneProgress(Set<Id> milestoneIds) {
        if (milestoneIds == null || milestoneIds.isEmpty()) return;

        // Security check: User must have access to read To-Dos and update Milestones
        if (!Schema.sObjectType.To_Do__c.isAccessible() || !Schema.sObjectType.Milestone__c.isUpdateable()) {
            throw new SecurityException('Missing read or update permissions for To-Do or Milestone.');
        }

        Map<Id, List<To_Do__c>> milestoneToToDos = new Map<Id, List<To_Do__c>>();
        Map<Id, Id> milestoneToProject = new Map<Id, Id>();

        // Query To-Dos linked to given Milestones and group them
        for (To_Do__c t : [
            SELECT Id, Status__c, Milestone__c, Milestone__r.Project__c
            FROM To_Do__c
            WHERE Milestone__c IN :milestoneIds
        ]) {
            if (t.Milestone__c != null) {
                // Group To-Dos by Milestone
                if (!milestoneToToDos.containsKey(t.Milestone__c)) {
                    milestoneToToDos.put(t.Milestone__c, new List<To_Do__c>());
                }
                milestoneToToDos.get(t.Milestone__c).add(t);

                // Track the related Project Id
                if (!milestoneToProject.containsKey(t.Milestone__c)) {
                    milestoneToProject.put(t.Milestone__c, t.Milestone__r.Project__c);
                }
            }
        }

        List<Milestone__c> milestonesToUpdate = new List<Milestone__c>();

        // Calculate Percent Complete for each Milestone
        for (Id milestoneId : milestoneToToDos.keySet()) {
            List<To_Do__c> todos = milestoneToToDos.get(milestoneId);
            Integer total = todos.size();
            Integer completed = 0;

            // Count completed tasks
            for (To_Do__c t : todos) {
                if (t.Status__c == 'Complete') {
                    completed++;
                }
            }

            // Calculate Percent Complete safely
            Decimal percent = total == 0 ? 0 : ((Decimal)completed / total) * 100;

            milestonesToUpdate.add(new Milestone__c(
                Id = milestoneId,
                Percent_Complete__c = percent.setScale(2)
            ));
        }

        // Bulk update Milestones
        if (!milestonesToUpdate.isEmpty()) {
            update milestonesToUpdate;
        }

        // Cascade: update related Project progress
        Set<Id> projectIds = new Set<Id>(milestoneToProject.values());
        if (!projectIds.isEmpty()) {
            updateProjectProgress(projectIds);
        }
    }
     //Updates the Percent_Complete__c on Projects based on the average of their Milestones' completion.
     // Accepts a Set of Project__c IDs that need recalculation.
    
    public static void updateProjectProgress(Set<Id> projectIds) {
        if (projectIds == null || projectIds.isEmpty()) return;

        // Security check: User must have access to update Projects and read Milestones
        if (!Schema.sObjectType.Project__c.isUpdateable() || !Schema.sObjectType.Milestone__c.isAccessible()) {
            throw new SecurityException('Missing permission for Project or Milestone.');
        }

        Map<Id, List<Milestone__c>> projectToMilestones = new Map<Id, List<Milestone__c>>();

        // Query Milestones related to given Projects
        for (Milestone__c ms : [
            SELECT Id, Project__c, Percent_Complete__c
            FROM Milestone__c
            WHERE Project__c IN :projectIds
        ]) {
            if (!projectToMilestones.containsKey(ms.Project__c)) {
                projectToMilestones.put(ms.Project__c, new List<Milestone__c>());
            }
            projectToMilestones.get(ms.Project__c).add(ms);
        }

        List<Project__c> updates = new List<Project__c>();

        // For each project, calculate average completion percentage
        for (Id projId : projectToMilestones.keySet()) {
            List<Milestone__c> milestones = projectToMilestones.get(projId);
            Integer total = milestones.size();
            Decimal sum = 0;

            for (Milestone__c ms : milestones) {
                sum += (ms.Percent_Complete__c == null ? 0 : ms.Percent_Complete__c);
            }

            Decimal avgPercent = total == 0 ? 0 : (sum / total);

            updates.add(new Project__c(
                Id = projId,
                Percent_Complete__c = avgPercent.setScale(2)
            ));
        }

        // Bulk update Projects
        if (!updates.isEmpty()) {
            update updates;
        }
    }
}
