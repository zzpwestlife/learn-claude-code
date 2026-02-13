---
name: tdd-without-test-framework
description: |
  Execute TDD workflow (red → green → refactor) when test framework isn't installed
  but project standards require test files. Use when: (1) pytest/unittest not installed
  but project requires @pytest.mark.parametrize or unittest tests, (2) constitution.md
  or coding standards mandate TDD but environment setup incomplete, (3) need to verify
  "red phase" (test fails) before implementation, (4) CI/CD will install framework but
  local dev environment lacks it. Works for Python (pytest/unittest), JavaScript
  (jest/mocha), Go (testing package). Maintains test-first discipline without blocking
  on environment setup.
author: Claude Code
version: 1.0.0
date: 2026-02-13
---

# TDD Without Test Framework

## Problem
Project standards (e.g., constitution.md, language annexes) mandate Test-Driven Development
with specific test frameworks, but:
- Local development environment doesn't have the framework installed
- Don't want to modify project dependencies just for development
- Still need to verify TDD red phase (test fails before implementation)
- Want to maintain test-first discipline despite tooling gaps

**Common Scenarios**:
- Python project requires `pytest` but `pip list | grep pytest` returns nothing
- JavaScript project uses Jest but `node_modules/.bin/jest` doesn't exist
- CI/CD has framework installed, but local setup doesn't

## Context / Trigger Conditions

### Exact Error Messages
```bash
# Python
$ python -m pytest test_foo.py
/opt/homebrew/bin/python3.14: No module named pytest

# Node.js
$ npm test
sh: jest: command not found

# When trying to import test functions
$ python3 -c "from test_foo import test_bar"
ImportError: cannot import name 'test_bar' from 'test_foo'
```

### Triggering Situations
1. **Constitution Requirement**: Project has constitution.md → Art. 2 "Test-First Development"
2. **Language Annex Mandate**: Python Annex 2.1 requires `@pytest.mark.parametrize`
3. **TDD Workflow**: Following red → green → refactor cycle
4. **Environment Gap**: Framework missing from local system but required in tests

## Solution

### Phase 1: Write Test File (Red Phase Prep)

**Step 1**: Write test file using proper framework syntax
```python
# test_demo_math.py
import pytest
from demo_math import add, multiply

class TestMultiply:
    @pytest.mark.parametrize(
        "a,b,expected",
        [
            (3, 4, 12),
            (2.5, 4, 10.0),
            (-3, 7, -21),
            (0, 100, 0),
        ],
    )
    def test_multiply(self, a, b, expected):
        assert multiply(a, b) == expected
```

**Why This Works**: You're writing the *contract* (test structure), not running the framework

### Phase 2: Verify Red Phase (Test Fails)

**Step 2**: Use language interpreter to verify function doesn't exist

**Python Example**:
```bash
# Verify the function is missing (red phase)
$ python3 -c "from demo_math import multiply"
ImportError: cannot import name 'multiply' from 'demo_math'
# ✅ Red phase confirmed: function doesn't exist
```

**JavaScript Example**:
```bash
# Verify function is missing
$ node -e "const {multiply} = require('./math'); console.log(multiply)"
ReferenceError: multiply is not defined
# ✅ Red phase confirmed
```

**Go Example**:
```bash
# Verify function is missing
$ go build ./...
# math.go:10:2: undefined: multiply
# ✅ Red phase confirmed
```

**Step 3**: (Optional) Test function would fail if it existed
```bash
# Python: Import succeeds but function returns wrong value
$ python3 -c "from demo_math import multiply; assert multiply(3,4) == 999"
AssertionError
# ✅ Confirms test logic is correct
```

### Phase 3: Implement Function (Green Phase)

**Step 4**: Implement the function
```python
# demo_math.py
def multiply(a, b):
    """Multiplies two numbers."""
    return a * b
```

### Phase 4: Verify Green Phase (Implementation Works)

**Step 5**: Manually test all test scenarios
```bash
# Python: Verify all test cases manually
$ python3 -c "
from demo_math import multiply
assert multiply(3, 4) == 12, 'Test 1 failed'
assert multiply(2.5, 4) == 10.0, 'Test 2 failed'
assert multiply(-3, 7) == -21, 'Test 3 failed'
assert multiply(0, 100) == 0, 'Test 4 failed'
print('✅ All tests passed')
"
✅ All tests passed
```

**Step 6**: Document verification in progress.md
```markdown
## Test Results
| Test | Input | Expected | Actual | Status |
|------|-------|----------|--------|--------|
| multiply - 整数 | (3, 4) | 12 | 12 | ✓ |
| multiply - 浮点数混合 | (2.5, 4) | 10.0 | 10.0 | ✓ |
| multiply - 负数 | (-3, 7) | -21 | -21 | ✓ |
| multiply - 零值边界 | (0, 100) | 0 | 0 | ✓ |
```

### Phase 5: Refactor (If Needed)

**Step 7**: Since tests verify behavior, refactor safely
```python
# Example: Add type hints (refactor)
def multiply(a: float, b: float) -> float:
    """Multiplies two numbers."""
    return a * b
```

**Step 8**: Re-verify manually
```bash
$ python3 -c "from demo_math import multiply; print(multiply(3, 4))"
12
# ✅ Refactor didn't break functionality
```

## Verification

### TDD Checklist (Framework-Independent)
- [ ] **Red Phase**: Confirmed function/feature doesn't exist (ImportError, undefined, build error)
- [ ] **Test Structure**: Test file uses proper framework syntax (will work when framework installed)
- [ ] **Green Phase**: All test scenarios pass manual verification
- [ ] **Refactor**: Changes verified manually after refactoring
- [ ] **Documentation**: Test results logged in progress.md or test report

### Environment Notes
Document in progress.md:
```markdown
- Environment Note:
  - pytest未安装，采用 python3 直接导入 + 手动调用验证
  - 所有测试场景均通过（TDD 绿灯阶段）
```

## Example: Complete Python TDD Cycle

**Scenario**: Add `multiply` function, pytest not installed

**Red Phase**:
```bash
$ python3 -c "from demo_math import multiply"
ImportError: cannot import name 'multiply'
✅ Red phase confirmed
```

**Green Phase**:
```bash
# After implementing multiply function
$ python3 -c "
from demo_math import multiply
cases = [(3,4,12), (2.5,4,10.0), (-3,7,-21), (0,100,0)]
for a, b, expected in cases:
    result = multiply(a, b)
    assert result == expected, f'{a}*{b}: expected {expected}, got {result}'
print('✅ All 4 tests passed')
"
✅ All 4 tests passed
```

**Refactor Phase**:
```python
# Add docstring improvements, type hints
def multiply(a: float, b: float) -> float:
    """
    Multiplies two numbers.

    Args:
        a: First number (int or float)
        b: Second number (int or float)

    Returns:
        Product of a and b
    """
    return a * b
```

**Re-verification**:
```bash
$ python3 -c "from demo_math import multiply; print(multiply.__doc__)"
    Multiplies two numbers.
    ...
✅ Refactor complete, behavior unchanged
```

## Notes

### When to Use vs. Install Framework

**Use This Skill When**:
- ✅ Quick prototype or proof-of-concept
- ✅ Framework will be installed by CI/CD
- ✅ Don't have permission to install packages
- ✅ Testing simple functions with clear inputs/outputs
- ✅ Need to unblock development immediately

**Install Framework When**:
- ❌ Complex test setup (fixtures, mocks, context managers)
- ❌ Need test discovery or parallel execution
- ❌ Testing async code or timeouts
- ❌ Team uses framework-specific features (parametrize, fixtures)
- ❌ Will be running tests frequently during development

### Limitations

**What This Approach Can't Do**:
- Run framework-specific features (fixtures, mocking, parametrize execution)
- Provide test discovery or automatic test collection
- Generate test reports or coverage metrics
- Handle complex setup/teardown logic
- Parallel test execution

**What This Approach CAN Do**:
- Verify TDD red phase (function doesn't exist)
- Test simple functions with direct assertions
- Maintain test-first discipline
- Write tests that will work when framework installed
- Document test results manually

### Multi-Language Patterns

**Python (pytest/unittest)**:
```bash
# Red: ImportError
python3 -c "from module import func"

# Green: Manual assertions
python3 -c "from module import func; assert func(1,2) == 3"
```

**JavaScript (Jest/Mocha)**:
```bash
# Red: ReferenceError
node -e "const {func} = require('./module')"

# Green: Manual assertions
node -e "const {func} = require('./module'); console.assert(func(1,2) === 3)"
```

**Go (testing)**:
```bash
# Red: Build error
go build ./...

# Green: Manual test (create temp main.go)
echo 'package main; import "fmt"; import "./math"; func main() { fmt.Println(math.Multiply(3,4)) }' | go run -
```

### Constitution Compliance

This approach maintains constitution compliance:
- ✅ **Art. 2 Test-First**: Tests written before implementation
- ✅ **Red Phase Verified**: Confirmed function doesn't exist
- ✅ **Green Phase Verified**: All scenarios tested manually
- ✅ **Framework-Ready**: Tests will run when framework installed
- ⚠️ **Partial Coverage**: Manual verification doesn't provide coverage metrics

### Integration with Planning Files

**In task_plan.md**:
```markdown
### Phase 2: Test-First Development
- [x] 创建 test_demo_math.py
- [x] 使用 @pytest.mark.parametrize 编写参数化测试
- [x] 验证 TDD 红灯：ImportError: cannot import name 'multiply' ✅
- **Status:** complete
```

**In progress.md**:
```markdown
- Environment Note:
  - pytest未安装，采用 python3 直接导入 + 手动调用验证
  - 所有测试场景均通过（TDD 绿灯阶段）
```

### Follow-Up Actions

**After Development**:
1. Install framework: `pip install pytest` / `npm install --save-dev jest`
2. Run tests properly: `pytest test_*.py -v` / `npm test`
3. Verify all tests pass with framework
4. Add to CI/CD pipeline

## References
- Verified through actual execution: 2026-02-13 session (learn-claude-code/demo_math.py)
- TDD Principles: Kent Beck's "Test-Driven Development by Example"
- Python Testing: pytest documentation (parametrization)
- Constitution Art. 2: Test-First Development mandate
