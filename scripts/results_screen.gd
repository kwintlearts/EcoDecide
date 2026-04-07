# results_screen.gd
extends Control

# Metrics for Scene 1
@onready var metrics_s_1: Control = $Panel/MetricsS1
@onready var items_sorted_text: Label = $Panel/MetricsS1/HBoxContainer/ItemsSortedText
@onready var acurracy_text: Label = $Panel/MetricsS1/HBoxContainer2/AcurracyText
@onready var energy_text: Label = $Panel/MetricsS1/HBoxContainer3/EnergyText

# Metrics for Scene 2
@onready var metrics_s_2: Control = $Panel/MetricsS2
@onready var canal_clarity_text: Label = $Panel/MetricsS2/HBoxContainer/CanalClarityText
@onready var npc_engage_text: Label = $Panel/MetricsS2/HBoxContainer2/NPCEngageText
@onready var hazardous_text: Label = $Panel/MetricsS2/HBoxContainer3/HazardousText

# Metrics for Scene 3
@onready var metrics_s_3: Control = $Panel/MetricsS3
@onready var survival_rate_text: Label = $Panel/MetricsS3/HBoxContainer/SurvivalRateText
@onready var species_text: Label = $Panel/MetricsS3/HBoxContainer2/SpeciesText
@onready var soil_health_text: Label = $Panel/MetricsS3/HBoxContainer3/SoilHealthText

# Main stats
@onready var eco_score_earned_text: Label = $Panel/HBoxContainer3/EcoScoreEarnedText
@onready var fact_text: Label = $Panel/FactText
@onready var tier_name_title: Label = $Panel/VBoxContainer/TierNameTitle
@onready var tier_name_text: Label = $Panel/VBoxContainer/TierNameText
@onready var carry_overtext: Label = $Panel/CarryOvertext

@onready var button: Button = $Panel/Button

func _ready():
	button.pressed.connect(_on_continue_pressed)
	_load_scenario_results()

func _load_scenario_results():
	match GameState.current_scenario:
		1:
			_show_scenario_1_results()
		2:
			_show_scenario_2_results()
		3:
			_show_scenario_3_results()
		_:
			_show_scenario_1_results()

func _show_scenario_1_results():
	metrics_s_1.visible = true
	metrics_s_2.visible = false
	metrics_s_3.visible = false
	
	items_sorted_text.text = "%d / 20" % GameState.total_disposals
	acurracy_text.text = "%.1f%%" % GameState.get_sorting_accuracy()
	energy_text.text = "%d%%" % round(GameState.energy)
	
	eco_score_earned_text.text = "%d" % GameState.eco_score
	
	var tier = GameState.get_ending_tier()
	_set_tier_display(tier)
	_apply_scenario_1_carry_over()
	
	fact_text.text = "💡 DID YOU KNOW?\nRinsing recyclables prevents contamination and saves up to 30% of materials from going to landfills!"

func _show_scenario_2_results():
	metrics_s_1.visible = false
	metrics_s_2.visible = true
	metrics_s_3.visible = false
	
	# Get actual canal clarity from GameState
	var final_clarity = GameState.get_scenario_flag("canal_clarity", 0)
	if final_clarity == 0:
		# Calculate from remaining items if not set
		var spawner = get_tree().get_first_node_in_group("spawner")
		if spawner and spawner.has_method("get_remaining_items"):
			var remaining = spawner.get_remaining_items()
			final_clarity = int((30 - remaining) / 30.0 * 100)
	
	canal_clarity_text.text = str(final_clarity) + "%"
	
	# Count engaged NPCs based on choices
	var npc_count = 0
	if GameState.did_choose("comforted_lola") or GameState.did_choose("asked_lola"):
		npc_count += 1
	if GameState.did_choose("educated_vendor"):
		npc_count += 1
	if GameState.did_choose("youth_joined") or GameState.did_choose("youth_inspired"):
		npc_count += 1
	
	npc_engage_text.text = str(npc_count) + " / 3"
	
	# Hazardous disposal
	if GameState.did_choose("battery_recycled"):
		hazardous_text.text = "✅ Properly Disposed"
		hazardous_text.modulate = Color.GREEN
	else:
		hazardous_text.text = "❌ Improperly Disposed"
		hazardous_text.modulate = Color.RED
	
	eco_score_earned_text.text = str(GameState.eco_score)
	
	var tier = GameState.get_ending_tier()
	_set_tier_display(tier)
	_apply_scenario_2_carry_over()
	
	fact_text.text = "💡 DID YOU KNOW?\nOne battery can contaminate 600,000 liters of water - enough for 3,000 people for a day!"

func _show_scenario_3_results():
	metrics_s_1.visible = false
	metrics_s_2.visible = false
	metrics_s_3.visible = true
	
	survival_rate_text.text = str(GameState.get_scenario_flag("survival_rate", 85)) + "%"
	species_text.text = GameState.get_scenario_flag("species_chosen", "Native Trees")
	soil_health_text.text = str(GameState.get_scenario_flag("soil_health", 75)) + "%"
	
	eco_score_earned_text.text = "%d" % GameState.eco_score
	
	var tier = GameState.get_ending_tier()
	_set_tier_display(tier)
	
	fact_text.text = "💡 DID YOU KNOW?\nNative trees support 10x more local wildlife than exotic species!"

func _apply_scenario_1_carry_over():
	var carry_effects = []
	
	if GameState.did_choose("rinsed_bottle"):
		carry_effects.append("✅ Recyclables will glow blue in next scenario")
		GameState.scenario_flags["recyclables_glow"] = true
	else:
		carry_effects.append("❌ No glow effect - all trash looks the same")
	
	if GameState.did_choose("asked_help"):
		carry_effects.append("✅ 2nd truck will spawn (less walking)")
		GameState.scenario_flags["extra_truck"] = true
	
	if GameState.get_sorting_accuracy() < 70:
		carry_effects.append("⚠️ Truck driver charges disposal fee (-5 pts per item)")
		GameState.scenario_flags["disposal_fee"] = true
	
	if GameState.energy > 50:
		carry_effects.append("✅ Player moves slightly faster in next scenario")
		GameState.scenario_flags["speed_boost"] = true
	
	carry_overtext.text = "📦 CARRY-OVER EFFECTS:\n" + "\n".join(carry_effects)

func _apply_scenario_2_carry_over():
	var carry_effects = []
	
	if GameState.did_choose("woven_bag"):
		carry_effects.append("✅ +10 Soil Health bonus")
		GameState.modify_soil_health(10)
	else:
		carry_effects.append("❌ -10 Environment Health penalty")
		GameState.modify_env_health(-10)
	
	if GameState.did_choose("educated_vendor"):
		carry_effects.append("✅ 2 NPC helpers will appear (plant faster)")
		GameState.scenario_flags["npc_helpers"] = 2
	elif GameState.did_choose("confront_vendor") or GameState.did_choose("ignore_vendor"):
		carry_effects.append("❌ Plant alone (slower, more energy drain)")
		GameState.scenario_flags["npc_helpers"] = 0
	
	if GameState.did_choose("battery_recycled"):
		carry_effects.append("✅ +15 Water Quality → +5% Tree Survival")
		GameState.scenario_flags["tree_survival_bonus"] = 5
	else:
		carry_effects.append("❌ -20 Water Quality → -10% Tree Survival")
		GameState.scenario_flags["tree_survival_penalty"] = 10
	
	var canal_clarity = GameState.get_scenario_flag("canal_clarity", 80)
	if canal_clarity > 80:
		carry_effects.append("✅ +5 Soil Health (high clarity bonus)")
		GameState.modify_soil_health(5)
	elif canal_clarity < 50:
		carry_effects.append("❌ -5 Soil Health (low clarity penalty)")
		GameState.modify_soil_health(-5)
	
	carry_overtext.text = "📦 CARRY-OVER EFFECTS:\n" + "\n".join(carry_effects)

func _set_tier_display(tier: String):
	match tier:
		"A":
			tier_name_title.text = "🎉 TIER A: Circular Economy 🎉"
			tier_name_text.text = "Excellent! You closed the loop!"
			carry_overtext.modulate = Color.GREEN
			GameState.add_score(100)
		"B":
			tier_name_title.text = "📊 TIER B: Landfill Leak 📊"
			tier_name_text.text = "Not bad, but there's room for improvement."
			carry_overtext.modulate = Color.YELLOW
		"C":
			tier_name_title.text = "⚠️ TIER C: Mixed Waste ⚠️"
			tier_name_text.text = "Oh no... everything went to the dump."
			carry_overtext.modulate = Color.RED
		_:
			tier_name_title.text = "Scenario Complete!"
			tier_name_text.text = "Keep learning and improving!"

func _on_continue_pressed():
	match GameState.current_scenario:
		1:
			GameState.has_completed_scenario_1 = true
			# Hide results screen first
			visible = false
			# Load next scene with loading screen
			SceneLoader.load_scene("res://scenes/Scenario 2 Clean Up Drive/scene_2_clean_up_drive.tscn")
			# Queue free after loading starts
			await get_tree().process_frame
			queue_free()
		2:
			visible = false
			SceneLoader.load_scene("res://scenes/scenario_3.tscn")
			await get_tree().process_frame
			queue_free()
		3:
			visible = false
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
