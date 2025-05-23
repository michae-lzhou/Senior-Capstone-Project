extends Control

@onready var graph_holder = $GraphHolder

func _ready():
	var graph_scene_path = get_graph_scene_path(GSession.current_game)
	if graph_scene_path != "":
		var graph_scene = load(graph_scene_path)
		var graph_instance = graph_scene.instantiate()
		graph_holder.add_child(graph_instance)
	else:
		push_warning("No graph scene found for game: %s" % GSession.current_game)

func get_graph_scene_path(game_name: String) -> String:
	match game_name:
		"reaction":
			return "res://graphs/ReactionGraph.tscn"
		"aim":
			return "res://graphs/AimGraph.tscn"
		"tracking":
			return "res://graphs/TrackingGraph.tscn"
		"flick":
			return "res://graphs/FlickGraph.tscn"
		_:
			return ""

#extends Line2D
#
## Global scaling factors
#var GLOBAL_X_SCALE: float = 2.0
#var GLOBAL_Y_SCALE: float = 2.0
#
## Data points: (session number, score)
#var base_data_points = [
	#Vector2(1, 1000), Vector2(2, 1050),
	#Vector2(3, 1100), Vector2(4, 1150),
	#Vector2(5, 1080), Vector2(6, 1300),
	#Vector2(7, 1250), Vector2(8, 1350),
	#Vector2(9, 1200), Vector2(10, 1400),
	#Vector2(11, 1300), Vector2(12, 1450),
	#Vector2(13, 1380), Vector2(14, 1320),
	#Vector2(15, 1450)
#]
#
## Offset for shifting the graph
#var offset_x: float = 205  # Horizontal shift
#var offset_y: float = 100  # Vertical shift from the top
#
#func _ready():
	#draw_axes()
	#draw_graph()
	#draw_shading()
#
#func get_scaled_points():
	#var scaled_points = []
#
	## Find the minimum and maximum y values (scores) to scale properly
	#var min_score = base_data_points[0].y
	#var max_score = base_data_points[0].y
	#for point in base_data_points:
		#min_score = min(min_score, point.y)
		#max_score = max(max_score, point.y)
#
	## Calculate graph dimensions (scaled)
	#var graph_width = 380 * GLOBAL_X_SCALE  # Width of the graph
	#var graph_height = 220 * GLOBAL_Y_SCALE  # Height of the graph
#
	## Set vertical scaling limits (20% and 75% of the graph height)
	#var min_y_scale = graph_height * 0.20  # 20% of the height
	#var max_y_scale = graph_height * 0.75  # 75% of the height
#
	## Scale the data points
	#for point in base_data_points:
		#var session = point.x  # The session number is the x-component
		#var score = point.y    # The score is the y-component
#
		## Scale x-axis based on the number of data points (spread them evenly)
		#var scaled_x = (session / len(base_data_points)) * graph_width
#
		## Scale y-axis based on the score, mapping score to the desired range
		#var scaled_y = lerp(min_y_scale, max_y_scale, (score - min_score) / (max_score - min_score))
#
		## Store the scaled points, applying both the horizontal and vertical offsets
		#scaled_points.append(Vector2(scaled_x + offset_x, graph_height - scaled_y + offset_y))  # Add both offsets
#
	#return scaled_points
#
#func draw_graph():
	#var graph = Line2D.new()
	#graph.width = 3 * GLOBAL_X_SCALE  # Scale line thickness
	#graph.default_color = Color(0, 0.5, 1)  # Blue color
#
	#for point in get_scaled_points():
		#graph.add_point(point)
#
	#add_child(graph)
#
## Function to draw the shading underneath the graph
#func draw_shading():
	#var polygon = Polygon2D.new()
	#var scaled_points = get_scaled_points()
#
	## Set an additional vertical offset for shifting the bottom row
	#var bottom_offset = 140  # You can change this value to adjust how much you want to shift it
#
	## Calculate the original bottom y position
	#var bottom_y = offset_y + 100 + (220 * GLOBAL_Y_SCALE)  # Bottom of the graph area
#
	## Shift the bottom y position by the offset
	#bottom_y -= bottom_offset  # Subtract to move the bottom row up
#
	#var points = []
	#for point in scaled_points:
		#points.append(point)
#
	## Add the shifted bottom points
	#points.append(Vector2(scaled_points[scaled_points.size() - 1].x, bottom_y))  # Bottom-right point
	#points.append(Vector2(scaled_points[0].x, bottom_y))  # Bottom-left point
#
	## Set the polygon color (shading color)
	#polygon.polygon = points
	#polygon.color = Color(0, 0.5, 1, 0.2)  # Set a semi-transparent blue
#
	#add_child(polygon)
#
#func draw_axes():
	#var x_axis = Line2D.new()
	#x_axis.width = 2 * GLOBAL_X_SCALE
	#x_axis.default_color = Color(1, 1, 1)  # White axis
	## Apply both offsets to axis points
	#x_axis.add_point(Vector2(10 * GLOBAL_X_SCALE + offset_x, 200 * GLOBAL_Y_SCALE + offset_y))  # Start at left
	#x_axis.add_point(Vector2(380 * GLOBAL_X_SCALE + offset_x, 200 * GLOBAL_Y_SCALE + offset_y))  # Extend right
	#add_child(x_axis)
#
	#var y_axis = Line2D.new()
	#y_axis.width = 2 * GLOBAL_Y_SCALE
	#y_axis.default_color = Color(1, 1, 1)  # White axis
	## Apply both offsets to axis points
	#y_axis.add_point(Vector2(10 * GLOBAL_X_SCALE + offset_x, 10 * GLOBAL_Y_SCALE + offset_y))  # Top
	#y_axis.add_point(Vector2(10 * GLOBAL_X_SCALE + offset_x, 200 * GLOBAL_Y_SCALE + offset_y))  # Bottom
	#add_child(y_axis)
