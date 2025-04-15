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

     // Updates the Percent_Complete__c of Milestones based on their related To_Do__c records.
     // Set of Milestone__c IDs that need recalculating.

    public static void updateMilestoneProgress(Set<Id> milestoneIds) {
        if (milestoneIds == null || milestoneIds.isEmpty()) return;

        // Security Check: Ensure user has permission to read To-Dos and update Milestones
        if (!Schema.sObjectType.To_Do__c.isAccessible() || !Schema.sObjectType.Milestone__c.isUpdateable()) {
            throw new System.NoAccessException('Missing read or update permissions for To-Do or Milestone.');
        }

      
        Map<Id, List<To_Do__c>> milestoneToToDos = new Map<Id, List<To_Do__c>>();
        Map<Id, Id> milestoneToProject = new Map<Id, Id>();

        // Query all To-Dos linked to given Milestones and group them
        for (To_Do__c t : [
            SELECT Id, Status__c, Milestone__c,
                   Milestone__r.Project__c
            FROM To_Do__c
            WHERE Milestone__c IN :milestoneIds
        ]) {
            if (t.Milestone__c != null) {
                // Group To-Dos by Milestone
                milestoneToToDos
                    .computeIfAbsent(t.Milestone__c, new List<To_Do__c>())
                    .add(t);

                if (!milestoneToProject.containsKey(t.Milestone__c)) {
                    milestoneToProject.put(t.Milestone__c, t.Milestone__r.Project__c);
                }
            }
        }

        List<Milestone__c> milestonesToUpdate = new List<Milestone__c>();

        // Calculate % complete for each milestone and prepare for update
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

            // Calculate % complete safely
            Decimal percent = total == 0 ? 0 : ((Decimal)completed / total) * 100;

            milestonesToUpdate.add(new Milestone__c(
                Id = milestoneId,
                Percent_Complete__c = percent.setScale(2)
            ));
        }

        // Update Milestones in bulk
        if (!milestonesToUpdate.isEmpty()) {
            update milestonesToUpdate;
        }

        // Cascade project progress updates
        Set<Id> projectIds = new Set<Id>(milestoneToProject.values());
        if (!projectIds.isEmpty()) {
            updateProjectProgress(projectIds);
        }
    }

     // Updates Percent_Complete__c on Projects based on average of all their Milestones.
     // Set of Project__c IDs to recalculate
    public static void updateProjectProgress(Set<Id> projectIds) {
        if (projectIds == null || projectIds.isEmpty()) return;

        // Security Check
        if (!Schema.sObjectType.Project__c.isUpdateable() || !Schema.sObjectType.Milestone__c.isAccessible()) {
            throw new System.NoAccessException('Missing permission for Project or Milestone.');
        }

        // Group milestones by Project
        Map<Id, List<Milestone__c>> projectToMilestones = new Map<Id, List<Milestone__c>>();
        for (Milestone__c ms : [
            SELECT Id, Project__c, Percent_Complete__c
            FROM Milestone__c
            WHERE Project__c IN :projectIds
        ]) {
            projectToMilestones
                .computeIfAbsent(ms.Project__c, new List<Milestone__c>())
                .add(ms);
        }

        List<Project__c> updates = new List<Project__c>();

        // For each project, calculate average % complete from its milestones
        for (Id projId : projectToMilestones.keySet()) {
            List<Milestone__c
