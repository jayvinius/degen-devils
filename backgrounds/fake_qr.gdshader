shader_type canvas_item;

uniform vec4 dark_color : source_color = vec4(0.05, 0.05, 0.05, 1.0);
uniform vec4 light_color : source_color = vec4(0, 0, 0, 0.0);
uniform int grid_size : hint_range(15, 45) = 25;
uniform int seed : hint_range(0, 65535) = 12345;
uniform float quiet_zone : hint_range(0.0, 0.15) = 0.04;
uniform float module_gap : hint_range(0.0, 0.4) = 0.08;
uniform float corner_radius : hint_range(0.0, 0.5) = 0.15;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Returns 1.0 = dark, 0.0 = light, -1.0 = not part of this finder
float finder_cell(int cx, int cy, int px, int py) {
	int lx = cx - px;
	int ly = cy - py;
	if (lx < 0 || lx >= 7 || ly < 0 || ly >= 7) return -1.0;
	if (lx == 0 || lx == 6 || ly == 0 || ly == 6) return 1.0; // outer ring dark
	if (lx == 1 || lx == 5 || ly == 1 || ly == 5) return 0.0; // separator light
	return 1.0; // inner 3x3 dark
}

// Rounded square SDF — returns 1.0 inside, 0.0 outside
float rounded_square(vec2 local, float radius) {
	vec2 d = abs(local - 0.5) - (0.5 - radius);
	float dist = length(max(d, vec2(0.0))) - radius;
	return dist < 0.0 ? 1.0 : 0.0;
}

void fragment() {
	vec2 uv = UV;

	// Apply quiet zone (white border)
	uv = (uv - quiet_zone) / (1.0 - 2.0 * quiet_zone);
	bool in_quiet = uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0;

	float gs = float(grid_size);
	vec2 cell_uv = uv * gs;
	int cx = clamp(int(cell_uv.x), 0, grid_size - 1);
	int cy = clamp(int(cell_uv.y), 0, grid_size - 1);
	vec2 local = fract(cell_uv); // position within the cell [0,1]

	// --- Determine module value ---
	float cell_val;

	float f1 = finder_cell(cx, cy, 0, 0);
	float f2 = finder_cell(cx, cy, grid_size - 7, 0);
	float f3 = finder_cell(cx, cy, 0, grid_size - 7);

	if (f1 >= 0.0) {
		cell_val = f1;
	} else if (f2 >= 0.0) {
		cell_val = f2;
	} else if (f3 >= 0.0) {
		cell_val = f3;
	} else {
		// Separator: 1-module white border outside each finder
		bool sep = (cx == 7 && cy <= 7) || (cy == 7 && cx <= 7)
				|| (cx == grid_size - 8 && cy <= 7) || (cy == 7 && cx >= grid_size - 8)
				|| (cx == 7 && cy >= grid_size - 8) || (cy == grid_size - 8 && cx <= 7);
		if (sep) {
			cell_val = 0.0;
		} else {
			// Timing pattern: alternating row 6 and col 6
			bool timing = (cy == 6 && cx >= 8 && cx <= grid_size - 9)
					   || (cx == 6 && cy >= 8 && cy <= grid_size - 9);
			if (timing) {
				cell_val = float((cx + cy) % 2 == 0);
			} else {
				// Random data modules
				cell_val = step(0.5, hash(vec2(float(cx + seed), float(cy))));
			}
		}
	}

	// --- Render module with gap and rounded corners ---
	float half_gap = module_gap * 0.5;
	vec2 inner = (local - half_gap) / (1.0 - module_gap); // remap to [0,1] inside gap

	float inside = 0.0;
	if (inner.x >= 0.0 && inner.x <= 1.0 && inner.y >= 0.0 && inner.y <= 1.0) {
		inside = rounded_square(inner, corner_radius);
	}

	float is_dark = cell_val * inside;
	COLOR = in_quiet ? vec4(0.0) : vec4(dark_color.rgb, is_dark * dark_color.a);
}
