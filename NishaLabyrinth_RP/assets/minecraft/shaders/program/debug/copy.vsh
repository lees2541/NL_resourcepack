#version 120

attribute vec4 Position;

uniform mat4 ProjMat;
uniform vec2 OutSize;
uniform vec2 InSize;

in vec2 texCoord;

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
}
