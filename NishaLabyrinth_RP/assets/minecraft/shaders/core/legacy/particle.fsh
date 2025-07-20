#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:emissive_utils.glsl>

uniform sampler2D Sampler0;
//uniform sampler2D Sampler2;  //추가

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec2 texCoord0;
in vec4 vertexColor;
in vec4 lightColor;
in vec4 maxLightColor;
flat in float isMarker;
flat in vec4 tint;

out vec4 fragColor;

void main() {
    if (isMarker == 1.0) {
        fragColor = vec4(254./255., tint.gb, 1);
        ivec2 iCoord = ivec2(gl_FragCoord.xy);
        // 여러겹의 오버레이 할 때 주의
        if (
            (((iCoord.x + iCoord.y) & 1) == 1)
            || (abs(tint.g * 255. - 253.) < .5 && iCoord != ivec2(0, 0))//손전등
            || (abs(tint.g * 255. - 252.) < .5 && iCoord != ivec2(0, 2))// 디버프 ui
            || (abs(tint.g * 255. - 250.) < .5 && iCoord != ivec2(0, 4)) // 버프 ui
            || (abs(tint.g * 255. - 248.) < .5 && iCoord != ivec2(0, 6)) // 발광상태ui
        )
            discard;
    }
    else {
        // Vanilla calculation + emissive stuff
        vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
        float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
        //color = make_emissive(color, lightColor, maxLightColor, vertexDistance, alpha);
        //color.a = remap_alpha(alpha) / 255.0;
        if (color.a < 0.1) {
            discard;
        }
        fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
    }
}
