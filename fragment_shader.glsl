precision mediump float;

float infinity = 1000000.0;

varying vec3 initialRay;

uniform vec3 eye;

uniform vec3 center;
uniform float radius;
struct Cube {
    vec3 minCorner;
    vec3 maxCorner;
};
struct Sphere {
    vec3 center;
    float radius;
};
// 盒子本身
Cube room = Cube(vec3(-1.0, -1.0, -1.0), vec3(1.0, 1.0, 1.0));

Cube c1 = Cube(vec3(0.3, -0.15, -0.15), vec3(0.6, 0.15, 0.15));

Sphere s1 = Sphere(vec3(0.0), 0.25);

float intersectSphere(vec3 origin, vec3 direction, Sphere sphere) {
    // direction不一定要是normallized的，origin + t * direction就是交点的位置
    vec3 toSphere = origin - sphere.center;
    float a = dot(direction, direction);
    float b = 2.0 * dot(toSphere, direction);
    float c = dot(toSphere, toSphere) - sphere.radius * sphere.radius;
    float discriminant = b * b - 4.0 * a * c;
    if (discriminant > 0.0) {
        float t = (-b - sqrt(discriminant)) / (2.0 * a);
        if (t > 0.0)
            return t;
    }
    return infinity + 1.0;
}

float intersectCube(vec3 origin, vec3 direction, Cube cube) {
    vec3 tMin = (cube.minCorner - origin) / direction;
    vec3 tMax = (cube.maxCorner - origin) / direction;
    vec3 t1 = min(tMin, tMax);
    vec3 t2 = max(tMin, tMax);
    float tNear = max(max(t1.x, t1.y), t1.z);
    float tFar = min(min(t2.x, t2.y), t2.z);
    if (tNear < tFar)
        return tFar;
    else
        return infinity + 1.0;
}
vec3 colorOnRoom(vec3 position) {
    if (position.x < -0.9999) {
        return vec3(0.1, 0.5, 1.0);
    } else if (position.x > 0.9999) {
        return vec3(1.0, 0.9, 0.1);
    } else if (position.y > 0.9999) {
        return vec3(0.1, 0.9, 0.1);
    } else if (position.y < -0.9999) {
        return vec3(0.9, 0.1, 0.9);
    }
    return vec3(0.75);
}
vec3 calculateColor(vec3 initialRay) {
    vec3 accumulatedColor = vec3(0.0);

    float t = infinity + 1.0;
    float tRoom = intersectCube(eye, initialRay, room);
    float tSphere1 = intersectSphere(eye, initialRay, s1);
    float tCube1 = intersectCube(eye, initialRay, c1);


    if (t > tRoom) t = tRoom;
    if (t > tSphere1) t = tSphere1;
    if (t > tCube1) t = tCube1;

    if (t > infinity)
        accumulatedColor = vec3(0.0);
    else if (t == tRoom)
        accumulatedColor = colorOnRoom(eye + t * initialRay);
    else if (t == tSphere1)
        accumulatedColor = vec3(0.4, 0.8, 0.2);
    else if (t == tCube1)
        accumulatedColor = vec3(0.4, 0.2, 0.8);
    return accumulatedColor;
}
void main() {

        gl_FragColor = vec4(calculateColor(initialRay), 1.0);
}