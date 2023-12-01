#version 150

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;

in vec4 vertexColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    if (color.a == 0.0) {
        discard;
    }
    fragColor = vec4(ColorModulator.rgb * vertexColor.rgb, ColorModulator.a);
    
    if(fragColor.r==0.0 && fragColor.g <0.7 && fragColor.g > 0.6 && fragColor.b == 0.0){//dark_aqua 감지
        fragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }

    /*if(fragColor.rgb==vec3(0.0, 0.66666666, 0.0)){//dark_green 감지
        fragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }*/
    
}
