#  Salesforce Assessment: Project Management App

 A complete project and task management solution built on Salesforce:
- Custom Metadata (Project, Milestone, To-Do)
- Apex Controllers and Logic
- Lightning Web Components (LWC)
- Declarative Configuration (Formulas, Validation Rules)
- SFDX-based deployment structure

Designed with best practices for scalability, performance, and reusability.

---
##  Features

- Create a **Project** with one or more **Milestones**
- Add multiple **To-Do items** under each Milestone
- Automatically calculate:
  - Milestone % Complete based on To-Dos
  - Project % Complete based on Milestones
  - Status auto-derived (Not Started, In Progress, Complete)
- Prevent manual override of calculated status
- Display live **project overview** upon submission

---

##  Technologies Used

- Apex (Bulk-safe trigger architecture + test classes)
- LWC (Parent + Child components)
- SFDX project structure
- Salesforce Developer Org

---

## 📐 Design Decisions

## 🗂️ Data Model Setup: Objects, Fields, and Relationships

The solution is structured around three core custom objects that reflect a real-world project management model:

### 🔷 1. Project__c

- Represents a high-level project record
- Used to group multiple milestones
- **Key Fields**:
  - `Name`: Text (Standard field for identification)
  - `Percent_Complete__c`: Percent (calculated from related milestones via Apex)
  - `Status__c`: Formula (derived from percent complete — Not Started, In Progress, Complete)

### 🔷 2. Milestone__c

- Represents a key phase or deliverable within a project
- Related to `Project__c` via a **Master-Detail** relationship
- Can contain multiple To-Dos
- **Key Fields**:
  - `Name`: Text
  - `Project__c`: Master-Detail to Project__c
  - `Percent_Complete__c`: Percent (calculated from related To-Dos via Apex)
  - `Status__c`: Formula (based on % complete)

### 🔷 3. To_Do__c

- Represents an individual task that must be completed within a milestone
- Related to `Milestone__c` via a **Master-Detail** relationship
- **Key Fields**:
  - `Name`: Text
  - `Milestone__c`: Master-Detail to Milestone__c
  - `Status__c`: Picklist (Not Started, In Progress, Complete)

---

### 🔗 Relationship Hierarchy

```
Project__c (1)
├── Milestone__c (Master-Detail, Many)
    └── To_Do__c (Master-Detail, Many)
```

- **Cascade delete** is enforced via master-detail setup — deleting a project will remove its milestones and associated to-dos.
- **Roll-up fields are intentionally avoided** in favor of Apex logic, allowing for complex calculations (averages, weights, conditions).

---

###  Why This Structure?

- Simulates real-world nested task/project management
- Master-detail ensures referential integrity and automatic ownership
- Easy to extend with additional fields like due dates, priority, owners, etc.
- Clear upward and downward traversal using relationship queries
- LWC can interact with the full nested structure using SOQL's relationship queries

---

### 🔁 No Roll-Up Summary Fields
Instead of using roll-up summary fields, It has been implemented **custom Apex logic** to calculate percent complete using triggers and service classes. This gives us:
- Full control over the calculation logic
- Flexibility for future enhancements (e.g. weighting, filters)
- Avoidance of roll-up field limitations (e.g. max limits, average not supported)

### 🔧 Trigger + Handler Pattern
To ensure scalability and best practices, It has been used the **Trigger → Handler → Service** pattern:

| Layer | Purpose | Files |
|-------|---------|-------|
| **Triggers** | Detect insert/update/delete events | `ToDoTrigger.trigger`, `MilestoneTrigger.trigger` |
| **Handlers** | Extract impacted record IDs and delegate logic | `ToDoTriggerHandler.cls`, `MilestoneTriggerHandler.cls` |
| **Service** | Execute calculation logic, DML updates, and project cascade | `MilestoneService.cls` |

### 💡 Apex Logic Handles:
- ✅ Recalculating `Milestone__c.Percent_Complete__c` based on To-Dos
- ✅ Recalculating `Project__c.Percent_Complete__c` based on Milestones
- ✅ Prevents duplicate queries or DML with bulk-safe batching
- ✅ Fully testable logic, independently from the UI

### 🧩 Lightning Web Component (LWC) Architecture: Design Rationale

The front-end user experience is built with a **modular LWC design** to balance **performance**, **reusability**, and **maintainability**.

### 🧩 Component Structure

| Component          | Responsibility |
|--------------------|----------------|
| `projectManager`   | Parent LWC that handles the entire project creation workflow, collects data from children, and displays an overview |
| `milestoneInput`   | Child LWC that manages milestone details and associated to-dos, emits structured data back to the parent |

---

###  Why This Architecture?

#### ✅ Best Practices
- **Separation of Concerns**: Each component has a focused responsibility, making the code easier to understand, test, and maintain.
- **Single Source of Truth**: The parent holds and manages the entire data structure, reducing state duplication or sync bugs.
- **Reusable Components**: `milestoneInput` can be reused in modals, record pages, or editing scenarios in the future.

#### ⚙️ Performance
- **Client-side composition** reduces server round-trips: all milestone and To-Do logic happens in the browser until submission.
- **Minimal re-rendering**: Changes are scoped to child component DOM trees, improving efficiency even with many milestones or to-dos.

####  Maintainability & Scalability
- Easy to:
  - Add new fields to Milestones or To-Dos
  - Add form validation logic
  - Isolate errors or loading states per milestone
- Clean event-driven communication using `CustomEvent` between child and parent

####  Alternative Considered: Single Monolithic LWC
- Initially considered for simplicity, but rejected due to:
  - Over-complex JavaScript logic handling multiple nested levels
  - Difficult to maintain and test each section independently
  - Performance hit when handling many DOM elements in a single LWC

---

### 📊 LWC's Data Flow Summary

```
projectManager (parent)
├── milestoneInput[] (children)
       └── emits milestone object { name, todos[] }
           └── todo: { name, status }
```

- Data is stored in the parent and updated in real-time as users interact
- On submission, the full structure is sent to Apex for record creation

---

This architecture ensures the application is flexible, scalable, and aligns with Salesforce LWC standards.

### 🧰 Declarative Enhancements
- `Status__c` on Project and Milestone calculated via **formula fields** based on % complete
- Minimal validation rules needed (most logic handled via Apex and UI)

---

## ⚙️ Setup Steps

### 1. Authenticate Dev Hub
```bash
sfdx auth:web:login --setdefaultdevhubusername -a DevHub
```

### 2. Create Scratch Org
```bash
sfdx force:org:create -s -f config/project-scratch-def.json -a ProjectDev
```

### 3. Push Source
```bash
sfdx force:source:push
```

### 4. Assign Permission Set
```bash
sfdx force:user:permset:assign -n ProjectAppAccess
```

### 5. Open the Org
```bash
sfdx force:org:open
```

---

## 👤 User Guide

### Step 1: Navigate to the `Project Manager` App Page
- Add `projectManager` LWC to any App Page using the Lightning App Builder
- Save and activate it for your user profile

### Step 2: Create a Project
- Enter a project name
- Add one or more Milestones
- Under each milestone, add To-Do items
- Click **Create Project**

### Step 3: View Overview
- After saving, the app displays the project structure:
  - Each Milestone with its calculated % Complete
  - Each To-Do with its name and status

---

## 📁 Folder Structure

```
force-app/main/default/
├── classes/
│   └── Apex controllers, service classes, and tests
├── lwc/
│   ├── projectManager/
│   └── milestoneInput/
├── objects/
│   └── Metadata for Project, Milestone, To-Do
├── permissionsets/
│   └── ProjectAppAccess.permissionset-meta.xml
manifest/
│   └── package.xml
```

---

## 🧪 Test Coverage

- 100% Apex test coverage for all logic and edge cases
- Validates:
- Input structure
- Record creation logic
- Overview retrieval
- Exception handling

- Apex class `ProjectManagerController.cls` covered by `Test_ProjectManagerController.cls`
- Apex class `MilestoneService.cls` covered by `Test_MilestoneService.cls`
- Apex class `MilestoneTriggerHandler.cls` covered by `Test_MilestoneTriggerHandler.cls`
- Apex class `ProjectManagerController.cls` covered by `Test_ProjectManagerController.cls`
- Apex class `ToDoTriggerHandler.cls` covered by `Test_ToDoTriggerHandler.cls`

---

## 📤 Submission

- Deployable via SFDX
- Fully packaged for GitHub or Dropbox submission
- All logic isolated and commented for clarity

---

## ✅ QA & Testing Sign-Off

Manual testing and test classes confirm this project meets all functional and technical requirements:

### 🔎 Manual Functionality Verification
- ✅ Project creation via LWC form
- ✅ Milestone and To-Do nested inputs function as expected
- ✅ Apex logic correctly calculates % complete at all levels
- ✅ Live overview updates immediately after submission
- ✅ Status formula fields reflect real-time progress
- ✅ Responsive layout and user-friendly component behavior

###  Apex Unit Test Coverage
- ✅ 100% test coverage across all Apex classes and triggers:
  - `ProjectManagerController`
  - `MilestoneService`
  - `MilestoneTriggerHandler`
  - `ToDoTriggerHandler`
- ✅ Assertions validate:
  - Relationships
  - Calculations
  - Exception handling
  - Edge cases (empty milestone/todo sets)

### 🧼 Code Quality & Deployment
- ✅ All metadata included in `package.xml`
- ✅ Folder structure follows SFDX standards
- ✅ Uses modern LWC patterns and Apex best practices
- ✅ Successfully deployed to scratch org and tested in runtime

---

## 🙋 Author Notes

- Built for internal Salesforce Lightning users
- Ready for future enhancements like due dates, Gantt charts, or reports
- Built by Vinicius Figueira
---



