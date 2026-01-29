extends Resource
## Buff - Temporary combat enhancement resource
##
## Represents a temporary buff that can be applied to the player before entering
## a combat run. Buffs are cleared when returning to Farm_Hub.
##
## Buff types:
## - HEALTH: Increases maximum health for the run
## - AMMO: Provides bonus ammunition for weapons
## - WEAPON_MOD: Applies a temporary weapon modification
##
## Validates: Requirements 5.1, 5.2, 5.3

class_name Buff

enum BuffType {
	HEALTH,      ## Increases player max health
	AMMO,        ## Adds bonus ammunition
	WEAPON_MOD   ## Applies weapon modification
}

## The type of buff this represents
@export var buff_type: BuffType = BuffType.HEALTH

## The numeric value of the buff (health amount, ammo count, etc.)
@export var value: int = 0

## Duration in number of runs (currently always 1 for temporary buffs)
@export var duration: int = 1

## For WEAPON_MOD buffs, specifies the type of modification
## Examples: "fire_rate_boost", "spread_reduction", "damage_increase"
@export var weapon_mod_type: String = ""

## Apply this buff's effects to the player.
##
## This method modifies the player's stats based on the buff type:
## - HEALTH: Increases maximum health for the duration of the run
## - AMMO: Adds bonus ammunition to inventory
## - WEAPON_MOD: Applies a temporary weapon modification (requires WeaponSystem)
##
## Args:
##   player: The PlayerController node (can be null for HEALTH/AMMO buffs)
func apply_to_player(player: Node) -> void:
	match buff_type:
		BuffType.HEALTH:
			GameManager.set_max_health(GameManager.player_max_health + value)
		BuffType.AMMO:
			GameManager.add_to_inventory("ammo", value)
		BuffType.WEAPON_MOD:
			# Will be implemented when WeaponSystem exists (task 3.3.3)
			if player != null and player.has_node("WeaponSystem"):
				var weapon_system = player.get_node("WeaponSystem")
				if weapon_system.has_method("apply_weapon_mod"):
					weapon_system.apply_weapon_mod(weapon_mod_type)
				else:
					push_warning("Buff.apply_to_player: WeaponSystem.apply_weapon_mod method not found")
			else:
				push_warning("Buff.apply_to_player: WEAPON_MOD requires PlayerController with WeaponSystem")
