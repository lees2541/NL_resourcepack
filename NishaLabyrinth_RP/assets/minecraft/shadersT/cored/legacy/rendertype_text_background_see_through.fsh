#version 150

uniform vec4 ColorModulator;

in vec4 vertexColor;

out vec4 fragColor;

void main() {
    vec4 color = vertexColor;
    if (color.a < 0.1) {
        discard;
    }else if (int(color.a*256.0)==235){
        discard;
    }else{
       fragColor = color * ColorModulator; 
    }
    //fragColor = color * ColorModulator;
}
