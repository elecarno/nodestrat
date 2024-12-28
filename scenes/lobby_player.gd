extends HBoxContainer

var client_id: int
var player_name: String = "N/A"

@onready var players = get_node("../../../../../players")

func _physics_process(_delta: float) -> void:
	for player in range(0, players.get_child_count()):
		if players.get_child(player).client_id == client_id:
			player_name = players.get_child(player).player_name
			$label.text = player_name

func init_entry() -> void:
	if multiplayer.get_unique_id() != client_id:
		$ready.visible = false
		$ready_label.visible = true
	else:
		$ready.visible = true
		$ready_label.visible = false

func _on_ready_toggled(toggled_on: bool) -> void:
	toggle_ready.rpc(toggled_on)
		
@rpc("any_peer", "call_local")
func toggle_ready(toggled_on: bool):
	for player in range(0, players.get_child_count()):
		if players.get_child(player).client_id == client_id:
			players.get_child(player).is_ready = toggled_on

	if toggled_on:
		$ready_label.text = "Ready"
	else:
		$ready_label.text = "Not Ready"
