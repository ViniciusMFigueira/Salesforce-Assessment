/******************************
*  Class Name  :  Test_ToDoTriggerHandler
* Version          : 1.0 
* Created Date     : Apr 10, 2025
* Function         : Test class for ToDoTriggerHandler
* Modification Log :

* Developer                         Date                   Description
* ----------------------------------------------------------------------------                 
* Vinicius FIGUEIRA            10/Apr/2025            First Version
*****************************/

@isTest
public class Test_ToDoTriggerHandler {
    @isTest
    static void testMilestonePercentCompleteUpdate() {
        //  Create project and milestone
        Project__c project = new Project__c(Name = 'Project A');
        insert project;

        Milestone__c milestone = new Milestone__c(Name = 'Milestone A', Project__c = project.Id);
        insert milestone;

        //  Add two To-Dos, one completed and one not
        To_Do__c t1 = new To_Do__c(Name = 'Task 1', Milestone__c = milestone.Id, Status__c = 'Complete');
        To_Do__c t2 = new To_Do__c(Name = 'Task 2', Milestone__c = milestone.Id, Status__c = 'Not Started');
        insert new List<To_Do__c>{ t1, t2 };

        //  Validate Milestone is 50% complete
        milestone = [SELECT Percent_Complete__c FROM Milestone__c WHERE Id = :milestone.Id];
        System.assertEquals(50, milestone.Percent_Complete__c);

        //  Mark second To-Do as complete → should update milestone to 100%
        t2.Status__c = 'Complete';
        update t2;

        milestone = [SELECT Percent_Complete__c FROM Milestone__c WHERE Id = :milestone.Id];
        System.assertEquals(100, milestone.Percent_Complete__c);

        //  Delete one To-Do → still should remain 100%
        delete t1;

        milestone = [SELECT Percent_Complete__c FROM Milestone__c WHERE Id = :milestone.Id];
        System.assertEquals(100, milestone.Percent_Complete__c); // 1/1 completed
    }
}
