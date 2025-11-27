extends Node2D
class_name GarlicTower

# Variables dari CSV
var tower_type: String = "Garlic_Tower"
var bullet_speed = 0.0
var bullet_damage = 0.0
var cooldown = 5.0
var range_radius = 200.0
var upgrade_cost_level2 = 80
var upgrade_cost_level3 = 160

# Slow properties
var slow_power := 0.5   # 50% slow
var slow_duration := 3.0
var is_aura_active := false
var can_activate := true

# References
@onready var aura: Sprite2D = $Aura_Effect
@onready var area: Area2D = $Sight
@onready var collision: CollisionShape2D = $Sight/CollisionShape2D
@onready var panel_upgrade: Panel = $Panel

# Upgrade system
var upgrade_level := 1
var enemies_in_area: Array = []
var currently_slowed_enemies: Array = []  # Track musuh yang sedang di-slow

func _ready() -> void:
	aura.visible = false
	panel_upgrade.visible = false
	ClickManager.connect("screen_clicked", Callable(self, "_on_screen_clicked"))
	setup_range_collision()

func setup_range_collision():
	if collision and collision.shape is CircleShape2D:
		collision.shape.radius = range_radius

func _process(delta: float) -> void:
	# Jika bisa aktivasi dan ada musuh di area, aktifkan aura
	if can_activate and enemies_in_area.size() > 0:
		_activate_aura()

func _activate_aura():
	if not can_activate:
		return
	
	can_activate = false
	is_aura_active = true
	aura.visible = true
	
	# Terapkan slow ke semua musuh yang ada di area saat ini
	_apply_slow_to_current_enemies()
	
	# Timer untuk durasi aura
	await get_tree().create_timer(slow_duration).timeout
	
	# Nonaktifkan aura dan HENTIKAN semua slow efek
	is_aura_active = false
	aura.visible = false
	_remove_all_slows()  # Hentikan semua slow efek
	
	# Cooldown sebelum bisa aktif lagi
	await get_tree().create_timer(cooldown).timeout
	can_activate = true

func _apply_slow_to_current_enemies():
	# Bersihkan musuh yang tidak valid
	_cleanup_enemies()
	
	# Terapkan slow ke semua musuh yang saat ini ada di area
	for enemy in enemies_in_area:
		if is_instance_valid(enemy) and enemy.has_method("apply_slow"):
			enemy.apply_slow(slow_power, slow_duration)
			if not enemy in currently_slowed_enemies:
				currently_slowed_enemies.append(enemy)

func _remove_all_slows():
	# Hentikan slow efek untuk semua musuh yang sedang di-track
	for enemy in currently_slowed_enemies:
		if is_instance_valid(enemy) and enemy.has_method("remove_slow"):
			enemy.remove_slow()
	
	# Kosongkan array
	currently_slowed_enemies.clear()

func _cleanup_enemies():
	# Bersihkan enemies_in_area dari musuh yang tidak valid
	var valid_enemies = []
	for enemy in enemies_in_area:
		if is_instance_valid(enemy):
			valid_enemies.append(enemy)
	enemies_in_area = valid_enemies
	
	# Juga bersihkan currently_slowed_enemies
	var valid_slowed = []
	for enemy in currently_slowed_enemies:
		if is_instance_valid(enemy):
			valid_slowed.append(enemy)
	currently_slowed_enemies = valid_slowed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_instance_valid(body):
		if not body in enemies_in_area:
			enemies_in_area.append(body)
			
			# Jika aura sedang aktif, terapkan slow ke musuh baru
			if is_aura_active and body.has_method("apply_slow"):
				body.apply_slow(slow_power, slow_duration)
				if not body in currently_slowed_enemies:
					currently_slowed_enemies.append(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body in enemies_in_area:
			enemies_in_area.erase(body)
		
		# Jika musuh keluar area, hentikan slow-nya (jika ada)
		if body in currently_slowed_enemies:
			if is_instance_valid(body) and body.has_method("remove_slow"):
				body.remove_slow()
			currently_slowed_enemies.erase(body)
		
# ... (fungsi-fungsi lainnya tetap sama)
func _on_shape_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_mask == 1: 
		panel_upgrade.visible = true

func _on_screen_clicked(pos: Vector2) -> void:
	if panel_upgrade.visible:
		var panel_rect = panel_upgrade.get_global_rect()
		if not panel_rect.has_point(pos):
			panel_upgrade.visible = false

func _on_texture_button_pressed() -> void:
	var upgrade_cost = get_upgrade_cost()
	if GameManager.coin >= upgrade_cost:
		GameManager.coin -= upgrade_cost
		GameManager.emit_signal("update_coin", GameManager.coin)
		
		upgrade_level += 1
		apply_upgrade_stats()
		print("Garlic Tower upgraded to level ", upgrade_level)

func get_upgrade_cost() -> int:
	match upgrade_level:
		1: return upgrade_cost_level2
		2: return upgrade_cost_level3
		_: return 99999

func apply_upgrade_stats():
	match upgrade_level:
		2:
			slow_power = 0.6    # 60% slow
			slow_duration = 3.5
			cooldown = 4.5
			range_radius *= 1.2
		3:
			slow_power = 0.75   # 75% slow
			slow_duration = 4.0
			cooldown = 4.0
			range_radius *= 1.3
	
	call_deferred("setup_range_collision")

var is_dragging = false

func start_drag():
	is_dragging = true
	process_mode = Node.PROCESS_MODE_DISABLED

func stop_drag():
	is_dragging = false
	process_mode = Node.PROCESS_MODE_INHERIT

func setup_from_data(tower_type: String, data: Dictionary):
	self.tower_type = tower_type
	self.bullet_speed = data.get("bullet_speed", 0.0)
	self.bullet_damage = data.get("bullet_damage", 0.0)
	self.cooldown = data.get("cooldown", 5.0)
	self.range_radius = data.get("range_radius", 200.0)
	self.upgrade_cost_level2 = data.get("upgrade_cost_level2", 80)
	self.upgrade_cost_level3 = data.get("upgrade_cost_level3", 160)
	
	call_deferred("setup_range_collision")
