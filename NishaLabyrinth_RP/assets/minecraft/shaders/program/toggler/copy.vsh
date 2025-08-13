#version 150

#moj_import <minecraft:projection.glsl>

in vec4 Position;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

out vec2 texCoord;
flat out vec2 oneTexel;

// Modified blit to work for copying between buffers of different sizes

void main(){

    float x = -1.0; 
    float y = -1.0;

    if (Position.x > 0.001){
        x = 1.0;
    }
    if (Position.y > 0.001){
        y = 1.0;
    }

    gl_Position = vec4(x, y, 0.2, 1.0);

    texCoord = Position.xy / OutSize;

    oneTexel = 1.0 / OutSize;
}