extends MeshInstance3D

func _ready():
	if mesh is ArrayMesh:
		print(mesh.get_faces())
		pass