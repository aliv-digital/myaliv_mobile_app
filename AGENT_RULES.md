# AGENT_RULES.md

## Purpose

This file contains mandatory working rules for every coding task in this repository.

**Every agent must read this file before inspecting, modifying, testing, or refactoring any code.**

These rules override any default tendency to refactor, improve, redesign, clean up, optimize, rename, or expand scope.

If a task conflicts with these rules, **stop and report the conflict before making changes**.

---

# 1. Core Rule: Strictly Isolated Changes

Every task must be implemented as a **strictly isolated change**.

Only modify what is required for the exact requested task.

Do **not**:

- modify unrelated UI
- modify unrelated business logic
- modify unrelated validation
- modify unrelated navigation
- modify APIs unless explicitly requested
- modify repositories unless explicitly required
- modify models unless explicitly required
- modify state-management architecture
- modify shared behavior that affects other scenarios
- rename unrelated files/classes/functions
- perform cleanup outside the requested scope
- perform broad refactors
- optimize unrelated code
- redesign existing UI
- change existing working behavior
- change existing copy/messages that are not part of the task
- fix unrelated warnings/errors while working on the task
- touch other screens/features simply because they use similar code

If the requested fix requires changing shared logic that may affect another flow, **STOP and report the dependency first**.

Do not make that shared change without explicit approval.

---

# 2. Audit First, Change Second

Before modifying code:

1. Read this `AGENT_RULES.md`.
2. Read the task carefully.
3. Inspect only the files/code paths relevant to the task.
4. Determine the current behavior.
5. Check whether the requested behavior is already implemented.
6. Identify the smallest possible change.

If the implementation already matches the requirement:

**Make no code changes.**

Report:

`No code change required.`

Do not rewrite existing code merely to make it cleaner.

---

# 3. Minimize Exploration and Token Usage

The task description should be treated as the primary source of scope.

Avoid broad repository exploration.

Start with:

- files mentioned in the task
- files directly responsible for the relevant screen/flow
- existing tests for that feature
- existing component/action/route already referenced by the task

Only expand inspection when necessary to understand an exact dependency.

Do not scan unrelated modules “just in case.”

---

# 4. Preserve Existing Architecture

Use the project's existing architecture and patterns.

Prefer reusing:

- existing widgets/components
- existing actions
- existing Cubit/BLoC events
- existing navigation routes
- existing services
- existing formatting
- existing validation paths
- existing error/success handling

Do not introduce a new architecture for a small feature.

Do not duplicate existing logic when a safe existing path can be reused.

---

# 5. UI Tasks: Screenshot Is the Source of Truth

When a screenshot/reference design is provided, treat it as the **UI source of truth**.

Match the reference as closely as possible for:

- position
- spacing
- margins
- padding
- width/height
- border
- border color
- border thickness
- corner radius
- background
- icon
- icon placement
- icon size
- text color
- typography
- font weight
- alignment
- CTA styling
- underline
- arrow/icon placement
- card/banner placement
- relationship to surrounding widgets

Do not invent a new UI.

Do not reinterpret the design.

Do not change other UI around it unless the task explicitly requires that.

Reuse an existing component if it can produce the required result safely.

If changing a shared component could affect other screens/states, **STOP and report first**.

---

# 6. Debug/Test Preview Rules

Debug helpers may be added only when explicitly requested.

A debug preview must:

- never modify backend data
- never modify real API responses
- never persist fake data
- never change production/release behavior
- remain disabled by default
- be clearly gated to debug mode
- be easy to remove
- alter only the smallest possible input required for testing

Most importantly:

**Debug mode must use the same production UI and production code path.**

Do not create a separate debug-only visual implementation just to preview a state.

Example:
If testing an expiry warning, override only the expiry input and let the real production warning widget render.

---

# 7. Business Logic Boundaries

For every conditional feature, explicitly preserve state boundaries.

Example pattern:

- state A → behavior A only
- state B → behavior B only
- state C → no A/B behavior

Do not allow mutually exclusive states to render simultaneously unless the task explicitly requires it.

Do not broaden conditions beyond the requested scenario.

Do not change shared threshold/date/time/business rules unless explicitly requested.

If a business-rule detail is ambiguous, **STOP and report rather than guessing**.

---

# 8. Navigation Rules

Always reuse existing navigation when possible.

Do not:

- create a new route if an existing destination already exists
- duplicate navigation logic
- alter unrelated navigation behavior
- change route architecture for a small task

If the required destination/action does not safely exist, **STOP and report before adding broader navigation**.

---

# 9. API / Backend / Model Safety

Unless the task explicitly asks for it:

- do not change API contracts
- do not change endpoints
- do not change request payloads
- do not change response parsing
- do not change backend data
- do not change models
- do not change repository interfaces
- do not change persistence/storage
- do not change shared networking

A UI/message task should remain a UI/message task unless a real dependency proves otherwise.

---

# 10. Existing Behavior Must Stay Unchanged

For every task, actively preserve:

- existing successful flows
- existing error flows
- existing navigation
- existing validations
- existing API behavior
- existing postpaid/prepaid separation
- unrelated cards/widgets/screens
- existing accessibility behavior
- existing keyboard/focus behavior
- existing loading states
- existing analytics behavior
- existing state restoration

Do not change behavior merely because a different implementation seems “better.”

---

# 11. Testing Rules

Run focused tests for the exact task.

Where relevant, test:

- requested positive scenario
- boundary condition
- negative/outside condition
- neighboring state that must remain unchanged
- exact message/copy
- CTA/action
- navigation
- dynamic values
- layout widths
- debug/release isolation
- regression of the immediately related previous feature

Do not modify unrelated tests just to make the full suite pass.

If the full suite contains pre-existing failures:

- report them separately
- do not treat them as caused by the task unless they are new
- do not fix them unless explicitly requested

---

# 12. Analyzer / Formatting / Verification

After changes:

- format changed files
- run focused tests
- run analyzer/static checks when practical
- run broader tests when practical
- compare new findings against the existing baseline
- verify no unrelated files changed
- review the final diff

If a screenshot/reference exists, perform visual verification when possible.

If pixel-perfect/full-device verification was not possible, say so explicitly.

---

# 13. Stop Conditions

Stop before making changes when:

- the fix requires modifying shared logic that may affect unrelated flows
- the required behavior is ambiguous
- the existing route/action needed by the task does not exist safely
- the task would require broad architecture changes
- the task would require backend/API changes not explicitly approved
- the task would require changing unrelated screens
- a screenshot/reference conflicts with current requirements
- exact business rules cannot be determined safely

Report:

1. what is blocking the task
2. why the scope must expand
3. which files/flows would be affected
4. the smallest proposed expansion

Wait for approval before continuing.

---

# 14. Git / Diff Discipline

Keep the diff minimal.

Before finishing, confirm:

- only necessary files changed
- no unrelated formatting churn
- no generated files accidentally committed
- no unrelated imports changed
- no unrelated comments removed
- no temporary debug code left enabled
- no dead code added
- no accidental behavior changes

---

# 15. Mandatory Final Text Report

After every task, provide a detailed plain-text execution report.

This report is mandatory even for small changes.

Include all of the following:

## A. Audit Result

- What was inspected
- What behavior existed before the change
- Whether the requested feature was:
  - already implemented
  - partially implemented
  - missing

If already correct, clearly state:

`No code change required.`

## B. Root Cause

If something was wrong/missing:

- explain why
- identify the exact condition/state/UI path involved

## C. Files Changed

List every modified file.

For each file, explain briefly why it changed.

## D. Exact Implementation

Explain:

- exact code behavior added/changed
- trigger/condition
- message/copy
- UI behavior
- CTA behavior
- navigation behavior
- dynamic values
- existing components/actions/routes reused

## E. Isolation / Non-Regression

Explicitly state what was NOT changed.

Confirm whether these remained unchanged where relevant:

- unrelated UI
- APIs
- models
- repositories
- state architecture
- navigation
- business logic
- other screens
- neighboring scenarios
- previous completed tasks

Also state:

`No broad refactor was performed.`

## F. Verification

Include:

- focused tests run
- focused tests passed/failed
- boundary scenarios tested
- analyzer result
- full-suite result if run
- existing unrelated failures
- whether any new failures were introduced

## G. Visual Verification

If UI was involved:

- whether the reference screenshot was used
- screen widths/device sizes checked
- whether position/styling matched
- any remaining visual difference
- whether full-device/pixel-perfect comparison was possible

## H. Regression Risk

State:

- `Low`
- `Medium`
- `High`

Then explain why.

## I. Final Status

End with exactly one:

`Completed`

or

`No code change required`

or

`Blocked - dependency requires approval`

---

# 16. Rule Priority

When performing any task, follow this priority:

1. User's exact task requirement
2. This `AGENT_RULES.md`
3. Existing project architecture
4. Existing implementation patterns
5. Minimal safe implementation

Never expand scope simply because a broader solution appears cleaner.

---

# 17. Before Every Task

Before doing anything, explicitly confirm internally:

- I have read `AGENT_RULES.md`.
- I understand the exact requested scenario.
- I know what must remain untouched.
- I will audit first.
- I will make no change if the feature is already correct.
- Any fix will be minimal and isolated.
- I will stop before touching shared/unrelated behavior.
- I will provide the mandatory detailed final report.

These rules apply to **every task in this repository unless the user explicitly overrides a specific rule for a specific task**.
