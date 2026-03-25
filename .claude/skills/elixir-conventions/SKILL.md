---
name: elixir-conventions
description: Write new Elixir code or review existing code against this project's conventions — TDD, pattern matching on structs, tagged return tuples, and separation of core logic from web/API layers.
argument-hint: <file(s) to review> or <description of new code to write>
---

This skill guides writing and reviewing Elixir code that is consistent, explicit, and testable. Apply it when writing new modules or auditing existing ones.

If `$ARGUMENTS` references existing files, read them (and their test counterparts) and audit against the conventions below — quoting violations, naming the broken rule, and showing corrected code. End with a per-convention issue count.

If `$ARGUMENTS` describes new functionality, identify which layer it belongs to, then produce the implementation and tests together. Never write implementation without tests.

## Think Before Writing

Before producing any code, commit to:

- **Layer placement**: Does this belong in `lib/ytz/game/` (pure logic), `lib/ytz/` (context/DB), or `lib/ytz_web/` (web)? The answer shapes every dependency decision.
- **Function contract**: What are the valid inputs? What does success return? What does failure return? Knowing this upfront determines the clause structure.
- **Test surface**: Which behaviors need a happy-path test? Which error cases need their own test? Name them before writing a line of implementation.

## Conventions

**TDD — Tests Match Implementation**

Every public function gets at least one happy-path test and one test per distinct error case. Tests live in `test/` mirroring `lib/`. Test files always use `use ExUnit.Case, async: true` and alias the module under test. Group tests with `describe "function_name/arity"` blocks and write test names as readable sentences describing behavior, not implementation details. In write mode, tests come first or alongside — never after.

**Pattern Matching — Function Heads Over Conditionals**

Use multiple function clauses to handle different input shapes. Never use `if`/`cond` to branch on types or struct identity — that belongs in the function head. Write the happy-path clause first, error clauses after. Match on struct type using `%__MODULE__{}` (inside the module) or `%ModName{}` (from outside). Use `when not is_struct(x, Mod)` as the guard for invalid-struct error clauses.

```elixir
# Correct
def process(%__MODULE__{} = thing), do: ...

def process(thing) when not is_struct(thing, __MODULE__) do
  {:error, "Invalid thing provided"}
end

# Incorrect — never do this
def process(thing) do
  if is_struct(thing, __MODULE__), do: ..., else: {:error, "..."}
end
```

**Struct Definitions — Always Include Type Specs**

Every struct module must have `defstruct` with defaults, a `@type t :: %__MODULE__{...}` covering every field with precise types, and a `new/0` constructor. Define a named `@type` for any map-shaped field. Never reach for `any()` when the shape is known.

```elixir
@type die :: %{value: integer(), frozen: boolean()}
@type t :: %__MODULE__{dice: [die()]}
defstruct dice: []
def new, do: %__MODULE__{}
```

**Return Values — Tag Every Result**

Functions that can fail return `{:ok, value}` or `{:error, reason}` where `reason` is a human-readable string. Functions that cannot fail may return a plain value. Store repeated error tuples as module attributes — not inline string literals. Callers must handle both branches with `case`, not bare pattern matching that silently crashes on error.

```elixir
@invalid_dice_error {:error, "Invalid dice provided"}
```

**Layer Separation — Core Logic Away from Web/API**

Game logic in `lib/ytz/game/` must have zero dependencies on Phoenix, LiveView, Plug, or Ecto. Context and DB modules in `lib/ytz/` may use Ecto and call game logic. The web layer in `lib/ytz_web/` calls context modules only — never game logic directly. If a web handler needs multiple game operations, compose them in the context layer.
