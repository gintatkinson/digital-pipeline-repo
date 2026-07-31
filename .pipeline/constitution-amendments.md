# Constitution Amendment Log

Append-only record of every change to `.pipeline/constitution.md`.

`tests/test_constitution_integrity.py` asserts that the SHA-256 of the constitution
matches the newest entry below. **The constitution therefore cannot be changed by
anyone — human or agent — without a logged entry.** An unlogged edit fails the suite.

## Why this exists

`.agents/AGENTS.md:60` permits rewriting `constitution.md` only when *"every line of
the replacement has been explicitly approved by the user in the current conversation
turn"*, and `skills/project-constitution/SKILL.md` Mandate 4 forbids modifying it
*autonomously*. Both allow an approved amendment; neither described **how**.

`project-constitution` Step 7 gave implementation profiles a full lifecycle — add,
update, remove, list — while the constitution, the higher-authority Tier 1 document,
had a single sentence at line 285. The stronger document had the weaker process, so
the safe default became refusal, and two known defects stayed unfixed as a result.
See Step 9 of that skill for the procedure this log serves.

## Entry format

Every entry MUST carry all fields. The integrity test rejects a partial entry.

- **Date** — the date of the constitution change, matching the file's `last_updated`.
- **Logged** — when this entry was written.
- **Motivating issue** — the issue that justifies the change, or `n/a` with a reason.
- **Approved by** — verbatim quote of the human's approval, or `n/a` for the baseline.
- **Destructive** — `no` if the change is purely additive or a refinement in place.
  `yes` requires a justification paragraph; `project-constitution` Mandate 3 requires
  amendments to be cumulative and never destructive.
- **Line count** — lines in the resulting file. A non-destructive entry may not
  reduce it below the previous entry.
- **Resulting SHA-256** — checksum of `.pipeline/constitution.md` after the change.

---

## AMEND-0000 — Baseline

- **Date:** 2026-06-29
- **Logged:** 2026-07-31
- **Motivating issue:** n/a — protocol adoption, no content change
- **Approved by:** n/a — baseline record; the constitution was not modified
- **Destructive:** no
- **Line count:** 161
- **Resulting SHA-256:** `ae68494ed6190919dc342612d27f873d01f273750b2d1418aa3516913dac24e9`

Records the constitution's state at the moment the amendment protocol was adopted, so
the integrity test has a starting point. No content was changed by this entry. The
`Date` is the constitution's existing `last_updated` value rather than the date this
entry was written, because it records the state as of the last actual change.

### Amendments known to be pending at baseline

Two divergences between the constitution and the implemented, enforced behaviour were
outstanding when this log was created. Both are registered in
`tests/rule_contracts.py` `KNOWN_DOC_DIVERGENCES` and both require line-by-line human
approval before they can be applied through Step 9:

1. **Line 41 — external actor exemption (issue #277).** The constitution requires
   *every* sequence-diagram lifeline to resolve to a defined Class or Component. The
   enforced rule exempts lifelines declared as external UML actors, which are outside
   the system boundary and correctly absent from the structural models.
2. **Line 120 — authorization sufficiency (issue #295).** The constitution states that
   typing "Proceed" is sufficient authorization. `.agents/AGENTS.md:7` states a
   keyword is explicitly insufficient without an approved implementation plan, and
   #295 unified on the stricter reading. The constitution sentence remains weaker.
