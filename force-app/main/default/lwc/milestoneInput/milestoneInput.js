import { LightningElement, api, track } from 'lwc';

export default class MilestoneInput extends LightningElement {
    @api index; // Index from parent
    @api milestone = { name: '', todos: [] }; // Milestone state
    todoIndex = 0;

    statusOptions = [
        { label: 'Not Started', value: 'Not Started' },
        { label: 'In Progress', value: 'In Progress' },
        { label: 'Complete', value: 'Complete' }
    ];

    // Handle name change
    handleNameChange(event) {
        this.milestone.name = event.detail.value;
        this.fireChange();
    }

    // Add new empty To-Do
    addTodo() {
        const newTodo = {
            id: this.todoIndex++,
            name: '',
            status: 'Not Started'
        };
        this.milestone.todos = [...this.milestone.todos, newTodo];
        this.fireChange();
    }

    // Remove To-Do by index
    removeTodo(event) {
        const idx = parseInt(event.currentTarget.dataset.index, 10);
        this.milestone.todos.splice(idx, 1);
        this.milestone.todos = [...this.milestone.todos];
        this.fireChange();
    }

    // Handle To-Do name change
    handleTodoNameChange(event) {
        const idx = parseInt(event.currentTarget.dataset.index, 10);
        this.milestone.todos[idx].name = event.detail.value;
        this.fireChange();
    }

    // Handle To-Do status change
    handleTodoStatusChange(event) {
        const idx = parseInt(event.currentTarget.dataset.index, 10);
        this.milestone.todos[idx].status = event.detail.value;
        this.fireChange();
    }

    // Remove milestone: notify parent
    removeMilestone() {
        this.dispatchEvent(new CustomEvent('removemilestone', {
            detail: { index: this.index }
        }));
    }

    // Emit milestone data to parent
    fireChange() {
        this.dispatchEvent(new CustomEvent('milestonechange', {
            detail: {
                index: this.index,
                milestone: this.milestone
            }
        }));
    }
}
