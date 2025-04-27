/******************************
*  Class Name  :  Test_ProjectManagerController
* Version          : 1.0 
* Created Date     : Apr 10, 2025
* Function         : Test class for ProjectManagerController
* Modification Log :

* Developer                         Date                   Description
* ----------------------------------------------------------------------------                 
* Vinicius FIGUEIRA            10/Apr/2025            First Version
*****************************/

@isTest
public with sharing class Test_ProjectManagerController {

      //Test full flow: create project with milestones and todos.
     
    @isTest
    static void testCreateFullProjectAndOverview() {
       
        // Build mock input for LWC request
        ProjectManagerController.ToDoInput todo1 = new ProjectManagerController.ToDoInput();
        todo1.name = 'Design Wireframes';
        todo1.status = 'Complete';

        ProjectManagerController.ToDoInput todo2 = new ProjectManagerController.ToDoInput();
        todo2.name = 'Review Requirements';
        todo2.status = 'Not Started';

        ProjectManagerController.MilestoneInput milestone1 = new ProjectManagerController.MilestoneInput();
        milestone1.name = 'Planning Phase';
        milestone1.todos = new List<ProjectManagerController.ToDoInput>{ todo1, todo2 };

        ProjectManagerController.MilestoneInput milestone2 = new ProjectManagerController.MilestoneInput();
        milestone2.name = 'Execution Phase';
        milestone2.todos = new List<ProjectManagerController.ToDoInput>(); // Empty To-Do list (edge case)

        ProjectManagerController.ProjectInput projectInput = new ProjectManagerController.ProjectInput();
        projectInput.name = 'New Website Launch';
        projectInput.milestones = new List<ProjectManagerController.MilestoneInput>{ milestone1, milestone2 };

        // Call Apex method to insert full project structure
        Test.startTest();
        Id projectId = ProjectManagerController.createFullProject(projectInput);
        Test.stopTest();

        // Validate project was created
        Project__c createdProject = [
            SELECT Id, Name FROM Project__c WHERE Id = :projectId
        ];
        System.assertEquals('New Website Launch', createdProject.Name);

        // Validate related milestones
        List<Milestone__c> milestones = [
            SELECT Id, Name, Project__c FROM Milestone__c WHERE Project__c = :projectId
        ];
        System.assertEquals(2, milestones.size());

        // Validate related To-Dos
        List<To_Do__c> todos = [
            SELECT Id, Name, Status__c FROM To_Do__c WHERE Milestone__c IN :milestones
        ];
        System.assertEquals(2, todos.size());

        // Call overview method and validate structure
        Project__c overview = ProjectManagerController.getProjectStructure(projectId);
        System.assertEquals(projectId, overview.Id);
        System.assertEquals(2, overview.Milestones__r.size());

        
    }

    /**
     * Test input validation - missing project name.
     */
    @isTest
    static void testCreateProjectFailsWithoutName() {
        ProjectManagerController.ProjectInput input = new ProjectManagerController.ProjectInput();
        input.name = null; // Should fail

        Test.startTest();
        try {
            ProjectManagerController.createFullProject(input);
            System.assert(false, 'Expected AuraHandledException');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Project name is required.'));
        }
        Test.stopTest();
    }
}
