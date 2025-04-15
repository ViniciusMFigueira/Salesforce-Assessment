import { LightningElement, track } from 'lwc';
import createFullProject from '@salesforce/apex/ProjectManagerController.createFullProject';
import getProjectStructure from '@salesforce/apex/ProjectManagerController.getProjectStructure';

export default class ProjectManager extends LightningElement {
    @track projectName = '';
    @track milestones = [];
    @track projectOverview;

    milestoneIndex = 0;

    // Handle input change
    handleProjectNameChange(event) {
        this.projectName = event.detail.value;
    }

    // Add a new milestone section
    addMilestone() {
        this.milestones = [
            ...this.milestones,
            { id: this.milestoneIndex++, name: '', todos: [] }
        ];
    }

    // Update milestone input from child
    handleMilestoneChange(event) {
        const { index, milestone } = event.detail;
        this.milestones[index] = milestone;
    }

    // Remove a milestone block
    removeMilestone(event) {
        const index = event.detail.index;
        this.milestones.splice(index, 1);
        this.milestones = [...this.milestones];
    }

    // Submit the full form to Apex
    async submitProject() {
        try {
            const payload = {
                name: this.projectName,
                milestones: this.milestones
            };

            const newProjectId = await createFullProject({ input: payload });
            this.projectOverview = await getProjectStructure({ projectId: newProjectId });

            // Optional: reset form
            this.projectName = '';
            this.milestones = [];
        } catch (error) {
            console.error('Error creating project:', error);
        }
    }
}
