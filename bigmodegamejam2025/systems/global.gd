extends Node

# Ref
var player_ref : CharacterBody3D
var world_ref : Node3D
var pause_ref : Control

const BULLET_DECAL = preload("res://assets/decals/BulletDecal.tscn")

var max_decals : int = 500
var spawned_decals : Array

signal update_hud
signal update_piss_bar
signal decrease_piss_bar
signal on_interact

# this is for UI later
func check_menus():
	if pause_ref.is_open == true:
		return true
	else:
		return false
