#version 150


// mix의 세번째 인자를 0.5로 츄라이
uniform sampler2D DiffuseSampler;
uniform sampler2D ControlSamplero;
uniform sampler2D GlowingSampler;

uniform vec4 ColorModulate;

uniform mat4 ProjMat;
uniform vec2 InSize;
uniform vec2 OutSize;
uniform vec2 ScreenSize;
uniform float _FOV;

in vec2 texCoord;
out vec4 fragColor;



void main() {
    vec4 prev_color  = texture(DiffuseSampler, texCoord);
    vec4 overlay3;
    //vec4 overlay3;
	fragColor = prev_color;

    // Channel #1 ,   손전등
    
	//Channel #3 for test SUSU
    vec4 control_coloro = texelFetch(ControlSamplero, ivec2(0, 6), 0);// 
    if(int(control_coloro.g * 255.) > 247 &&  int(control_coloro.g * 255.) < 249) { // 범위로 둔 이유는 손전등 불빛에 의해 미약하게 영향을 받아서 그렇다 기본은 248
        switch(int(control_coloro.b * 255.)) {
        case 0:
            overlay3 = texture(GlowingSampler, vec2(texCoord.x, (1.0-texCoord.y) )); //
            if(overlay3.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay3.rgb, overlay3.a).rgb; //        
            }
            break;
        case 255:
            break;
        }
        
    }
}
