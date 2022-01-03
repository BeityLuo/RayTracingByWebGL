
function createShader(gl, type, source) {
    let shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    let success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (success) {
        return shader;
    }

    if (type === gl.VERTEX_SHADER)
        console.log("create vertex shader failed!")
    else
        console.log('create fragment shader failed!')
    console.log(gl.getShaderInfoLog(shader))
    gl.deleteShader(shader)
}
function createProgram(gl, vertexShaderSource, fragmentShaderSource) {
    let vertexShader = createShader(gl, gl.VERTEX_SHADER, vertexShaderSource)
    let fragmentShader = createShader(gl, gl.FRAGMENT_SHADER ,fragmentShaderSource)
    if (!vertexShader || !fragmentShader) {
        return
    }
    let program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    let success = gl.getProgramParameter(program, gl.LINK_STATUS);
    if (success) {
        return program;
    }


    console.log(gl.getProgramInfoLog(program))
    gl.deleteProgram(program)
}

function Utilities() {
}
Utilities.makePerspective = (fieldOfViewInRadians, aspect, near, far) => {
    let f = Math.tan(Math.PI * 0.5 - 0.5 * fieldOfViewInRadians)
    let rangeInv = 1.0 / (near - far)

    return Matrix.create([
        [f / aspect, 0, 0, 0],
        [0, f, 0, 0],
        [0, 0, (near + far) * rangeInv, -1],
        [0, 0, near * far * rangeInv * 2, 0]
    ])
}
Utilities.setUniforms = (gl, program, uniforms) => {
    for (let name in uniforms) {
        let value = uniforms[name];
        let location = gl.getUniformLocation(program, name);
        if (location == null) continue;
        if (value instanceof Vector) {
            gl.uniform3fv(location, new Float32Array([value.elements[0], value.elements[1], value.elements[2]]));
        } else if (value instanceof Matrix) {
            gl.uniformMatrix4fv(location, false, new Float32Array(value.flatten()));
        } else {
            gl.uniform1f(location, value);
        }
    }
}
const vertices = [
    -1, -1,
    1, -1,
    1, 1,
    1, 1,
    -1, 1,
    -1, -1,
]

function readFile(fileName) {
    let file = new File(fileName, )

    let reader = new FileReader()
    reader.readAsText(file)
    reader.onload = function () {
        console.log(this.result)
    }

}

function main() {
    // 初始化阶段
    let canvas = document.querySelector('#canvas')
    let gl = canvas.getContext('webgl')
    let vertexShaderSource = document.querySelector('#v').textContent
    let fragmentShaderSource = document.querySelector('#f').textContent



    if (!gl) {
        console.log('WebGL not supported!')
        return
    }
    // 创建program
    let program = createProgram(gl, vertexShaderSource, fragmentShaderSource)

    //let vertexAttributeLocation = gl.getAttribLocation(program, "vertex");


    // 给GLSL的各种属性赋值
    let uniforms = {}

    let eye = Vector.create([0, 0, 2.8])
    uniforms.ray00 = Vector.create([-1, -1, 0]).subtract(eye)
    uniforms.ray01 = Vector.create([-1, 1, 0]).subtract(eye)
    uniforms.ray11 = Vector.create([1, 1, 0]).subtract(eye)
    uniforms.ray10 = Vector.create([1, -1, 0]).subtract(eye)

    gl.useProgram(program) // 必须useProgram，再向uniform赋值

    uniforms.eye = eye
    uniforms.center = Vector.create([0, 0, 0])
    uniforms.radius = 0.25

    Utilities.setUniforms(gl, program, uniforms)


        // 输入数据
    let vertexBuffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer)
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW)

    let vertexAttributeLocation = gl.getAttribLocation(program, 'vertex')
    gl.vertexAttribPointer(vertexAttributeLocation, 2, gl.FLOAT, false, 0, 0)
    gl.enableVertexAttribArray(vertexAttributeLocation)

    gl.clearColor(0, 0, 0, 0)
    gl.clear(gl.COLOR_BUFFER_BIT)

    gl.drawArrays(gl.TRIANGLES, 0, 6)
}
main()