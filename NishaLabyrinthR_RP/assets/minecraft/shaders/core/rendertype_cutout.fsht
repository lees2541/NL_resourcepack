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
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, 2.0, 4.5, vec4(0.0,0.0,0.1,0.2));//수풀 및 투명성질있는 블럭들의 거리에 따른 밝기 및 색 적용
    if(FogColor.rgb==vec3(0.0,0.0,0.0) && FogStart >=3.0){
        fragColor = linear_fog(color, vertexDistance, 5.5, 7.5, vec4(0.0,0.0,0.1,0.5));
    }
}
