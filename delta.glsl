
#ifdef GL_ES
precision mediump float;
#endif

#define EP 0.0001

uniform vec2 u_resolution; // width, height

float sphere (vec3 pos, float r) {
    return length(pos) - r;
}

vec3 getSphereNormal(vec3 pos, float r){
    return vec3(1.0);
}

void main(){

    vec3 color = vec3(0.0);

    // normalized pixel location
    vec2 pixLoc = (gl_FragCoord.xy * 2.0 - u_resolution.xy) / min(u_resolution.x, u_resolution.y);
    vec3 camera = vec3(0.0, 0.0, 10.0);

    vec3 ray = normalize(vec3(pixLoc, 0.0) - camera);
    vec3 pivot = camera;

    float sphereRadius = 1.0;

    for(int i=0;i<16;i++) {
        float d = sphere(pivot, sphereRadius);
        if (d < EP){
            color = getSphereNormal(pivot, sphereRadius);
            break;
        }
        pivot += ray*d; // move d towards the ray
    }

    gl_FragColor = vec4 (color, 1.0);
}