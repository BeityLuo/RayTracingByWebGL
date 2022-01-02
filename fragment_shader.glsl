precision mediump float;
varying vec4 initialRay;
vec3 calculateColor(vec4 initialRay) {
    vec3 accumulatedColor = vec3(0.5);


    return accumulatedColor;
}
void main() {
    gl_FragColor = vec4(calculateColor(initialRay), 1.0);
}