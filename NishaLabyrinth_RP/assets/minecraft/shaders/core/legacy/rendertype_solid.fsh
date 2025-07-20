#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:emissive_utils.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in float dimension;
in vec4 vertexColor;
in vec4 lightColor;
in vec4 maxLightColor;
in vec2 texCoord0;
in vec3 faceLightingNormal;
in vec4 normal;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
	float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
	color = make_emissive(color, lightColor, maxLightColor, vertexDistance, alpha) / face_lighting_check(faceLightingNormal, alpha, dimension);
	color.a = remap_alpha(alpha) / 255.0;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);

	if(FogColor.rgb==vec3(0.0,0.0,0.0)){// 어둠 상태이상 감지(blindness와 안개 거리로 구별)
		if(FogStart < 3.0){
			fragColor = linear_fog(color, vertexDistance, 2.0, 4.0, vec4(0.0,0.0,0.1,0.99));//안개 범위 및 색깔 설정
			if(vertexDistance > 4.0 && vertexDistance<9.0){// 특수 외곽선 이펙트 범위
				float aa = 4.0*color.a;
				aa -= texture(Sampler0, texCoord0 + vec2(0.0001, 0.0)).a;

				aa -= texture(Sampler0, texCoord0 + vec2(-0.0001, 0.0)).a;

				aa -= texture(Sampler0, texCoord0 + vec2(0.0, 0.0001)).a;

				aa -= texture(Sampler0, texCoord0 + vec2(0.0, -0.0001)).a;

				vec4 col;

				if(abs(aa) < 0.1){
					col = linear_fog(color, vertexDistance, 2.0, 4.0, vec4(0.0,0.0,0.1,0.99));
				}else{
					col = vec4(0.695, 0.273, 0.83, 0.5);
				}

				fragColor = col;
			}
		}else{
			fragColor = linear_fog(color, vertexDistance, 3.3, 5.0, vec4(0.0,0.0,0.1,0.99));
			
		}
		
	}
}
