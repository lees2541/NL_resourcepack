#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:emissive_utils.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightColor;
in vec4 maxLightColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec4 normal;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    color *= vertexColor * ColorModulator;
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
	float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
    color = make_emissive(color, lightColor, maxLightColor, vertexDistance, alpha);
	color.a = remap_alpha(alpha) / 255.0;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, 3.0, 6.0, vec4(0.0,0.0,0.0,0.3));//안개거리에 따른 엔티티의 밝기 변화
    if(FogColor.rgb==vec3(0.0,0.0,0.0) && FogStart >=3.0){
        fragColor = linear_fog(color, vertexDistance, 10.0, 12.5, vec4(0.0,0.0,0.1,0.3));
    }
}
