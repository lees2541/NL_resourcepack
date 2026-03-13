#version 330

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

out vec2 texCoord;
flat out vec2 oneTexel;

// Full-screen copy pass for 1.21.9+ / 1.21.11
// Replaces the old Position-based quad with a 3-vertex full-screen triangle.
void main() {
    vec2 uv = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);

    gl_Position = vec4(uv * 2.0 - 1.0, 0.2, 1.0);
    texCoord = uv;
    oneTexel = 1.0 / OutSize;
}
