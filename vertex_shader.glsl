attribute vec3 vertex;

uniform vec3 ray00;
uniform vec3 ray01;
uniform vec3 ray11;
uniform vec3 ray10;

// initialRay在vertex shader中是相机指向四个角的向量之一
// 由于varying在fragment中进行插值计算，因此initialRay在fragment shader
// 中就会是相机指向“当前像素”的向量
varying vec3 initialRay;
void main() {
    vec2 percent = vertex.xy * 0.5 + 0.5;
    // 根据输入顶点的不同，决定不同的初始光线
    // 比如输入(1, 1)时，就用视点看向盒子右上前角的光线
    if (vertex.x < 0.0 && vertex.y < 0.0)
        initialRay = ray00;
    else if (vertex.x < 0.0 && vertex.y > 0.0)
        initialRay = ray01;
    else if (vertex.x > 0.0 && vertex.y > 0.0)
        initialRay = ray11;
    else if (vertex.x > 0.0 && vertex.y < 0.0)
        initialRay = ray10;

    gl_Position = vec4(vertex, 1.0);
}