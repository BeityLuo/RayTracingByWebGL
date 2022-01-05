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
struct Ray {
    vec3 origin;
    vec3 direction;
    int bounceNum;
};
struct Light {
    vec3 position;
    float intensity;
};
// 盒子本身
Cube room = Cube(vec3(-1.0, -1.0, -1.0), vec3(1.0, 1.0, 1.0));
Light light = Light(vec3(0.9, 0.9, 0.9), 0.5);

Cube c1 = Cube(vec3(0.3, -0.8, -0.15), vec3(0.6, -0.5, 0.15));

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
vec3 lightColor(vec3 point) {
    vec3 toLight = light.position - point;
    float t = infinity + 1.0;
    float tRoom = intersectCube(point, toLight, room);
    float tSphere1 = intersectSphere(point, toLight, s1);
    float tCube1 = intersectCube(point, toLight, c1);
    if (t > tRoom) t = tRoom;
    if (t > tSphere1) t = tSphere1;
    if (t > tCube1) t = tCube1;
    if (t < 1.0) {
        // 说明从point到light.positon的路径上有阻挡
        return vec3(0.0);
    } else {
        return vec3(light.intensity);
    }
}
vec3 normalOfCube(vec3 point, Cube cube) {
    if (point.x < cube.minCorner.x + 0.0001) {
        return vec3(-1.0, 0.0, 0.0);
    } else if (point.x > cube.maxCorner.x - 0.0001) {
        return vec3(1.0, 0.0, 0.0);
    } else if (point.y < cube.minCorner.y + 0.0001) {
        return vec3(0.0, -1.0, 0.0);
    } else if (point.y > cube.maxCorner.y - 0.0001) {
        return vec3(0.0, 1.0, 0.0);
    } else if (point.z < cube.minCorner.z + 0.0001) {
        return vec3(0.0, 0.0, -1.0);
    } else {
        return vec3(0.0, 0.0, 1.0);
    }
}
vec3 normalOfSphere(vec3 point, Sphere sphere) {
    return normalize(point - sphere.center);
}

vec3 calculateColor(vec3 origin, vec3 direction) {
    vec3 accumulatedColor = vec3(0.0);

    // colorMask随着bounce增加不断变小。表示当前bounce对color的贡献百分比
    float colorMask = 0.9;
    float reColorMask = 0.2;
    for (int bounce = 0; bounce < 5; bounce++) {
        float t = infinity + 1.0;
        float tRoom = intersectCube(origin, direction, room);
        float tSphere1 = intersectSphere(origin, direction, s1);
        float tCube1 = intersectCube(origin, direction, c1);


        if (t > tRoom) t = tRoom;
        if (t > tSphere1) t = tSphere1;
        if (t > tCube1) t = tCube1;

        if (t > infinity){
            break;
        } else{
            vec3 hitPoint = origin + t * direction;
            vec3 normal;
            if (t == tRoom) {
                normal = -normalOfCube(hitPoint, room); // 这里一定是从内向外碰到了room，因此法线反向
                accumulatedColor += colorMask * colorOnRoom(hitPoint) + colorMask * lightColor(hitPoint);
            }
            else if (t == tSphere1) {
                normal = normalOfSphere(hitPoint, s1);
                accumulatedColor += colorMask * vec3(0.4, 0.8, 0.2)  + colorMask * lightColor(hitPoint);
            } else if (t == tCube1) {
                normal = normalOfCube(hitPoint, c1);
                accumulatedColor += colorMask * vec3(0.4, 0.8, 0.2) + colorMask * lightColor(hitPoint);
            }
            colorMask = colorMask * changeColorMask;
            origin = hitPoint;
            direction = reflect(direction, normal);
        }
    }
    return accumulatedColor;
}
void main() {

    gl_FragColor = vec4(calculateColor(eye, initialRay), 1.0);
}