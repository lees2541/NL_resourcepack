#version 150


// mix의 세번째 인자를 0.5로 츄라이
uniform sampler2D InSampler;
uniform sampler2D Control3Sampler;
uniform sampler2D GlowingSampler;





in vec2 texCoord;
out vec4 fragColor;



void main() {
    vec4 prev_color  = texture(InSampler, texCoord);
    vec4 overlay3;

	fragColor = prev_color;




    vec4 control_color3 = texelFetch(Control3Sampler, ivec2(0, 4), 0);// 
    if(int(control_color3.g * 255.) >= 247) {

        switch(int(control_color3.b * 255.)) {
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
