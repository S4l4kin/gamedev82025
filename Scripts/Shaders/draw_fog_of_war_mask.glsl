#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, rgba32f) uniform image2D target_mask;
layout(set = 0, binding = 1, std430) readonly buffer DataBuffer {
    float x;
    float y;
    float radius;
    bool seed;
} draw_data;

// The code we want to execute in each invocation
void main() {
    ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
    float dist = distance(uv, vec2(draw_data.x, draw_data.y));
    vec4 color = imageLoad(target_mask, uv);
    if (dist < draw_data.radius){
        if(color.a == 0.0)
            imageStore(target_mask, uv, vec4(1));
    if (dist < 1 && draw_data.seed)
        imageStore(target_mask, uv, vec4(0,0,0,1));

    }

}