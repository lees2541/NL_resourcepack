#version 150


// mix의 세번째 인자를 0.5로 츄라이
uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D ControlSampler;
uniform sampler2D ControlSamplerf;
uniform sampler2D DebuffSampler;
uniform sampler2D BuffSampler;

uniform vec4 ColorModulate;

uniform mat4 ProjMat;
uniform vec2 InSize;
uniform vec2 OutSize;
uniform vec2 ScreenSize;
uniform float _FOV;
uniform float BuffIcons;
uniform float DebuffIcons;

in vec2 texCoord;
out vec4 fragColor;

float near = 0.1; 
float far  = 1000.0;
float LinearizeDepth(float depth) // depth를 선형적으로 수치화해서 반환 (거리 수치화)
{
    float z = depth * 2.0 - 1.0;
    return (near * far) / (far + near - z * (far - near));    
}

// Debuff Variables
const float exposure = 2.8; //커질수록 더 밝아진다 기존: 2 , 손전등 켠 상태
const float AOE = 12.; // 커질수록 원의 크기가 작아진다 기존:8, 
const float exposuref = 0.7; //커질수록 더 밝아진다 기존: 2
const float AOEF = 2.;// 커질수록 원의 크기가 작아진다 기존:8

void main() {
    vec4 prev_color  = texture(DiffuseSampler, texCoord);
    vec4 overlay;
    vec4 overlay2;
    //vec4 overlay3;
	fragColor = prev_color;

    // Channel #1 ,   손전등
    vec4 control_color = texelFetch(ControlSampler, ivec2(0, 1), 0); // control buffer의 ivec2(0,1) 위치로 저장된 값 가져오기, 
    float depth;
    float distance;
    vec2 uv;
    float d;
    switch(int(control_color.b * 255.)) {
        case 1:
            depth = LinearizeDepth(texture(DiffuseDepthSampler, texCoord).r);
            distance = length(vec3(1., (2.*texCoord - 1.) * vec2(OutSize.x/OutSize.y,1.) * tan(radians(_FOV / 2.))) * depth);

            uv = texCoord;
            d = sqrt(pow((uv.x - 0.5),2.0) + pow((uv.y - 0.5),2.0));// 원 방정식 (화면 중심으로부터 타원만들기)
            d = exp(-(d * AOE)) * exposure / (distance*0.15);
            fragColor = vec4(fragColor.rgb*clamp(1.0 + d,0.1,10.0),1.0);
            break;
        case 2:
            depth = LinearizeDepth(texture(DiffuseDepthSampler, texCoord).r);
            distance = length(vec3(1., (2.*texCoord - 1.) * vec2(OutSize.x/OutSize.y,1.) * tan(radians(_FOV / 2.))) * depth);

            uv = texCoord;
            d = sqrt(pow((uv.x - 0.5),2.0) + pow((uv.y - 0.5),2.0));// 원 방정식 (화면 중심으로부터 타원만들기)
            d = exp(-(d * AOEF)) * exposuref / (distance*0.15);
            fragColor = vec4(fragColor.rgb*clamp(1.0 + d,0.1,10.0),1.0);
            break;
        /*case 1:
            float depth = LinearizeDepth(texture(DiffuseDepthSampler, texCoord).r);
            float distance = length(vec3(1., (2.*texCoord - 1.) * vec2(OutSize.x/OutSize.y,1.) * tan(radians(_FOV / 2.))) * depth);

            vec2 uv = texCoord;
            float d = sqrt(pow((uv.x - 0.5),2.0) + pow((uv.y - 0.5),2.0));// 원 방정식 (화면 중심으로부터 타원만들기)
            d = exp(-(d * AOE)) * exposure / (distance*0.15);
            fragColor = vec4(fragColor.rgb*clamp(1.0 + d,0.1,10.0),1.0);
            break;
        case 2:
            float depth = LinearizeDepth(texture(DiffuseDepthSampler, texCoord).r);
            float distance = length(vec3(1., (2.*texCoord - 1.) * vec2(OutSize.x/OutSize.y,1.) * tan(radians(_FOV / 2.))) * depth);

            vec2 uv = texCoord;
            float d = sqrt(pow((uv.x - 0.5),2.0) + pow((uv.y - 0.5),2.0));// 원 방정식 (화면 중심으로부터 타원만들기)
            d = exp(-(d * AOE)) * exposure / (distance*0.15);
            fragColor = vec4(fragColor.rgb*clamp(1.0 + d,0.1,10.0),1.0);
            break;*/
    }

    // Channel #2
    float debuff = 0.0;

    control_color = texelFetch(ControlSampler, ivec2(0, 2), 0); //control buffer의 ivec2(0,2)위치로 저장된 값 가져오기
    if (int(control_color.g * 255.) == 252){ // entity effect의 g 값을 판별 
        switch(int(control_color.b * 255.)) { // entity effect의 b 값에 따라 나타낼 이미지 좌표가 달라진다
            case 0:
                debuff = 0.0;
                overlay = texture(DebuffSampler, vec2(texCoord.x, debuff/DebuffIcons + (1.0-texCoord.y)/DebuffIcons ));
                if(overlay.a > 0.0) {
                    fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb;       
                }
                break;
            case 1:
                debuff = 1.0;
                overlay = texture(DebuffSampler, vec2(texCoord.x, debuff/DebuffIcons + (1.0-texCoord.y)/DebuffIcons ));
                if(overlay.a > 0.0) {
                    fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb;       
                }
                break;
            case 2:
                debuff = 2.0;
                overlay = texture(DebuffSampler, vec2(texCoord.x, debuff/DebuffIcons + (1.0-texCoord.y)/DebuffIcons ));
                if(overlay.a > 0.0) {
                    fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb;       
                }
                break;
            case 3:
                debuff = 3.0;
                overlay = texture(DebuffSampler, vec2(texCoord.x, debuff/DebuffIcons + (1.0-texCoord.y)/DebuffIcons));
                if(overlay.a > 0.0) {
                    fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb;       
                }
                break;
            case 4:
                debuff = 4.0;
                overlay = texture(DebuffSampler, vec2(texCoord.x, debuff/DebuffIcons + (1.0-texCoord.y)/DebuffIcons));
                if(overlay.a > 0.0) {
                    fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb;       
                }
                break;
            case 255:
                break;
            } 
    }
    
	/*if(overlay.a > 0.0) {
        //overlay3 = mix(overlay.rgb, overlay2.rgb, overlay.a).rgb;
        fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb;
        //fragColor.rgb = mix(fragColor.rgb, overlay2.rgb,overlay.a).rgb;
    }*/
	float buff = 0.0;
	
	//Channel #3 for test SUSU
    control_color = texelFetch(ControlSamplerf, ivec2(0, 4), 0);// 새로운 버퍼 ControlSamplerf를 만든이유는 다음에 실행할때까지 저장되는 ControlSampler 버퍼에 덮어씌우지 않게 함으로서 따로 기능하게 만들기 위함
    if(int(control_color.g * 255.) == 250 ) {
        buff = int(control_color.b * 255.);
        if (0 <= buff && buff < 30 ){
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
        }
        /*switch(int(control_color.b * 255.)) {
        case 0:
            buff = 0.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 1:
            buff = 1.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 2:
            buff = 2.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 3:
            buff = 3.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 4:
            buff = 4.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 5:
            buff = 5.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 6:
            buff = 6.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 7:
            buff = 7.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 8:
            buff = 8.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 9:
            buff = 9.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 10:
            buff = 10.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 11:
            buff = 11.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 12:
            buff = 12.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 13:
            buff = 13.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 14:
            buff = 14.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 15:
            buff = 15.0;
            overlay = texture(BuffSampler, vec2(texCoord.x, buff/BuffIcons+(1.0-texCoord.y)/BuffIcons )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
            if(overlay.a > 0.0) {       
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; //        
            }
            break;
        case 255:
            break;
        }*/
        /*overlay = texture(BuffSampler, vec2(texCoord.x+0.6, buff/5.0+(1.0-texCoord.y)/5.0 )); // 위의 왼쪽 위 배터리 이미지에다 다른 배터리 이미지를 덧씌운다
        if(overlay.a > 0.0) {
        //overlay3 = mix(overlay.rgb, overlay2.rgb, overlay.a).rgb;
        fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb; // 
        //fragColor.rgb = mix(fragColor.rgb, overlay2.rgb,overlay.a).rgb;
        }*/
    }/*else{
        overlay = texture(BuffSampler, vec2(texCoord.x+0.5, buff/5.0+(1.0-texCoord.y)/5.0 ));
        if(overlay.a > 0.0) {
        //overlay3 = mix(overlay.rgb, overlay2.rgb, overlay.a).rgb;
        fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb;
        //fragColor.rgb = mix(fragColor.rgb, overlay2.rgb,overlay.a).rgb;
        }
    }*/
    /*else{
        buff = 2.0;
        overlay = texture(BuffSampler, vec2(texCoord.x, buff/5.0+(1.0-texCoord.y)/5.0 ));
    }*/
    
	

    // Overlay Coordinates Based on Battery Level
    //overlay = texture(DebuffSampler, vec2(texCoord.x, battery/5.0+(1.0-texCoord.y)/5.0 ));
    //overlay = texture(BuffSampler, vec2(texCoord.x, buff/5.0+(1.0-texCoord.y)/5.0 ));

    // Overlay the Overlay on top of other pixels, by default overlay has nothing.
    // Import an overlay sampler to set it.
    /*if(overlay.a > 0.0) {
        //overlay3 = mix(overlay.rgb, overlay2.rgb, overlay.a).rgb;
        fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb;
        //fragColor.rgb = mix(fragColor.rgb, overlay2.rgb,overlay.a).rgb;
    }*/
}
