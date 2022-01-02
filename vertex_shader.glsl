attribute vec3 vertex;

uniform vec3 ray00;
uniform vec3 ray01;
uniform vec3 ray11;
uniform vec3 ray10;

// initialRay在vertex shader中是相机指向四个角的向量之一
// 由于varying在fragment中进行插值计算，因此initialRay在fragment shader
// 中就会是相机指向“当前像素”的向量
varying vec4 initialRay;
void main() {
    vec3 currentRay;
    if (vertex.x < 0.0 && vertex.y < 0.0)
        currentRay = ray00;
    else if (vertex.x < 0.0 && vertex.y > 0.0)
        currentRay = ray01;
    else if (vertex.x > 0.0 && vertex.y > 0.0)
        currentRay = ray11;
    else if (vertex.x > 0.0 && vertex.y < 0.0)
        currentRay = ray10;
    initialRay = vec4(currentRay, 1.0);
    gl_Position = vec4(vertex, 1.0);;
}