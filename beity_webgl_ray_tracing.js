
function createShader(gl, type, source) {
    let shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    let success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (success) {
        return shader;
    }

    console.log("createShader failed!: \n" + gl.getShaderInfoLog(shader))
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
const vertices = [
    -1, -1,
    1, -1,
    1, 1,
    1, 1,
    -1, 1,
    -1, -1,
]

function main() {
    // 初始化阶段
    let canvas = document.querySelector('#canvas')
    let gl = canvas.getContext('webgl')
    let vertexShaderSource = document.querySelector('#vertex_shader').text
    let fragmentShaderSource = document.querySelector('#fragment_shader').text
    if (!gl) {
        console.log('WebGL not supported!')
        return
    }
    // 创建program
    let program = createProgram(gl, vertexShaderSource, fragmentShaderSource)

    //let vertexAttributeLocation = gl.getAttribLocation(program, "vertex");


    // 给GLSL的各种属性赋值

    // 输入数据
    let vertexBuffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer)
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW)

    let vertexAttributeLocation = gl.getAttribLocation(program, 'vertex')
    gl.vertexAttribPointer(vertexAttributeLocation, 2, gl.FLOAT, false, 0, 0)
    gl.enableVertexAttribArray(vertexAttributeLocation)

    gl.clearColor(0, 0, 0, 0)
    gl.clear(gl.COLOR_BUFFER_BIT)
    gl.useProgram(program)
    gl.drawArrays(gl.TRIANGLES, 0, 6)
}
main()