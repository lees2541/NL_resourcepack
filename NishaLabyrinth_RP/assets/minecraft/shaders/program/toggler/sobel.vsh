#version 150

in vec4 Position;

uniform mat4 ProjMat;
uniform vec2 InSize;
uniform vec2 OutSize;

uniform sampler2D ControlSampler;

out vec2 texCoord;
out vec2 oneTexel;

void main(){
    vec4 outPos = ProjMat * vec4(Position.xy, 0.0, 1.0);
    gl_Position = vec4(outPos.xy, 0.2, 1.0);

    oneTexel = 1.0 / InSize;

    texCoord = Position.xy / OutSize;
    /*vec4 control_color = texelFetch(ControlSampler, ivec2(0, 1), 0); 
    if(int(control_color.r * 255.)==254 && int(control_color.g * 255.)==253 && int(control_color.b * 255.) == 3){
        vec4 outPos = ProjMat * vec4(Position.xy, 0.0, 1.0);
        gl_Position = vec4(outPos.xy, 0.2, 1.0);

        oneTexel = 1.0 / InSize;

        texCoord = Position.xy / OutSize;
    }
    else{
        oneTexel = 1.0 / InSize;

        texCoord = Position.xy / OutSize;
    }*/

}
