extends Node

signal state_changed(new_state: int)

enum State {
	MENU,
	WEAPON_SELECT,
	PLAYING,
	WAVE_TRANSITION,
	UPGRADE_SELECTION,
	PAUSED,
	GAME_OVER,
	VICTORY
}

var state: int = State.MENU
var previous_state: int = State.MENU

func set_state(new_state: int) -> bool:
	if state == new_state:
		return false
	previous_state = state
	state = new_state
	state_changed.emit(state)
	return true

func is_combat_active() -> bool:
	return state == State.PLAYING
