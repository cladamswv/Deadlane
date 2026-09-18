# DEADLANE v1.5.1 Debug / Error Check

This pass is based on the released v1.5 Graphics Polish source and focuses on runtime correctness, Android lifecycle behavior, deterministic checkpoint behavior, and GitHub Actions reliability.

## Fixes made

- Disabled Godot's default Android Back-button auto-quit so DEADLANE's pause/back handler actually receives the request.
- Clears held-fire state on pause and focus loss so resuming can never continue shooting without a finger on FIRE.
- Prevents duplicate resume countdown coroutines from multiple rapid Resume taps.
- Pauses wave-transition/rush/tutorial timers with the SceneTree instead of letting default `SceneTree.create_timer()` process through pause.
- Freezes non-combat transition/upgrade state while the app is backgrounded and resumes that state on focus return.
- Removed `Array.shuffle()` from upgrade generation. Upgrade choices now consume only the saved `RandomNumberGenerator`, making checkpoint replay deterministic.
- Added checkpoint structure/range validation and clamps restored health/cooldown values.
- `has_checkpoint()` now validates the checkpoint instead of enabling Continue merely because a corrupt file exists.
- Added engine tests for deterministic upgrade choices and held-fire clearing.
- Bumped development build to 1.5.1 / Android version code 6.

## Validation boundary

The local workspace cannot resolve github.com, so the pinned Godot 4.7.2 binary still cannot be executed here. GitHub Actions remains the authoritative Godot parser/import/export test.
