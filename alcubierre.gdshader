shader_type canvas_item;

uniform float velocity;
uniform float R;
uniform float sigma;


uniform sampler2D disk_texture: repeat_enable;

uniform int width;
uniform int height;
uniform vec3 camera_position;
uniform mat3 camera_rotation;

uniform float fov = 0.80;

uniform int max_ray_trace_steps = 256;
uniform float step_size = 1.0;
uniform float step_size_drop_factor = 1000.0;

uniform samplerCube sky_map : filter_linear, source_color, hint_default_black;

struct Ray {
	vec3 position;
	vec3 direction;
};


mat4 diagonal(vec4 v) {
    return mat4(
		vec4(v.x, 0.0, 0.0, 0.0),
		vec4(0.0, v.y, 0.0, 0.0),
		vec4(0.0, 0.0, v.z, 0.0),
		vec4(0.0, 0.0, 0.0, v.w)
	);
}

float f(float r_s) {
	return (tanh(sigma * (r_s + R)) - tanh(sigma * (r_s - R))) / (2.0 * tanh(sigma * R));
}

mat4 metric(vec4 x) {
	float x_s = velocity * TIME;
	float r_s = length(vec3( x.y - x_s, x.z, x.w ));
	float f_r_s = f(r_s);

	float vf = velocity * f_r_s;

	return mat4(
		vec4(-vf * vf + 1.0, 2.0 * vf, 0.0, 0.0),
		vec4(2.0 * vf, 1.0, 0.0, 0.0),
		vec4(0.0, 0.0, 1.0, 0.0),
		vec4(0.0, 0.0, 0.0, 1.0)
	);

}

mat4 inverse_metric(vec4 x) {
	return inverse(metric(x));
}

float hamiltonian(vec4 x, vec4 p) {
	mat4 g_inv = inverse_metric(x);
	return 0.5 * dot(g_inv*p, p);
}

vec4 hamiltonian_gradient(vec4 x, vec4 p) {
	const float epislon = 0.001;
	return (vec4(
		hamiltonian(x + vec4(epislon,0,0,0), p),
		hamiltonian(x + vec4(0,epislon,0,0), p),
		hamiltonian(x + vec4(0,0,epislon,0), p),
		hamiltonian(x + vec4(0,0,0,epislon), p)
	) - hamiltonian(x,p)) / epislon;
}

void integration_step(inout vec4 x, inout vec4 p) {
	float r = length(x.yzw);
	float curvature = 1.0 / (r * r * r + 1e-6);
	float factor = step_size / (1.0 + step_size_drop_factor * curvature);

    p = p - factor * hamiltonian_gradient(x, p);
    x = x + factor * inverse_metric(x) * p;
}

vec4 get_null_momentum(vec4 x, vec3 dir) {
	return metric(x) * vec4(1.0, normalize(dir));
}

vec3 get_direction(vec4 x, vec4 p) {
	vec4 dxdt = inverse_metric(x) * p;
	return normalize(dxdt.yzw);
}


vec3 trace_geodesic(Ray ray, float time) {

	vec4 x = vec4(time, ray.position);
	vec4 p = get_null_momentum(x, ray.direction);

	float density = 0.0;


    int current_step = 0;
	Ray stepper = ray;
    for (int i = 0; i < max_ray_trace_steps; i++) {
        integration_step(x, p);
    }
	vec3 sky_color = texture( sky_map, get_direction(x,p) ).rgb;
	return sky_color;
}



void fragment() {

	vec2 normalized_device_coordinates = UV * 2.0 - 1.0;
	float aspect_ratio = float(width)/float(height);
	float fov_scale = tan(fov * 0.5);
	vec3 ray_direction_camera = normalize(vec3(
		normalized_device_coordinates.x * aspect_ratio * fov_scale,
		normalized_device_coordinates.y * fov_scale,
		-1.0
	));

	Ray ray;
	ray.position = camera_position;
	ray.direction = normalize(camera_rotation * ray_direction_camera);

	vec3 color = trace_geodesic(ray, TIME);
	COLOR = vec4(color, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
