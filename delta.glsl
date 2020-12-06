
#extension GL_OES_standard_derivatives : enable

#ifdef GL_ES
precision mediump float;
#endif

#define EP 0.0001
#define SAMPLE 128

uniform vec2 u_resolution; // width, height

float box( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

mat4 rotMatY(float theta) {
    float c = cos(theta);
    float s = sin(theta);

    return mat4(
        vec4(c, 0, s, 0),
        vec4(0, 1, 0, 0),
        vec4(-s, 0, c, 0),
        vec4(0, 0, 0, 1)
    );
}

vec3 rotateY(vec3 p, float theta){
    mat4 mat = rotMatY(theta);
    return (mat*vec4(p,1.0)).xyz;
}

float scene(vec3 p) {
    vec3 box1Size = vec3(0.2, 0.2, 0.3);
    vec3 box1Pos = vec3(0.1, 0.2, 0.0);

    vec3 box2Size = vec3(0.4, 0.15, 0.15);
    vec3 box2Pos =rotateY(vec3(-0.35, 0.1, 0.1), 3.14*0.25);

    float box1 = box(p+box1Pos, box1Size);
    float box2 = box(p+box2Pos, box2Size);

    return max(box1, -box2);
}

vec3 sceneNormal(vec3 pos){
    return normalize(vec3(
        scene(pos) - scene(vec3(pos.x - EP, pos.y, pos.z)),
        scene(pos) - scene(vec3(pos.x, pos.y - EP, pos.z)),
        scene(pos) - scene(vec3(pos.x, pos.y, pos.z - EP))));
}

void main(){

    vec3 color = vec3(0.0);

    // normalized pixel location
    vec2 pixLoc = (gl_FragCoord.xy * 2.0 - u_resolution.xy) / min(u_resolution.x, u_resolution.y);
    vec3 camera = vec3(4.0, 3.0, 10.0);

    vec3 ray = normalize(vec3(pixLoc, 0.0) - camera);
    vec3 pivot = camera;

    vec3 boxSize = vec3(0.5,0.5,0.5);

    for(int i=0;i<SAMPLE;i++) {
        float d = scene(pivot);
        if (d < EP){
            color = sceneNormal(pivot);
            break;
        }
        pivot += ray*d; // move d towards the ray
    }

    gl_FragColor = vec4 (color, 1.0);
}