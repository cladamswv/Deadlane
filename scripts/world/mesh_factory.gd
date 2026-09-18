extends RefCounted
class_name MeshFactory

static var _material_cache: Dictionary = {}

static func material(color: Color, roughness: float = 0.8, metallic: float = 0.0, transparent: bool = false) -> StandardMaterial3D:
	var surface := _surface_texture_for_color(color)
	var surface_name := String(surface.get("name", ""))
	var key := "%s|%.2f|%.2f|%s|%s" % [color.to_html(true), roughness, metallic, str(transparent), surface_name]
	if _material_cache.has(key):
		return _material_cache[key] as StandardMaterial3D
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	if surface_name == "water":
		mat.albedo_color = Color(0.92, 0.97, 1.0)
		mat.roughness = 0.28
	if not surface_name.is_empty():
		var albedo_path := "res://assets/textures/%s_albedo.png" % surface_name
		var normal_path := "res://assets/textures/%s_normal.png" % surface_name
		var roughness_path := "res://assets/textures/%s_roughness.png" % surface_name
		if ResourceLoader.exists(albedo_path):
			mat.albedo_texture = load(albedo_path) as Texture2D
			mat.uv1_triplanar = true
			mat.uv1_world_triplanar = true
			var tiling := float(surface.get("tiling", 1.0))
			mat.uv1_scale = Vector3(tiling, tiling, tiling)
		if ResourceLoader.exists(normal_path):
			mat.normal_enabled = true
			mat.normal_texture = load(normal_path) as Texture2D
			mat.normal_scale = float(surface.get("normal", 0.8))
		if ResourceLoader.exists(roughness_path):
			mat.roughness_texture = load(roughness_path) as Texture2D
	if transparent:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	_material_cache[key] = mat
	return mat

static func _surface_texture_for_color(color: Color) -> Dictionary:
	var hex := color.to_html(false).to_lower()
	if hex in ["343d49", "252c34"]:
		return {"name": "asphalt", "tiling": 0.55, "normal": 1.05}
	if hex in ["78828d", "515b65", "626970"]:
		return {"name": "concrete", "tiling": 0.72, "normal": 0.8}
	if hex in ["36414b", "3f4851", "444f59", "46525c", "4a5660", "39434c", "353735", "3a4650", "566570", "7b4248", "3f6274", "6c6651", "727b82", "d8d9d2", "a48d58", "6c5545", "4e6870", "59636a"]:
		return {"name": "painted_metal", "tiling": 0.9, "normal": 0.65}
	if hex in ["774838", "754737"]:
		return {"name": "rusty_metal", "tiling": 0.8, "normal": 0.95}
	if hex in ["d87936", "9f4f2c", "e98c48"]:
		return {"name": "survivor_fabric", "tiling": 2.4, "normal": 0.65}
	if hex in ["242b33", "39434d", "5c5264", "393941", "70464e", "4a555f", "60485b", "57445f", "51404a", "46374f", "403a48", "242932", "2a3036", "3a3035"]:
		return {"name": "dark_cloth", "tiling": 2.5, "normal": 0.55}
	if hex in ["849a68", "667a53", "80a653", "5f7d42", "748a5b", "6d974d", "4e6c39", "6f8055", "4f5d3d"]:
		return {"name": "zombie_skin", "tiling": 3.0, "normal": 0.75}
	if hex in ["171c20", "1a2025", "151c22", "12171c"]:
		return {"name": "charred", "tiling": 1.3, "normal": 0.8}
	if hex in ["67544c", "6a554b", "70584e"]:
		return {"name": "brick", "tiling": 0.72, "normal": 0.9}
	if hex in ["4d553c", "535c40", "465039"]:
		return {"name": "olive_canvas", "tiling": 1.8, "normal": 0.7}
	if hex in ["847758", "81765e", "8b7c59"]:
		return {"name": "sandbag", "tiling": 2.4, "normal": 0.75}
	if hex in ["425258", "30414c", "253642", "1e2d37"]:
		return {"name": "dirty_glass", "tiling": 1.2, "normal": 0.28}
	if hex in ["bc7b2a", "df7434", "d7ad3f"]:
		return {"name": "hazard_plastic", "tiling": 1.3, "normal": 0.55}
	if hex in ["1e2022", "171c21", "242a2f"]:
		return {"name": "rubber", "tiling": 1.6, "normal": 0.65}
	if hex in ["244c63", "315d72"]:
		return {"name": "water", "tiling": 0.22, "normal": 0.75}
	return {}


static func emissive_material(color: Color, energy: float = 2.0, transparent: bool = false) -> StandardMaterial3D:
	var key := "emissive|%s|%.2f|%s" % [color.to_html(true), energy, str(transparent)]
	if _material_cache.has(key):
		return _material_cache[key] as StandardMaterial3D
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.45
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = energy
	if transparent:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material_cache[key] = mat
	return mat

static func emissive_box(parent: Node, size: Vector3, pos: Vector3, color: Color, energy: float = 2.0, rotation: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = emissive_material(color, energy, color.a < 0.99)
	node.mesh = mesh
	node.position = pos
	node.rotation = rotation
	parent.add_child(node)
	return node

static func emissive_sphere(parent: Node, radius: float, pos: Vector3, color: Color, energy: float = 2.0, segments: int = 12, rings: int = 7) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = maxi(8, segments)
	mesh.rings = maxi(5, rings)
	mesh.material = emissive_material(color, energy, color.a < 0.99)
	node.mesh = mesh
	node.position = pos
	parent.add_child(node)
	return node

static func emissive_tapered_cylinder(parent: Node, top_radius: float, bottom_radius: float, height: float, pos: Vector3, color: Color, energy: float = 2.0, rotation: Vector3 = Vector3.ZERO, segments: int = 10) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_radius
	mesh.bottom_radius = bottom_radius
	mesh.height = height
	mesh.radial_segments = maxi(6, segments)
	mesh.material = emissive_material(color, energy, color.a < 0.99)
	node.mesh = mesh
	node.position = pos
	node.rotation = rotation
	parent.add_child(node)
	return node

static func asset_mesh(parent: Node, path: String, pos: Vector3, scale_value: Vector3, color: Color, rotation: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var resource := load(path)
	if resource is Mesh:
		node.mesh = resource as Mesh
	else:
		push_error("Could not load mesh asset: %s" % path)
	node.material_override = material(color)
	node.position = pos
	node.rotation = rotation
	node.scale = scale_value
	parent.add_child(node)
	return node

static func box(parent: Node, size: Vector3, pos: Vector3, color: Color, rotation: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material(color)
	node.mesh = mesh
	node.position = pos
	node.rotation = rotation
	parent.add_child(node)
	return node

static func sphere(parent: Node, radius: float, pos: Vector3, color: Color, segments: int = 14, rings: int = 9) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = maxi(8, segments)
	mesh.rings = maxi(5, rings)
	mesh.material = material(color)
	node.mesh = mesh
	node.position = pos
	parent.add_child(node)
	return node

static func cylinder(parent: Node, radius: float, height: float, pos: Vector3, color: Color, rotation: Vector3 = Vector3.ZERO, segments: int = 12) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = maxi(6, segments)
	mesh.material = material(color)
	node.mesh = mesh
	node.position = pos
	node.rotation = rotation
	parent.add_child(node)
	return node

static func tapered_cylinder(parent: Node, top_radius: float, bottom_radius: float, height: float, pos: Vector3, color: Color, rotation: Vector3 = Vector3.ZERO, segments: int = 10) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_radius
	mesh.bottom_radius = bottom_radius
	mesh.height = height
	mesh.radial_segments = maxi(6, segments)
	mesh.material = material(color)
	node.mesh = mesh
	node.position = pos
	node.rotation = rotation
	parent.add_child(node)
	return node

static func capsule(parent: Node, radius: float, height: float, pos: Vector3, color: Color, rotation: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mesh.rings = 6
	mesh.material = material(color)
	node.mesh = mesh
	node.position = pos
	node.rotation = rotation
	parent.add_child(node)
	return node

static func decal_material(texture_path: String, tint: Color = Color.WHITE) -> StandardMaterial3D:
	var key := "decal|%s|%s" % [texture_path, tint.to_html(true)]
	if _material_cache.has(key):
		return _material_cache[key] as StandardMaterial3D
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tint
	mat.roughness = 0.86
	mat.metallic = 0.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	if ResourceLoader.exists(texture_path):
		mat.albedo_texture = load(texture_path) as Texture2D
	else:
		push_error("Missing decal texture: %s" % texture_path)
	_material_cache[key] = mat
	return mat

static func decal_quad(parent: Node, texture_path: String, size: Vector2, pos: Vector3, rotation_y: float = 0.0, tint: Color = Color.WHITE) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := QuadMesh.new()
	mesh.size = size
	mesh.material = decal_material(texture_path, tint)
	node.mesh = mesh
	node.position = pos
	node.rotation = Vector3(-PI * 0.5, rotation_y, 0.0)
	parent.add_child(node)
	return node
