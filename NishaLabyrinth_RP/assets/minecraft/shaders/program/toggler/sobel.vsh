#version 330

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 MainSize;
    vec2 ControlSize;
    vec2 MainDepthSize;
};

out vec2 texCoord;
out vec2 oneTexel;

// 1.21.9+ full-screen sobel pass.
// Input order matches transparency.json: Main, Control, MainDepth.
void main() {
    vec2 uv = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);

    gl_Position = vec4(uv * 2.0 - 1.0, 0.2, 1.0);
    texCoord = uv;
    oneTexel = 1.0 / MainSize;
}
