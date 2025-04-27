/******************************
*  Class Name  :  ProjectManagerController
* Version          : 1.0 
* Created Date     : Apr 10, 2025
* Function         : Apex Controller class for Project Manager component
* Modification Log :

* Developer                         Date                   Description
* ----------------------------------------------------------------------------                 
* Vinicius FIGUEIRA            10/Apr/2025            First Version
*****************************/

public with sharing class ProjectManagerController {

    // Wrapper classes to accept structured input from LWC
    public class ToDoInput {
        @AuraEnabled public String name;
        @AuraEnabled public String status;
    }

    public class MilestoneInput {
        @AuraEnabled public String name;
        @AuraEnabled public List<ToDoInput> todos;
    }

    public class ProjectInput {
        @AuraEnabled public String name;
        @AuraEnabled public List<MilestoneInput> milestones;
    }

     //Create full project with milestones and to-Dos
     
    @AuraEnabled
    public static Id createFullProject(ProjectInput input) {
        if (input == null || String.isBlank(input.name)) {
            throw new AuraHandledException('Project name is required.');
        }

        Project__c project = new Project__c(Name = input.name);
        insert project;

        List<Milestone__c> milestones = new List<Milestone__c>();
        List<To_Do__c> todos = new List<To_Do__c>();
        Map<String, Id> milestoneNameToId = new Map<String, Id>();

        // Create milestones and collect To-Dos
        for (MilestoneInput m : input.milestones) {
            Milestone__c ms = new Milestone__c(Name = m.name, Project__c = project.Id);
            milestones.add(ms);
        }

        insert milestones;

        // Map back inserted milestone Ids
        for (Integer i = 0; i < milestones.size(); i++) {
            milestoneNameToId.put(input.milestones[i].name, milestones[i].Id);
        }

        // Create To-Dos using mapped milestone Ids
        for (MilestoneInput m : input.milestones) {
            Id msId = milestoneNameToId.get(m.name);

            for (ToDoInput t : m.todos) {
                todos.add(new To_Do__c(
                    Name = t.name,
                    Status__c = t.status,
                    Milestone__c = msId
                ));
            }
        }

        if (!todos.isEmpty()) {
            insert todos;
        }

        return project.Id;
    }

    
     //Get project overview: project, milestones, todos
     
     @AuraEnabled(cacheable=true)
     public static Project__c getProjectStructure(Id projectId) {
         return [
             SELECT Id, Name, Percent_Complete__c,
                    (SELECT Id, Name, Percent_Complete__c, Status__c
                     FROM Milestones__r)
             FROM Project__c
             WHERE Id = :projectId
             LIMIT 1
         ];
     }
     
}
