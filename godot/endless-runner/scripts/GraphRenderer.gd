extends Line2D
@export var data_key: String = ""  # The key to use in GSession
# Global scaling factors
var GLOBAL_X_SCALE: float = 2.0
var GLOBAL_Y_SCALE: float = 2.0
# Base dimensions before scaling
var BASE_GRAPH_WIDTH: float = 380
var BASE_GRAPH_HEIGHT: float = 220
# Offset for shifting the graph
var offset_x: float = 125  # Horizontal shift
var offset_y: float = 100  # Vertical shift from the top

func _ready():
	if data_key == "":
		push_warning("No data_key provided.")
		return
		
	var data_array = GSession.get(data_key)
	if data_array == null or typeof(data_array) != TYPE_ARRAY:
		push_warning("Invalid or missing data for key: %s" % data_key)
		return
		
	draw_axes()
	draw_graph(data_array)
	draw_shading(data_array)

func get_scaled_points(data_points: Array) -> Array:
	var scaled_points = []
	
	# Find min and max scores
	var min_score = data_points[0].y
	var max_score = data_points[0].y
	for point in data_points:
		min_score = min(min_score, point.y)
		max_score = max(max_score, point.y)
	
	# Calculate actual graph dimensions
	var graph_width = BASE_GRAPH_WIDTH * GLOBAL_X_SCALE
	var graph_height = BASE_GRAPH_HEIGHT * GLOBAL_Y_SCALE
	
	# Y-scale range
	var min_y_scale = graph_height * 0.20
	var max_y_scale = graph_height * 0.75
	
	# Fixed x-axis start position
	var x_start = offset_x + 10 * GLOBAL_X_SCALE
	
	# For each data point
	for i in range(data_points.size()):
		var point = data_points[i]
		var score = point.y
		
		# Calculate position based on index rather than the x value
		var scaled_x = (float(i) / max(1.0, float(data_points.size() - 1))) * graph_width
		var scaled_y = lerp(min_y_scale, max_y_scale, inverse_lerp(min_score, max_score, score))
		
		scaled_points.append(Vector2(
			x_start + scaled_x, 
			graph_height - scaled_y + offset_y
		))
	
	return scaled_points

func draw_graph(data_points: Array):
	var graph = Line2D.new()
	graph.width = 3 * GLOBAL_X_SCALE
	graph.default_color = Color(0, 0.5, 1)
	
	for point in get_scaled_points(data_points):
		graph.add_point(point)
		
	add_child(graph)

func draw_shading(data_points: Array):
	var polygon = Polygon2D.new()
	var scaled_points = get_scaled_points(data_points)
	
	# Calculate baseline y position (same as x-axis)
	var bottom_y = offset_y + 200 * GLOBAL_Y_SCALE
	
	var my_points = []
	
	# Add all curve points
	for point in scaled_points:
		my_points.append(point)
	
	# Add bottom-right corner
	my_points.append(Vector2(scaled_points[scaled_points.size() - 1].x, bottom_y))
	# Add bottom-left corner
	my_points.append(Vector2(scaled_points[0].x, bottom_y))
	
	# Set the polygon points - FIXED: was using "points" instead of "my_points"
	polygon.polygon = my_points
	polygon.color = Color(0, 0.5, 1, 0.2)
	
	add_child(polygon)

func draw_axes():
	# Fixed x-axis start position
	var x_start = offset_x + 10 * GLOBAL_X_SCALE
	var x_end = offset_x + BASE_GRAPH_WIDTH * GLOBAL_X_SCALE
	var y_axis_height = 200 * GLOBAL_Y_SCALE
	
	# Draw X-axis
	var x_axis = Line2D.new()
	x_axis.width = 2 * GLOBAL_X_SCALE
	x_axis.default_color = Color(1, 1, 1)
	x_axis.add_point(Vector2(x_start, offset_y + y_axis_height))
	x_axis.add_point(Vector2(x_end, offset_y + y_axis_height))
	add_child(x_axis)
	
	# Draw Y-axis
	var y_axis = Line2D.new()
	y_axis.width = 2 * GLOBAL_Y_SCALE
	y_axis.default_color = Color(1, 1, 1)
	y_axis.add_point(Vector2(x_start, offset_y + 10 * GLOBAL_Y_SCALE))
	y_axis.add_point(Vector2(x_start, offset_y + y_axis_height))
	add_child(y_axis)
