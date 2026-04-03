@tool
extends EditorPlugin

const OpenClawBridge = preload("openclaw_bridge_v3.gd")

var bridge: OpenClawBridge

func _enter_tree():
	bridge = OpenClawBridge.new()
	bridge.editor_plugin = self
	add_child(bridge)
	print("[OpenClaw Bridge] Plugin activated (v3)")

func _exit_tree():
	if bridge:
		bridge.stop_server()
		bridge.queue_free()
		print("[OpenClaw Bridge] Plugin deactivated")