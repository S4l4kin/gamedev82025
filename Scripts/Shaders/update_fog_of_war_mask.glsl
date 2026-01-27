#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, rgba32f) readonly uniform image2D target_mask;
layout(set = 0, binding = 1, rgba32f) uniform image2D current_mask;



// The code we want to execute in each invocation
void main() {
    ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
    ivec2 size = imageSize(target_mask);


   vec4 target_color = imageLoad(target_mask, uv);
   vec4 current_color = imageLoad(current_mask, uv);

   if (target_color.a != 0.0 && current_color.a == 0) {
        bool flag = false;
        ivec2 neighbours[8] = ivec2[](ivec2(1,0), ivec2(-1,0), ivec2(0,1), ivec2(0,-1), ivec2(1,1), ivec2(-1,1), ivec2(1,-1), ivec2(-1,-1));
        for(int i = 0; i < neighbours.length(); i++){
            vec4 neighbour_color = imageLoad(current_mask, uv+neighbours[i]);
            if (neighbour_color.a >= 0.01)
                flag = true;
        }
        if (flag || (target_color.r == 0 && target_color.a != current_color.a)) {
            imageStore(current_mask, uv, vec4(1,1,1,min(target_color.a, 0.1)));
        }
   }
   if (current_color.a > 0 && current_color.a < target_color.a)
    imageStore(current_mask, uv, vec4(1,1,1, min(target_color.a, current_color.a+0.1)));
    //imageStore(current_mask, uv, target_color);
}