# Development Workflow

## Working on a GitHub Issue

When assigned a GitHub issue, ALWAYS follow this order — no exceptions:

### Step 1: Research & Understand
- Read the issue thoroughly
- Explore relevant files and understand the current design
- Do NOT write any code yet

### Step 2: Plan
- Write a brief implementation plan: what to change, why, potential risks
- List the test cases you intend to cover
- Present the plan and wait for confirmation before proceeding

### Step 3: TDD — Write Tests First (RED)
- Write failing tests that describe the desired behavior
- Run tests and confirm they fail for the right reason
- Do NOT implement anything yet

### Step 4: Implement (GREEN)
- Write the minimal code to make the tests pass
- Run tests and confirm they pass

### Step 5: Analyze
- Run `flutter analyze` and fix every issue before proceeding
- No warnings or errors are acceptable

### Step 6: Refactor
- Clean up the implementation while keeping tests green
- Run `flutter analyze` and tests again after every meaningful change

## Hard Rules
- Never skip the planning step
- Never write implementation before tests
- Never mark a task done without all tests passing
- If you believe tests don't apply, you MUST get explicit human confirmation: "I AUTHORIZE SKIPPING TESTS"
