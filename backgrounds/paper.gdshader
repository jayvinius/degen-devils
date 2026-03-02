shader_type canvas_item;

uniform vec4 paper_color : source_color = vec4(0.95, 0.92, 0.85, 1.0);
uniform float crumple_scale : hint_range(0.1, 20.0) = 6.0;
uniform float crumple_strength : hint_range(0.0, 2.0) = 0.6;
uniform vec3 light_dir = vec3(0.5, -0.8, 0.4);
uniform float ambient : hint_range(0.0, 1.0) = 0.5;

vec2 hash2(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return fract(sin(p) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);

	float a = dot(hash2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0));
	float b = dot(hash2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
	float c = dot(hash2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
	float d = dot(hash2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));

	return 0.5 + 0.5 * mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	float frequency = 1.0;
	for (int i = 0; i < 6; i++) {
		value += amplitude * noise(p * frequency);
		frequency *= 2.1;
		amplitude *= 0.5;
	}
	return value;
}

// Domain warp: offset UV by two independent FBM passes before sampling
vec2 warp(vec2 uv) {
	float wx = fbm(uv + vec2(1.7, 9.2));
	float wy = fbm(uv + vec2(8.3, 2.8));
	return uv + 0.5 * vec2(wx, wy);
}

void fragment() {
	vec2 uv = UV;

	float eps = 0.002;
	float h   = fbm(warp(uv * crumple_scale));
	float hx  = fbm(warp((uv + vec2(eps, 0.0)) * crumple_scale));
	float hy  = fbm(warp((uv + vec2(0.0, eps)) * crumple_scale));

	// Derive surface normal from height field
	vec3 n = normalize(vec3((h - hx) / eps * crumple_strength, (h - hy) / eps * crumple_strength, 1.0));

	// Diffuse lighting against hardcoded light direction
	vec3 l = normalize(light_dir);
	float diffuse = max(dot(n, l), 0.0);
	float light = ambient + (1.0 - ambient) * diffuse;

	// Darken valleys
	float shade = mix(0.78, 1.0, h) * mix(0.88, 1.0, fbm(warp(uv * crumple_scale * 0.3)));

	// Fiber grain
	float grain = noise(uv * 120.0) * 0.04;

	vec3 color = paper_color.rgb * shade * light + grain;
	COLOR = vec4(color, paper_color.a);
}
