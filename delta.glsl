
#ifdef GL_ES
precision mediump float;
#endif

#define EP 0.0001
#define SAMPLE 64

uniform vec2 u_resolution; // width, height

float sphere (vec3 pos, float r) {
    return length(pos) - r;
}

vec3 sphereNormal(vec3 pos, float r){
    return normalize(vec3(
        sphere(pos, r) - sphere(vec3(pos.x - EP, pos.y, pos.z), r),
        sphere(pos, r) - sphere(vec3(pos.x, pos.y - EP, pos.z), r),
        sphere(pos, r) - sphere(vec3(pos.x, pos.y, pos.z - EP), r)));
}

float box( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

vec3 boxNormal(vec3 pos, vec3 b){
    return normalize(vec3(
        box(pos, b) - box(vec3(pos.x - EP, pos.y, pos.z), b),
        box(pos, b) - box(vec3(pos.x, pos.y - EP, pos.z), b),
        box(pos, b) - box(vec3(pos.x, pos.y, pos.z - EP), b)));
}

void main(){

    vec3 color = vec3(0.0);

    // normalized pixel location
    vec2 pixLoc = (gl_FragCoord.xy * 2.0 - u_resolution.xy) / min(u_resolution.x, u_resolution.y);
    vec3 camera = vec3(4.0, 3.0, 10.0);

    vec3 ray = normalize(vec3(pixLoc, 0.0) - camera);
    vec3 pivot = camera;

    // float sphereRadius = 1.1;
    vec3 boxSize = vec3(0.5,0.5,0.5);

    for(int i=0;i<SAMPLE;i++) {
        // here I'm changeing the location of the sphere by adding coordinates
        // adding x moves the sphere to the left
        // adding y moves the sphere to the bottom
        // adding z pushes the sphere further from the camera
        // float d = sphere(pivot+vec3(0.0, 0.1, 0.1), sphereRadius); 
        float d = box(pivot, boxSize);
        if (d < EP){
            color = boxNormal(pivot, boxSize);
            break;
        }
        pivot += ray*d; // move d towards the ray
    }

    gl_FragColor = vec4 (color, 1.0);
}