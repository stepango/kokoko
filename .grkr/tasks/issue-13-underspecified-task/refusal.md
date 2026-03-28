<!-- grkr:checkpoint stage=refusal task=issue-13-underspecified-task version=1 -->
I will now generate the refusal document for Issue #13, providing a detailed justification for the refusal based on the lack of actionable specifications and outlining the necessary steps for the user to provide a valid task definition.

### Refusal for Issue #13: Underspecified task

**Refusal Summary:**
The task "Do something with the codebase" is critically underspecified and provides no actionable instructions, technical requirements, or measurable goals. As an autonomous agent, I cannot safely or effectively modify the codebase without a defined objective and success criteria.

**Refusal Class:**
`underspecified`

**Detailed Reasoning:**
The request "Do something with the codebase" violates the core operational principles of the Kokoko AI agent. Our workflow (Research -> Plan -> Decision -> Implement -> Test) requires a specific problem statement to identify relevant files, assess risks, and verify outcomes. 
- **Lack of Intent:** It is impossible to distinguish between a beneficial improvement and a destructive change under this prompt.
- **Risk of Regressions:** Arbitrary changes to the supervisor loop or worker scripts could break the entire autonomous pipeline.
- **Resource Inefficiency:** Proceeding with a vague task consumes API tokens and computational cycles without producing any value for the project.
- **Validation Impossibility:** Without acceptance criteria, there is no way to "Test" or "Validate" the work, which is a mandatory step in our lifecycle.

**Missing Information/Prerequisites:**
To proceed with this or a related task, the following information is missing:
1. **Specific Problem or Feature:** A clear description of *what* needs to be improved or added (e.g., "Add logging to the lock acquisition phase").
2. **Functional Area:** Identification of the scripts or modules involved (e.g., `.grkr/lib/lock.sh`).
3. **Acceptance Criteria:** A list of conditions that must be met for the task to be considered complete.
4. **Concrete Examples:** Examples of the desired behavior or output.

**Next Step Recommendations:**
To ensure this task can be prioritized and executed, please update Issue #13 with the following:
- **Clarify the Title:** Rename the issue to reflect a specific goal (e.g., "Enhance Supervisor Error Handling").
- **Define the 'What' and 'Why':** Explain the motivation behind the change and the expected benefit to the project.
- **List Requirements:** Provide a bulleted list of technical requirements or constraints.
- **Provide a 'Definition of Done':** Explicitly state how the success of the implementation should be verified (e.g., "Run `doctor.sh` and ensure all checks pass").

Once the issue is updated with these details, a new research cycle can be initiated.
