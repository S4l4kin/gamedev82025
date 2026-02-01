#[compute]
#version 450

#define START_MASK_COLOR vec3(0,0,1)

// Invocations in the (x, y, z) dimension
layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, rgba32f) uniform image2D target_mask;
layout(set = 0, binding = 1, rgba32f) uniform image2D current_mask;
layout(set = 0, binding = 2, std430) readonly buffer PointBuffer {
    vec2 points[];
};
layout(set = 0, binding = 3, std430) readonly buffer DataBuffer {
    float radius;
} draw_data;


float easing(float dist){
    return (draw_data.radius-dist) / draw_data.radius;
}

void draw_pixel(ivec2 uv, float alpha){
    imageStore(target_mask, uv, vec4(START_MASK_COLOR,alpha));
    imageStore(current_mask, uv, vec4(vec3(1),alpha));

}

float distance_to_polygon(){
    vec2 uv = gl_GlobalInvocationID.xy;
    float closest_distance = 1.0 / 0.0;
    for ( int i = 0, j = points.length() - 1 ; i < points.length() ; j = i++ )
    {
        vec2 a = points[i];
        vec2 b = points[j];
        vec2 closest;
        vec2 ab = b-a;
        vec2 ap = uv-a;

        float proj = dot(ap, ab);
        float length = pow(length(ab),2);

        float d = proj/length;

        if (d <= 0)
            closest = a;
        else if (d >= 1)
            closest = b;
        else {
            closest = a + ab*d;
        }
        if (distance(uv, closest) < closest_distance)
            closest_distance = distance(uv, closest);
    }
    
    
    return closest_distance;
}

bool in_bound(){
    vec2 uv = gl_GlobalInvocationID.xy;
    float minX = points[ 0 ].x;
    float maxX = points[ 0 ].x;
    float minY = points[ 0 ].y;
    float maxY = points[ 0 ].y;
    for ( int i = 1 ; i < points.length() ; i++ )
    {
        vec2 q = points[ i ];
        minX = min( q.x, minX );
        maxX = max( q.x, maxX );
        minY = min( q.y, minY );
        maxY = max( q.y, maxY );
    }

    if ( uv.x < minX || uv.x > maxX || uv.y < minY || uv.y > maxY )
    {
        return false;
    }

    // https://wrf.ecse.rpi.edu/Research/Short_Notes/pnpoly.html
    bool inside = false;
    for ( int i = 0, j = points.length() - 1 ; i < points.length() ; j = i++ )
    {
        if ( ( points[ i ].y > uv.y ) != ( points[ j ].y > uv.y ) &&
             uv.x < ( points[ j ].x - points[ i ].x ) * ( uv.y - points[ i ].y ) / ( points[ j ].y - points[ i ].y ) + points[ i ].x )
        {
            inside = !inside;
        }
    }

    return inside;
}

// The code we want to execute in each invocation
void main() {
    ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
    if (!in_bound()) {
        float dist = distance_to_polygon();
        float alpha = min(easing(dist), 1);
        if (dist > draw_data.radius)
            draw_pixel(uv, 1);
        else
            draw_pixel(uv, 1-alpha);

    }
    //imageStore(target_mask, uv, vec4(0,0,0,1));

   //for (int i=0; i < points.length(); i++){
   //    vec2 point = points[i];
   //    float dist = distance(uv, point);
   //    if (dist <= draw_data.radius){
   //        imageStore(target_mask, uv, vec4(0,0,0,1));
   //    }
   //}
}

