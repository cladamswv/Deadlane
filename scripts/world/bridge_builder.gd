extends RefCounted
class_name BridgeBuilder

const MF = preload("res://scripts/world/mesh_factory.gd")

static func build(parent: Node3D) -> void:
	var asphalt := Color("#343d49")
	var asphalt_patch := Color("#252c34")
	var concrete := Color("#78828d")
	var concrete_dark := Color("#515b65")
	var metal := Color("#36414b")
	var rust := Color("#774838")
	var yellow := Color("#d7ad3f")
	var white := Color("#cfd4d8")
	var water := Color("#244c63")

	# Raised bridge deck and exposed structure.
	MF.box(parent, Vector3(10.0, 0.55, 46.0), Vector3(0.0, -0.28, -15.0), asphalt)
	MF.box(parent, Vector3(10.7, 0.42, 46.0), Vector3(0.0, -0.72, -15.0), concrete_dark)
	MF.box(parent, Vector3(0.42, 0.42, 46.0), Vector3(-4.82, 0.16, -15.0), concrete)
	MF.box(parent, Vector3(0.42, 0.42, 46.0), Vector3(4.82, 0.16, -15.0), concrete)
	for side in [-1.0, 1.0]:
		MF.box(parent, Vector3(0.28, 0.32, 43.0), Vector3(side * 5.18, -0.86, -15.5), Color("#3f4851"))
		for z in [-32.0, -18.0, -4.0]:
			MF.box(parent, Vector3(1.35, 0.22, 2.4), Vector3(side * 5.65, -1.2, z), concrete_dark, Vector3(0.0, 0.0, side * 0.08))

	# Expansion joints, tar repairs, shattered patches and branching cracks.
	for z in range(-35, 7, 5):
		MF.box(parent, Vector3(9.35, 0.032, 0.12), Vector3(0.0, 0.035, float(z)), Color("#171d24"))
		MF.box(parent, Vector3(9.25, 0.018, 0.025), Vector3(0.0, 0.054, float(z) + 0.09), Color("#88919a"))
	for i in range(18):
		var patch_z := -2.0 - float(i) * 1.92
		var patch_x := -3.55 + fmod(float(i) * 1.73, 7.1)
		var patch_w := 0.72 + fmod(float(i), 4.0) * 0.24
		MF.box(parent, Vector3(patch_w, 0.018, 0.45 + fmod(float(i), 3.0) * 0.3), Vector3(patch_x, 0.049, patch_z), asphalt_patch, Vector3(0.0, 0.16 * float(i), 0.0))
	for i in range(28):
		var crack_z := -1.4 - float(i) * 1.24
		var crack_x := -3.8 + fmod(float(i) * 1.31, 7.6)
		var crack_angle := 0.18 + float(i) * 0.31
		MF.box(parent, Vector3(0.038, 0.02, 0.55 + fmod(float(i), 5.0) * 0.15), Vector3(crack_x, 0.066, crack_z), Color("#12171c"), Vector3(0.0, crack_angle, 0.0))
		if i % 3 == 0:
			MF.box(parent, Vector3(0.032, 0.018, 0.38), Vector3(crack_x + 0.23, 0.067, crack_z - 0.15), Color("#12171c"), Vector3(0.0, -0.55 + crack_angle, 0.0))

	# v1.5 layered road decals add broad stains/skids that geometry cracks alone cannot sell.
	MF.decal_quad(parent, "res://assets/textures/skid_decal_v15.png", Vector2(2.5, 8.8), Vector3(-1.85, 0.078, -12.8), -0.08, Color(1.0, 1.0, 1.0, 0.72))
	MF.decal_quad(parent, "res://assets/textures/skid_decal_v15.png", Vector2(2.2, 7.2), Vector3(2.05, 0.079, -27.0), 0.12, Color(1.0, 1.0, 1.0, 0.58))
	MF.decal_quad(parent, "res://assets/textures/oil_decal_v15.png", Vector2(3.1, 2.3), Vector3(-3.55, 0.081, -8.7), 0.31, Color(1.0, 1.0, 1.0, 0.84))
	MF.decal_quad(parent, "res://assets/textures/oil_decal_v15.png", Vector2(2.7, 2.0), Vector3(3.55, 0.082, -18.2), -0.18, Color(1.0, 1.0, 1.0, 0.72))
	MF.decal_quad(parent, "res://assets/textures/blood_decal_v15.png", Vector2(2.5, 2.3), Vector3(1.2, 0.084, -21.7), 0.41, Color(1.0, 1.0, 1.0, 0.74))
	MF.decal_quad(parent, "res://assets/textures/blood_decal_v15.png", Vector2(1.8, 1.5), Vector3(-2.7, 0.085, -30.4), -0.24, Color(1.0, 1.0, 1.0, 0.52))

	# Worn markings and roadside reflectors.
	for z in range(-34, 6, 4):
		MF.box(parent, Vector3(0.13, 0.022, 1.75), Vector3(0.0, 0.052, float(z)), white)
	for x in [-2.5, 2.5]:
		for z in range(-34, 6, 5):
			MF.box(parent, Vector3(0.075, 0.018, 2.15), Vector3(x, 0.054, float(z)), Color(0.88, 0.9, 0.92, 0.62))
	for z in range(-33, 5, 3):
		for x in [-1.25, 1.25]:
			MF.box(parent, Vector3(0.11, 0.035, 0.18), Vector3(x, 0.067, float(z) + 0.8), Color("#dfc878"))

	# Guardrails are segmented so the apocalypse can actually damage them.
	for side in [-1.0, 1.0]:
		var rail_x: float = float(side) * 5.12
		for z in range(-37, 9, 2):
			var broken: bool = (float(side) < 0.0 and (z == -19 or z == -17)) or (float(side) > 0.0 and (z == -9 or z == -7))
			if broken:
				MF.box(parent, Vector3(0.11, 0.85, 0.11), Vector3(rail_x + side * 0.28, 0.45, float(z)), rust, Vector3(0.0, 0.0, side * 0.48))
				MF.box(parent, Vector3(0.10, 0.10, 1.7), Vector3(rail_x + side * 0.25, 0.68, float(z) + 0.45), rust, Vector3(0.0, side * 0.46, side * 0.18))
				continue
			MF.box(parent, Vector3(0.12, 1.1, 0.12), Vector3(rail_x, 0.72, float(z)), metal)
			MF.box(parent, Vector3(0.12, 0.12, 2.05), Vector3(rail_x, 1.22, float(z) + 0.9), metal)
			MF.box(parent, Vector3(0.10, 0.10, 2.05), Vector3(rail_x, 0.74, float(z) + 0.9), Color("#46525c"))
			MF.box(parent, Vector3(0.08, 0.08, 2.05), Vector3(rail_x, 0.43, float(z) + 0.9), Color("#4a5660"))

	# Drain grates and standing roadside rubble.
	for side in [-1.0, 1.0]:
		for z in [-5.5, -14.0, -22.5, -31.0]:
			MF.box(parent, Vector3(0.42, 0.025, 0.8), Vector3(side * 4.35, 0.06, z), Color("#1d252d"))
			for stripe in [-0.13, 0.0, 0.13]:
				MF.box(parent, Vector3(0.035, 0.012, 0.72), Vector3(side * 4.35 + stripe, 0.075, z), Color("#65717b"))
	_build_debris_pile(parent, Vector3(-4.42, 0.08, -4.6), -1.0)
	_build_debris_pile(parent, Vector3(4.38, 0.08, -28.5), 1.0)

	# Abandoned traffic tells small stories but stays out of the firing corridor.
	_build_vehicle(parent, Vector3(-4.0, 0.43, -8.5), -0.36, Color("#7b4248"), true)
	_build_vehicle(parent, Vector3(4.0, 0.43, -18.5), 0.31, Color("#3f6274"), true)
	_build_vehicle(parent, Vector3(-4.05, 0.43, -29.5), -0.18, Color("#6c6651"), true)
	_build_van(parent, Vector3(4.0, 0.62, -11.8), Color("#727b82"), true)
	_build_ambulance(parent, Vector3(6.15, 0.62, -6.5), -0.32)
	_build_bus_wreck(parent, Vector3(-6.25, 0.62, -17.8), 0.26)

	# The bridge used to be a quarantine evacuation route.
	_build_quarantine_checkpoint(parent, -25.6)
	_build_survivor_barricade(parent, Vector3(-6.0, 0.0, -2.0), -1.0)
	_build_survivor_barricade(parent, Vector3(6.0, 0.0, -31.5), 1.0)
	_build_container_stack(parent, Vector3(-8.2, -0.2, -34.5), -0.12, Color("#6c5545"))
	_build_container_stack(parent, Vector3(8.4, -0.2, -33.0), 0.16, Color("#4e6870"))

	# Warning barriers, scattered cones, a battered gantry and road-sign carcass.
	for x in [-3.45, 3.45]:
		_build_barrier(parent, Vector3(x, 0.22, -26.2), yellow)
	for x in [-3.8, -3.2, 3.25, 3.8]:
		_build_cone(parent, Vector3(x, 0.05, -23.8 + absf(x) * 0.18))
	_build_sign_gantry(parent, -20.5)

	# Street lights: several are bent, broken or blinking.
	for z in [-3.0, -12.0, -21.0, -30.0]:
		_build_street_light(parent, -4.72, z, 1.0, z == -12.0)
		_build_street_light(parent, 4.72, z, -1.0, z == -21.0)

	# Fires, smoke and emergency beacons animate through EnvironmentFX.
	_build_fire_barrel(parent, Vector3(-5.78, 0.1, -5.8), 0.2)
	_build_fire_barrel(parent, Vector3(5.9, 0.1, -27.6), 1.4)
	_build_burning_wreck_fx(parent, Vector3(-6.0, 0.45, -17.2), 2.1)
	_build_burning_wreck_fx(parent, Vector3(6.0, 0.35, -7.2), 3.4)
	_build_ember_field(parent, Vector3(-5.9, 0.7, -17.1), 2.0)
	_build_ember_field(parent, Vector3(5.9, 0.6, -7.1), 3.2)

	# Water, piers and hanging debris below the shattered bridge edges.
	MF.box(parent, Vector3(86.0, 0.38, 105.0), Vector3(0.0, -8.25, -23.0), water)
	for i in range(13):
		var water_z := -68.0 + float(i) * 8.0
		MF.box(parent, Vector3(80.0, 0.025, 1.25), Vector3(0.0, -8.02, water_z), Color("#315d72"))
	for side in [-1.0, 1.0]:
		for z in [-28.0, -8.0]:
			MF.box(parent, Vector3(1.0, 12.5, 1.0), Vector3(side * 6.8, -3.2, z), concrete_dark)
			MF.box(parent, Vector3(2.1, 0.5, 2.1), Vector3(side * 6.8, -7.6, z), concrete)
			MF.box(parent, Vector3(0.13, 5.4, 0.13), Vector3(side * 5.3, -3.1, z + 2.8), rust, Vector3(0.12, 0.0, side * 0.08))

	# Ruined skyline: missing roof chunks, rooftop tanks and smoke columns.
	for i in range(11):
		var bx := -23.0 + float(i) * 4.6
		var h := 3.4 + fmod(float(i) * 2.25, 7.5)
		_build_ruined_building(parent, Vector3(bx, h * 0.5 - 0.25, -48.0 - fmod(float(i), 3.0) * 3.0), Vector3(3.0, h, 3.1), i)
	for i in range(7):
		var bx2 := -19.0 + float(i) * 6.1
		var h2 := 6.0 + fmod(float(i) * 3.1, 8.0)
		_build_ruined_building(parent, Vector3(bx2, h2 * 0.5 - 1.0, -63.0), Vector3(4.4, h2, 4.0), i + 20)
	_build_background_smoke(parent, Vector3(-13.0, 5.0, -51.0), 4.2, 0.7)
	_build_background_smoke(parent, Vector3(11.5, 6.5, -59.0), 5.4, 1.9)

	# v1.4 peripheral world pass: ruined ramps, utility clutter and roof silhouettes
	# keep the playable road clear while making the edges feel like a collapsed city.
	_build_broken_flyover(parent, Vector3(-12.8, -2.3, -22.0), -0.20, -1.0)
	_build_broken_flyover(parent, Vector3(13.4, -2.6, -37.0), 0.24, 1.0)
	_build_military_wreck(parent, Vector3(-8.8, 0.38, -10.8), 0.42)
	_build_military_wreck(parent, Vector3(8.9, 0.38, -30.2), -0.31)
	_build_billboard_ruin(parent, Vector3(13.8, -0.3, -43.0), -0.20, 1)
	_build_billboard_ruin(parent, Vector3(-14.8, -0.4, -37.5), 0.18, 2)
	_build_utility_cluster(parent, Vector3(7.2, -0.1, -3.0), 1.0)
	_build_utility_cluster(parent, Vector3(-8.0, -0.2, -31.2), -1.0)
	_build_helicopter_crash(parent, Vector3(10.8, -0.35, -17.0), -0.48)
	_build_crane_ruin(parent, Vector3(-20.5, -7.4, -53.0), 0.16)
	_build_rooftop_silhouettes(parent)
	_build_flooded_debris_field(parent)

	# v1.5 high-detail peripheral incidents: these sit outside the firing corridor
	# and use imported original meshes so the world reads as a failed evacuation.
	_build_police_wreck_v15(parent, Vector3(7.7, -0.05, -13.7), -0.58)
	_build_fire_engine_wreck_v15(parent, Vector3(-9.5, -0.18, -26.8), 0.38)
	_build_rubble_cluster_v15(parent, Vector3(-6.2, 0.02, -11.4), -0.12)
	_build_rubble_cluster_v15(parent, Vector3(6.35, 0.02, -22.7), 0.22)
	_build_rubble_cluster_v15(parent, Vector3(-7.25, -0.06, -34.0), 0.46)

static func _build_vehicle(parent: Node3D, pos: Vector3, yaw: float, color: Color, damaged: bool) -> void:
	var car := Node3D.new()
	car.position = pos
	car.rotation.y = yaw
	parent.add_child(car)
	MF.asset_mesh(car, "res://assets/models/wrecked_car.obj", Vector3(0.0, -0.42, 0.0), Vector3(0.86, 0.86, 0.86), color)
	MF.box(car, Vector3(1.18, 0.34, 0.05), Vector3(0.0, 0.48, -0.34), Color("#253642"), Vector3(-0.10, 0.0, 0.0))
	MF.box(car, Vector3(1.14, 0.32, 0.05), Vector3(0.0, 0.48, 0.52), Color("#1e2d37"), Vector3(0.10, 0.0, 0.0))
	MF.box(car, Vector3(0.9, 0.025, 0.04), Vector3(0.0, 0.4, -0.67), Color("#718999"))
	MF.box(car, Vector3(0.9, 0.025, 0.04), Vector3(0.0, 0.4, 0.39), Color("#718999"))
	MF.box(car, Vector3(0.82, 0.05, 0.16), Vector3(0.0, -0.08, -1.14), Color("#242a2f"))
	for x in [-0.65, 0.65]:
		for z in [-0.72, 0.72]:
			MF.cylinder(car, 0.22, 0.18, Vector3(x, -0.18, z), Color("#171c21"), Vector3(0.0, 0.0, PI * 0.5), 10)
	if damaged:
		MF.box(car, Vector3(0.48, 0.08, 0.72), Vector3(0.34, 0.28, 0.64), Color("#262d33"), Vector3(0.0, 0.25, 0.22))
		MF.box(car, Vector3(0.32, 0.03, 0.48), Vector3(-0.31, 0.55, -0.42), Color("#11171c"), Vector3(0.0, -0.45, 0.0))
		MF.box(car, Vector3(0.07, 0.16, 0.44), Vector3(0.62, 0.08, 0.15), Color("#88543a"), Vector3(0.0, 0.0, 0.28))

static func _build_van(parent: Node3D, pos: Vector3, color: Color, damaged: bool) -> void:
	var van := Node3D.new()
	van.position = pos
	van.rotation.y = 0.15
	parent.add_child(van)
	MF.box(van, Vector3(1.55, 1.15, 2.65), Vector3.ZERO, color)
	MF.box(van, Vector3(1.32, 0.43, 0.06), Vector3(0.0, 0.23, -1.34), Color("#30414c"))
	MF.box(van, Vector3(0.05, 0.86, 1.58), Vector3(-0.79, 0.0, 0.25), Color("#3d474f"))
	for x in [-0.78, 0.78]:
		for z in [-0.85, 0.85]:
			MF.cylinder(van, 0.24, 0.18, Vector3(x, -0.52, z), Color("#171c21"), Vector3(0.0, 0.0, PI * 0.5), 10)
	if damaged:
		MF.box(van, Vector3(0.65, 0.05, 0.7), Vector3(0.2, 0.6, -0.6), Color("#2b3339"), Vector3(0.0, 0.0, 0.13))

static func _build_ambulance(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var ambulance := Node3D.new()
	ambulance.position = pos
	ambulance.rotation = Vector3(0.0, yaw, 0.10)
	parent.add_child(ambulance)
	MF.asset_mesh(ambulance, "res://assets/models/ambulance_wreck.obj", Vector3(0.0, -0.68, 0.0), Vector3(0.88, 0.88, 0.88), Color("#d8d9d2"))
	MF.box(ambulance, Vector3(1.52, 0.17, 2.65), Vector3(0.0, 0.08, 0.14), Color("#a74642"))
	MF.box(ambulance, Vector3(1.52, 0.46, 0.05), Vector3(0.0, 0.47, -1.47), Color("#425258"))
	MF.emissive_box(ambulance, Vector3(0.28, 0.11, 0.14), Vector3(-0.42, 0.86, -0.42), Color("#dd3d35"), 1.8)
	MF.emissive_box(ambulance, Vector3(0.28, 0.11, 0.14), Vector3(0.42, 0.86, -0.42), Color("#417bc0"), 1.8)
	MF.box(ambulance, Vector3(0.52, 0.035, 0.66), Vector3(0.42, 0.88, 1.24), Color("#171c20"), Vector3(0.0, 0.15, 0.22))

static func _build_bus_wreck(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var bus := Node3D.new()
	bus.position = pos
	bus.rotation = Vector3(0.0, yaw, -0.12)
	parent.add_child(bus)
	MF.asset_mesh(bus, "res://assets/models/wrecked_bus.obj", Vector3(0.0, -0.78, 0.0), Vector3(0.88, 0.88, 0.88), Color("#a48d58"))
	# broken window band and soot make the single-material body read as wreckage.
	for z in [-2.25, -1.35, -0.45, 0.45, 1.35, 2.25]:
		MF.box(bus, Vector3(1.95, 0.46, 0.045), Vector3(0.0, 0.77, z), Color("#425258"), Vector3(0.0, 0.0, 0.02 * z))
	MF.box(bus, Vector3(1.45, 0.06, 1.4), Vector3(0.35, 0.93, -1.66), Color("#171c20"), Vector3(0.0, 0.0, 0.19))
	MF.box(bus, Vector3(0.14, 0.88, 1.55), Vector3(-1.15, 0.38, 0.65), Color("#754737"), Vector3(0.0, 0.0, -0.16))

static func _build_quarantine_checkpoint(parent: Node3D, z: float) -> void:
	var checkpoint := Node3D.new()
	checkpoint.position = Vector3(0.0, 0.0, z)
	parent.add_child(checkpoint)
	# Side booths and concrete protection leave the center open for enemies.
	for side in [-1.0, 1.0]:
		var x: float = float(side) * 5.9
		var booth := MF.asset_mesh(checkpoint, "res://assets/models/quarantine_booth.obj", Vector3(x, 0.0, 0.0), Vector3(0.82, 0.82, 0.82), Color("#59636a"), Vector3(0.0, side * 0.04, side * 0.035))
		MF.box(checkpoint, Vector3(1.12, 0.52, 0.04), Vector3(x, 1.23, -0.88), Color("#425258"))
		_build_sandbag_wall(checkpoint, Vector3(side * 4.45, 0.12, 0.55), side)
		_build_beacon(checkpoint, Vector3(side * 5.45, 2.45, -0.45), Color("#d33f35" if side < 0.0 else "#d4a947"))
	# Hanging damaged checkpoint sign.
	MF.box(checkpoint, Vector3(7.3, 0.14, 0.14), Vector3(0.0, 3.35, 0.0), Color("#3e484f"), Vector3(0.0, 0.0, -0.04))
	MF.box(checkpoint, Vector3(3.8, 0.92, 0.08), Vector3(0.0, 2.94, 0.03), Color("#713f35"), Vector3(0.0, 0.0, 0.06))
	var label := Label3D.new()
	label.text = "QUARANTINE  •  EVAC ROUTE"
	label.font_size = 44
	label.modulate = Color("#eee0bd")
	label.outline_modulate = Color("#211b19")
	label.outline_size = 6
	label.position = Vector3(0.0, 2.94, 0.09)
	label.rotation.y = PI
	checkpoint.add_child(label)

static func _build_survivor_barricade(parent: Node3D, pos: Vector3, side: float) -> void:
	var nest := Node3D.new()
	nest.position = pos
	parent.add_child(nest)
	_build_sandbag_wall(nest, Vector3.ZERO, side)
	MF.box(nest, Vector3(1.45, 0.09, 0.52), Vector3(side * 0.25, 0.73, -0.15), Color("#514638"), Vector3(0.0, 0.17 * side, 0.0))
	MF.box(nest, Vector3(0.11, 1.45, 0.11), Vector3(-side * 0.62, 0.74, 0.38), Color("#3a332d"), Vector3(0.0, 0.0, 0.13 * side))
	MF.box(nest, Vector3(0.9, 0.68, 0.05), Vector3(-side * 0.58, 1.22, 0.38), Color("#66433a"), Vector3(0.0, 0.0, -0.1 * side))

static func _build_sandbag_wall(parent: Node3D, pos: Vector3, side: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = 0.11 * side
	parent.add_child(root)
	for row in range(3):
		for col in range(4):
			var offset: float = -0.72 + float(col) * 0.48 + (0.22 if row % 2 == 1 else 0.0)
			MF.asset_mesh(root, "res://assets/models/sandbag.obj", Vector3(offset, 0.17 + float(row) * 0.22, 0.0), Vector3(0.72, 0.72, 0.72), Color("#847758"), Vector3(0.0, 0.04 * float(col-row), 0.0))

static func _build_container_stack(parent: Node3D, pos: Vector3, yaw: float, color: Color) -> void:
	var stack := Node3D.new()
	stack.position = pos
	stack.rotation.y = yaw
	parent.add_child(stack)
	for level in range(2):
		var shift: float = 0.0 if level == 0 else 0.55
		MF.asset_mesh(stack, "res://assets/models/shipping_container.obj", Vector3(shift, 0.0 + float(level) * 1.44, 0.0), Vector3.ONE, color.darkened(float(level) * 0.12), Vector3(0.0, 0.02 * float(level), 0.0))
		MF.box(stack, Vector3(1.7, 0.05, 0.04), Vector3(shift, 0.78 + float(level) * 1.44, -2.5), Color("#754737"), Vector3(0.0, 0.0, 0.08))

static func _build_barrier(parent: Node3D, pos: Vector3, color: Color) -> void:
	var barrier := Node3D.new()
	barrier.position = pos
	barrier.rotation.y = pos.x * 0.025
	parent.add_child(barrier)
	MF.asset_mesh(barrier, "res://assets/models/jersey_barrier.obj", Vector3.ZERO, Vector3(0.78, 0.78, 0.78), Color("#78828d"))
	MF.box(barrier, Vector3(1.38, 0.08, 0.04), Vector3(0.0, 0.56, -0.25), color, Vector3(0.0, 0.0, -0.08))
	MF.emissive_box(barrier, Vector3(0.18, 0.07, 0.025), Vector3(-0.48, 0.58, -0.28), Color("#ff9f2e"), 1.3)
	MF.emissive_box(barrier, Vector3(0.18, 0.07, 0.025), Vector3(0.48, 0.58, -0.28), Color("#ff9f2e"), 1.3)

static func _build_cone(parent: Node3D, pos: Vector3) -> void:
	var cone := Node3D.new()
	cone.position = pos
	cone.rotation.z = (pos.x * 0.03)
	parent.add_child(cone)
	MF.tapered_cylinder(cone, 0.05, 0.18, 0.48, Vector3(0.0, 0.24, 0.0), Color("#df7434"), Vector3.ZERO, 10)
	MF.box(cone, Vector3(0.44, 0.04, 0.44), Vector3(0.0, 0.02, 0.0), Color("#252b31"))
	MF.cylinder(cone, 0.13, 0.045, Vector3(0.0, 0.29, 0.0), Color("#e8e2d6"), Vector3.ZERO, 10)

static func _build_street_light(parent: Node3D, x: float, z: float, inward: float, broken: bool) -> void:
	var light := Node3D.new()
	light.position = Vector3(x, 0.0, z)
	light.rotation = Vector3(0.0, PI if inward < 0.0 else 0.0, inward * (0.0 if not broken else 0.18))
	parent.add_child(light)
	MF.asset_mesh(light, "res://assets/models/streetlight.obj", Vector3.ZERO, Vector3.ONE, Color("#39434c"))
	if not broken:
		MF.emissive_box(light, Vector3(0.34, 0.035, 0.20), Vector3(1.20, 4.79, 0.01), Color("#ffdca2"), 1.5)
	else:
		MF.box(light, Vector3(0.08, 0.58, 0.08), Vector3(0.72, 4.30, 0.0), Color("#754737"), Vector3(0.0, 0.0, inward * 0.65))

static func _build_sign_gantry(parent: Node3D, z: float) -> void:
	var gantry := Node3D.new()
	gantry.position = Vector3(0.0, 0.0, z)
	gantry.rotation.z = -0.018
	parent.add_child(gantry)
	for x in [-4.55, 4.55]:
		MF.box(gantry, Vector3(0.16, 4.4, 0.16), Vector3(x, 2.2, 0.0), Color("#444f59"))
	MF.box(gantry, Vector3(9.2, 0.16, 0.16), Vector3(0.0, 4.35, 0.0), Color("#444f59"))
	MF.box(gantry, Vector3(3.2, 1.05, 0.12), Vector3(-1.7, 3.65, -0.06), Color("#315744"), Vector3(0.0, 0.0, 0.08))
	MF.box(gantry, Vector3(2.7, 0.82, 0.12), Vector3(1.9, 3.75, -0.06), Color("#584839"), Vector3(0.0, 0.0, -0.11))
	for x in [-2.55, -1.85, -1.15, 1.25, 1.95, 2.65]:
		MF.box(gantry, Vector3(0.42, 0.06, 0.02), Vector3(x, 3.68, -0.14), Color("#d5ddd7"))
	MF.box(gantry, Vector3(1.1, 0.05, 0.08), Vector3(2.25, 3.4, -0.13), Color("#1e2429"), Vector3(0.0, 0.0, 0.48))

static func _build_debris_pile(parent: Node3D, pos: Vector3, side: float) -> void:
	var root := Node3D.new()
	root.position = pos
	parent.add_child(root)
	for i in range(7):
		var x: float = side * (0.1 + float(i % 3) * 0.22)
		var z: float = -0.45 + float(i) * 0.15
		var size: float = 0.26 + float(i % 2) * 0.18
		MF.box(root, Vector3(size, 0.15 + size * 0.4, size * 1.35), Vector3(x, 0.08 + float(i % 3) * 0.05, z), Color("#626970"), Vector3(0.2 * float(i), 0.37 * float(i), 0.14 * side))
	MF.cylinder(root, 0.34, 0.16, Vector3(-side * 0.24, 0.18, 0.22), Color("#171c20"), Vector3(PI * 0.5, 0.0, 0.0), 12)
	MF.box(root, Vector3(0.07, 0.08, 1.45), Vector3(side * 0.22, 0.28, -0.05), Color("#754737"), Vector3(0.0, 0.35 * side, 0.23))

static func _build_fire_barrel(parent: Node3D, pos: Vector3, phase: float) -> void:
	var root := Node3D.new()
	root.position = pos
	parent.add_child(root)
	MF.cylinder(root, 0.32, 0.68, Vector3(0.0, 0.34, 0.0), Color("#3f484d"), Vector3.ZERO, 14)
	for y in [0.11, 0.34, 0.57]:
		MF.cylinder(root, 0.335, 0.035, Vector3(0.0, y, 0.0), Color("#754737"), Vector3.ZERO, 14)
	var fire := Node3D.new()
	fire.position = Vector3(0.0, 0.84, 0.0)
	fire.set_meta("phase", phase)
	fire.add_to_group("deadlane_fire")
	root.add_child(fire)
	MF.emissive_tapered_cylinder(fire, 0.035, 0.22, 0.62, Vector3(0.0, 0.18, 0.0), Color("#e3662f"), 2.8, Vector3.ZERO, 10)
	MF.emissive_tapered_cylinder(fire, 0.025, 0.13, 0.48, Vector3(0.06, 0.28, 0.02), Color("#ffc04f"), 3.4, Vector3.ZERO, 10)
	var glow := OmniLight3D.new()
	glow.light_color = Color("#ff8a45")
	glow.light_energy = 1.6
	glow.omni_range = 4.2
	glow.shadow_enabled = false
	glow.position = Vector3(0.0, 0.35, 0.0)
	fire.add_child(glow)
	_build_smoke_cluster(root, Vector3(0.0, 1.45, 0.0), phase)

static func _build_burning_wreck_fx(parent: Node3D, pos: Vector3, phase: float) -> void:
	var fire := Node3D.new()
	fire.position = pos
	fire.set_meta("phase", phase)
	fire.add_to_group("deadlane_fire")
	parent.add_child(fire)
	MF.emissive_tapered_cylinder(fire, 0.03, 0.24, 0.72, Vector3(-0.12, 0.32, 0.0), Color("#e45a2c"), 3.0, Vector3.ZERO, 10)
	MF.emissive_tapered_cylinder(fire, 0.03, 0.18, 0.58, Vector3(0.16, 0.25, -0.08), Color("#ffc04f"), 3.8, Vector3.ZERO, 10)
	var glow := OmniLight3D.new()
	glow.light_color = Color("#ff7040")
	glow.light_energy = 1.8
	glow.omni_range = 5.3
	glow.shadow_enabled = false
	fire.add_child(glow)
	_build_smoke_cluster(parent, pos + Vector3(0.0, 1.0, 0.0), phase + 0.4)

static func _build_ember_field(parent: Node3D, pos: Vector3, phase: float) -> void:
	var root := Node3D.new()
	root.position = pos
	parent.add_child(root)
	for i in range(12):
		var ember := Node3D.new()
		ember.position = Vector3(-0.55 + float(i % 4) * 0.35, float(i % 3) * 0.18, -0.28 + float(i % 5) * 0.14)
		ember.set_meta("phase", phase + float(i) * 0.41)
		ember.set_meta("base_position", ember.position)
		ember.add_to_group("deadlane_ember")
		root.add_child(ember)
		MF.emissive_sphere(ember, 0.018 + float(i % 3) * 0.006, Vector3.ZERO, Color("#ff9b3d"), 3.2, 8, 5)

static func _build_smoke_cluster(parent: Node3D, pos: Vector3, phase: float) -> void:
	var smoke := Node3D.new()
	smoke.position = pos
	smoke.set_meta("phase", phase)
	smoke.add_to_group("deadlane_smoke")
	parent.add_child(smoke)
	for i in range(5):
		var alpha := 0.28 - float(i) * 0.025
		var puff := MF.sphere(smoke, 0.28 + float(i) * 0.12, Vector3(sin(float(i)) * 0.16, float(i) * 0.34, cos(float(i) * 0.8) * 0.12), Color(0.15, 0.17, 0.18, alpha), 10, 6)
		var puff_mesh := puff.mesh as SphereMesh
		if puff_mesh != null:
			puff_mesh.material = MF.material(Color(0.15, 0.17, 0.18, alpha), 1.0, 0.0, true)

static func _build_background_smoke(parent: Node3D, pos: Vector3, height: float, phase: float) -> void:
	var smoke := Node3D.new()
	smoke.position = pos
	smoke.set_meta("phase", phase)
	smoke.add_to_group("deadlane_smoke")
	parent.add_child(smoke)
	for i in range(7):
		var alpha := 0.19 - float(i) * 0.012
		var puff := MF.sphere(smoke, 0.85 + float(i) * 0.18, Vector3(sin(float(i) * 1.5) * 0.55, float(i) * height / 7.0, cos(float(i)) * 0.25), Color(0.16, 0.17, 0.19, alpha), 10, 6)
		var puff_mesh := puff.mesh as SphereMesh
		if puff_mesh != null:
			puff_mesh.material = MF.material(Color(0.16, 0.17, 0.19, alpha), 1.0, 0.0, true)

static func _build_beacon(parent: Node3D, pos: Vector3, color: Color) -> void:
	MF.cylinder(parent, 0.11, 0.16, pos, Color("#2a3035"), Vector3.ZERO, 10)
	MF.emissive_sphere(parent, 0.12, pos + Vector3(0.0, 0.12, 0.0), color, 2.6, 10, 6)
	var light := OmniLight3D.new()
	light.position = pos + Vector3(0.0, 0.18, 0.0)
	light.light_color = color
	light.light_energy = 2.0
	light.omni_range = 4.5
	light.shadow_enabled = false
	light.add_to_group("deadlane_beacon")
	parent.add_child(light)

static func _build_ruined_building(parent: Node3D, pos: Vector3, size: Vector3, seed_index: int) -> void:
	var building := Node3D.new()
	building.position = pos
	building.rotation.z = 0.012 * float((seed_index % 3) - 1)
	parent.add_child(building)
	var body_color: Color = Color("#67544c") if seed_index % 3 == 0 else (Color("#46535f") if seed_index % 2 == 0 else Color("#555f69"))
	MF.box(building, size, Vector3.ZERO, body_color)
	# Roof damage and missing corner chunks are represented by dark cavities and broken slabs.
	var damage_side: float = -1.0 if seed_index % 2 == 0 else 1.0
	MF.box(building, Vector3(size.x * 0.42, size.y * 0.22, 0.08), Vector3(damage_side * size.x * 0.31, size.y * 0.34, -size.z * 0.51), Color("#1a2025"), Vector3(0.0, 0.0, 0.08 * damage_side))
	MF.box(building, Vector3(size.x * 0.48, 0.13, size.z * 0.75), Vector3(-damage_side * size.x * 0.18, size.y * 0.5, 0.0), Color("#626a70"), Vector3(0.0, 0.0, 0.08 * damage_side))
	var rows: int = maxi(2, int(size.y / 1.6))
	for row in range(rows):
		for col in range(2):
			if (row + col + seed_index) % 3 == 0:
				continue
			var wx: float = (-0.55 if col == 0 else 0.55) * size.x * 0.35
			var wy: float = -size.y * 0.42 + float(row) * 1.35
			var lit := (row + seed_index) % 7 == 0
			if lit:
				MF.emissive_box(building, Vector3(0.38, 0.28, 0.025), Vector3(wx, wy, -size.z * 0.505), Color("#b07846"), 0.85)
			else:
				MF.box(building, Vector3(0.38, 0.28, 0.025), Vector3(wx, wy, -size.z * 0.505), Color("#151c22"))
	if seed_index % 3 == 0:
		MF.asset_mesh(building, "res://assets/models/rooftop_tank.obj", Vector3(0.0, size.y * 0.5, 0.0), Vector3(0.42, 0.42, 0.42), Color("#515b65"))
	elif seed_index % 4 == 0:
		MF.asset_mesh(building, "res://assets/models/satellite_dish.obj", Vector3(0.0, size.y * 0.5, 0.0), Vector3(0.30, 0.30, 0.30), Color("#59636a"), Vector3(0.0, 0.25 * float(seed_index), 0.0))


static func _build_military_wreck(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var truck := Node3D.new()
	truck.position = pos
	truck.rotation = Vector3(0.0, yaw, 0.04 * (1.0 if yaw >= 0.0 else -1.0))
	parent.add_child(truck)
	MF.asset_mesh(truck, "res://assets/models/military_truck.obj", Vector3(0.0, -0.45, 0.0), Vector3(0.78, 0.78, 0.78), Color("#4d553c"))
	MF.box(truck, Vector3(1.66, 0.07, 2.45), Vector3(0.0, 1.30, 0.65), Color("#465039"), Vector3(0.0, 0.0, 0.05))
	MF.box(truck, Vector3(0.62, 0.04, 0.88), Vector3(-0.46, 0.78, -1.54), Color("#171c20"), Vector3(0.0, 0.08, 0.18))

static func _build_broken_flyover(parent: Node3D, pos: Vector3, yaw: float, side: float) -> void:
	var fly := Node3D.new()
	fly.position = pos
	fly.rotation = Vector3(-0.08, yaw, side * 0.08)
	parent.add_child(fly)
	MF.box(fly, Vector3(6.8, 0.52, 12.0), Vector3.ZERO, Color("#515b65"))
	MF.box(fly, Vector3(6.2, 0.08, 11.5), Vector3(0.0, 0.31, 0.0), Color("#252c34"))
	for x in [-2.9, 2.9]:
		MF.box(fly, Vector3(0.24, 1.0, 11.3), Vector3(x, 0.66, 0.0), Color("#78828d"))
	# fractured end teeth and exposed rebar
	for i in range(6):
		var rx := -2.4 + float(i) * 0.95
		MF.box(fly, Vector3(0.42, 0.24 + 0.10 * float(i % 2), 0.65), Vector3(rx, 0.08, -6.02), Color("#626970"), Vector3(0.0, 0.0, 0.06 * float(i-3)))
		MF.cylinder(fly, 0.035, 1.2, Vector3(rx, 0.02, -6.45), Color("#754737"), Vector3(PI * 0.5, 0.0, 0.0), 8)
	MF.asset_mesh(fly, "res://assets/models/wrecked_car.obj", Vector3(side * 1.6, 0.48, -1.3), Vector3(0.72, 0.72, 0.72), Color("#59636a"), Vector3(0.0, 0.35 * side, 0.0))

static func _build_billboard_ruin(parent: Node3D, pos: Vector3, yaw: float, variant: int) -> void:
	var board := Node3D.new()
	board.position = pos
	board.rotation.y = yaw
	parent.add_child(board)
	MF.asset_mesh(board, "res://assets/models/billboard_frame.obj", Vector3.ZERO, Vector3.ONE, Color("#3f4851"), Vector3(0.0, 0.0, 0.02 * float(variant)))
	MF.box(board, Vector3(3.85, 1.70, 0.055), Vector3(0.0, 2.30, -0.04), Color("#6a554b"), Vector3(0.0, 0.0, 0.08 * float(variant-1)))
	MF.box(board, Vector3(1.25, 0.11, 0.04), Vector3(-0.75, 2.54, -0.08), Color("#171c20"), Vector3(0.0, 0.0, 0.38))

static func _build_utility_cluster(parent: Node3D, pos: Vector3, side: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = side * 0.12
	parent.add_child(root)
	MF.asset_mesh(root, "res://assets/models/utility_transformer.obj", Vector3.ZERO, Vector3.ONE, Color("#59636a"))
	MF.asset_mesh(root, "res://assets/models/shipping_container.obj", Vector3(side * 2.2, -0.2, -0.8), Vector3(0.72, 0.72, 0.72), Color("#6c5545"), Vector3(0.0, side * 0.09, 0.0))
	for i in range(4):
		MF.box(root, Vector3(0.09, 1.8 + float(i) * 0.2, 0.09), Vector3(-side * (0.9 + float(i) * 0.38), 0.9, 0.5 + float(i) * 0.25), Color("#754737"), Vector3(0.0, 0.0, side * 0.22))

static func _build_rooftop_silhouettes(parent: Node3D) -> void:
	MF.asset_mesh(parent, "res://assets/models/rooftop_tank.obj", Vector3(-18.0, 4.9, -49.5), Vector3.ONE * 0.72, Color("#515b65"))
	MF.asset_mesh(parent, "res://assets/models/satellite_dish.obj", Vector3(17.0, 6.5, -55.0), Vector3.ONE * 0.86, Color("#59636a"), Vector3(0.0, 0.68, 0.0))
	MF.asset_mesh(parent, "res://assets/models/satellite_dish.obj", Vector3(-8.0, 8.1, -62.5), Vector3.ONE * 0.72, Color("#59636a"), Vector3(0.0, -0.32, 0.0))
	MF.asset_mesh(parent, "res://assets/models/rooftop_tank.obj", Vector3(8.5, 7.5, -62.0), Vector3.ONE * 0.65, Color("#515b65"))

static func _build_flooded_debris_field(parent: Node3D) -> void:
	# Tiny silhouettes below the bridge add scale without entering the gameplay lane.
	for i in range(12):
		var side: float = -1.0 if i % 2 == 0 else 1.0
		var x := side * (8.0 + float(i % 4) * 2.6)
		var z := -8.0 - float(i) * 4.1
		MF.box(parent, Vector3(0.8 + float(i % 3) * 0.5, 0.18, 1.8 + float(i % 2) * 0.8), Vector3(x, -7.92, z), Color("#3f4851"), Vector3(0.0, float(i) * 0.47, 0.08 * side))


static func _build_helicopter_crash(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var heli := Node3D.new()
	heli.position = pos
	heli.rotation = Vector3(0.10, yaw, -0.14)
	parent.add_child(heli)
	MF.asset_mesh(heli, "res://assets/models/helicopter_wreck.obj", Vector3.ZERO, Vector3(0.78, 0.78, 0.78), Color("#4d553c"))
	MF.box(heli, Vector3(0.92, 0.36, 0.05), Vector3(0.0, 0.80, -1.18), Color("#425258"), Vector3(-0.18, 0.0, 0.0))
	MF.box(heli, Vector3(0.32, 0.05, 1.15), Vector3(1.65, 1.47, 0.12), Color("#754737"), Vector3(0.0, 0.35, 0.18))
	_build_burning_wreck_fx(parent, pos + Vector3(-0.25, 0.55, 0.1), 4.7)

static func _build_crane_ruin(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var crane := Node3D.new()
	crane.position = pos
	crane.rotation = Vector3(0.0, yaw, -0.13)
	parent.add_child(crane)
	MF.asset_mesh(crane, "res://assets/models/crane_tower.obj", Vector3.ZERO, Vector3(0.95, 0.95, 0.95), Color("#754737"))
	# snapped cable and dangling load frame create a recognisable silhouette.
	MF.box(crane, Vector3(0.045, 4.0, 0.045), Vector3(6.55, 5.2, 0.0), Color("#171c20"), Vector3(0.0, 0.0, 0.03))
	MF.box(crane, Vector3(1.15, 0.12, 1.15), Vector3(6.55, 3.15, 0.0), Color("#515b65"), Vector3(0.04, 0.18, 0.08))

static func _build_police_wreck_v15(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation = Vector3(0.0, yaw, 0.07)
	parent.add_child(root)
	MF.asset_mesh(root, "res://assets/models/police_suv_wreck_v15.obj", Vector3(0.0, -0.30, 0.0), Vector3(0.90, 0.90, 0.90), Color("#49545d"))
	# Generic emergency color breakup without logos/trademarks.
	MF.box(root, Vector3(1.64, 0.22, 0.06), Vector3(0.0, 0.50, -1.51), Color("#d4d7d6"), Vector3(-0.10, 0.0, 0.0))
	MF.box(root, Vector3(1.16, 0.08, 0.16), Vector3(0.0, 1.13, 0.16), Color("#242a2f"))
	MF.emissive_box(root, Vector3(0.28, 0.08, 0.14), Vector3(-0.38, 1.17, 0.14), Color("#d9413d"), 1.9)
	MF.emissive_box(root, Vector3(0.28, 0.08, 0.14), Vector3(0.38, 1.17, 0.14), Color("#3e76c5"), 1.9)
	MF.decal_quad(root, "res://assets/textures/scorch_decal_v15.png", Vector2(3.6, 3.3), Vector3(0.0, -0.015, 0.15), 0.0, Color(1.0,1.0,1.0,0.76))
	_build_burning_wreck_fx(root, Vector3(0.25, 0.65, -0.55), 5.2)

static func _build_fire_engine_wreck_v15(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation = Vector3(0.0, yaw, -0.055)
	parent.add_child(root)
	MF.asset_mesh(root, "res://assets/models/fire_engine_wreck_v15.obj", Vector3(0.0, -0.32, 0.0), Vector3(0.86, 0.86, 0.86), Color("#8e3d35"))
	MF.box(root, Vector3(2.0, 0.10, 1.05), Vector3(0.0, 0.86, 0.65), Color("#a4a8a6"), Vector3(0.0, 0.0, 0.02))
	MF.box(root, Vector3(1.7, 0.30, 0.05), Vector3(0.0, 0.88, -1.80), Color("#27343c"))
	MF.emissive_box(root, Vector3(0.19, 0.09, 0.09), Vector3(-0.62, 1.52, -1.0), Color("#d94436"), 1.35)
	MF.decal_quad(root, "res://assets/textures/scorch_decal_v15.png", Vector2(4.8, 4.0), Vector3(0.0, -0.015, 0.2), 0.0, Color(1.0,1.0,1.0,0.66))
	_build_smoke_cluster(root, Vector3(0.4, 1.65, 0.8), 7.1)

static func _build_rubble_cluster_v15(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = yaw
	parent.add_child(root)
	for i in range(3):
		MF.asset_mesh(root, "res://assets/models/rubble_chunk_v15.obj", Vector3(float(i - 1) * 0.72, 0.0, float(i % 2) * 0.36), Vector3(0.72, 0.72, 0.72), Color("#626970"), Vector3(0.0, float(i) * 0.73, 0.0))
	for i in range(4):
		MF.box(root, Vector3(0.05, 0.05, 1.3), Vector3(-0.75 + float(i) * 0.48, 0.34 + float(i % 2) * 0.13, 0.08), Color("#754737"), Vector3(0.15 * float(i), 0.28 * float(i), 0.32 - float(i) * 0.17))
