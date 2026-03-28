<!-- grkr:checkpoint stage=research task=issue-13-underspecified-task version=1 -->
I will begin by reading the `spec.md` and `README.md` files to understand the project's purpose and architecture.
I will examine the contents of `.grkr/tasks/issue-13-underspecified-task/research.md` and `progress.json` to see if any research has already been conducted for this issue.
I will now read the `worker-refuse-issue.sh` and `worker-exec-issue.sh` scripts to understand the system's current handling of underspecified tasks.
I will read `doctor.sh` to assess its completeness and then proceed to generate the research document for Issue #13, providing the output in Markdown format as requested.
I will now generate the research document for Issue #13 as requested.

### Research for Issue #13: Underspecified task

**Problem Statement:**
The issue "Underspecified task" with the body "Do something with the codebase" is critically underspecified. It lacks any actionable instructions, goals, or constraints. An autonomous agent cannot safely or effectively "do something" without a clear objective, defined scope, and measurable acceptance criteria.

**Current System Behavior:**
The Kokoko AI agent is designed to execute specific tasks defined in GitHub issues through a structured workflow (Research -> Plan -> Decision -> Implement -> Test). The current system requires a non-empty, meaningful problem description to generate a viable research document and implementation plan. When faced with a vague instruction like this, the agent's decision gate (Stage 3) is expected to trigger a "refusal" flow to prevent arbitrary or destructive changes.

**Relevant Files/Modules:**
Potentially all files in the repository are "relevant" due to the global nature of the request, which increases the risk of unintended side effects if any change were attempted.

**Assumptions:**
1. The user intended this issue as a functional test for the agent's ability to identify and refuse underspecified tasks.
2. No actual codebase modification is currently desired by the stakeholder under this specific issue ID.

**Unknowns:**
1. The intended functional area for improvement (e.g., supervisor loop, worker scripts, library functions, or documentation).
2. The specific problem the user wants to solve or the feature they want to add.
3. The desired outcome or "definition of done" for this task.

**Risks:**
1. **System Instability:** Any arbitrary change ("doing something") could introduce regressions in the supervisor loop or worker scripts.
2. **Resource Waste:** Executing a full workflow on a vague task consumes computational resources (Gemini API calls, GitHub API limits) without providing value.
3. **Security/Policy Violations:** Without a clear scope, the agent might inadvertently modify sensitive configurations or bypass established safety boundaries.

**Inferred Acceptance Criteria:**
1. The issue must be updated with a clear title and description that identifies a specific problem or feature request.
2. The description must include at least one concrete example of the desired change.
3. Acceptance criteria must be explicitly listed to allow for automated or manual verification.
4. If the task is large, it should be broken down into smaller, well-defined sub-tasks.

---
**Summary for next stage (Plan):**
The research confirms that this issue is a primary candidate for **refusal** under the "underspecified" class. The plan should focus on documenting this refusal and providing guidance to the user on how to provide a better task specification.
