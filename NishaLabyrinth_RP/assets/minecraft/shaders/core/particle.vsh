#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec2 UV0;
in vec4 Color;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;


out float vertexDistance;
out vec2 texCoord0;
out vec4 vertexColor;
out vec4 lightColor;
out vec4 maxLightColor;
flat out float isMarker;
flat out vec4 tint;

vec2[] corners = vec2[](
    vec2(0, 1),
    vec2(0, 0),
    vec2(1, 0),
    vec2(1, 1)
);


const float minGreen = 246.0;  //252.0 -> 248.0 으로 바꿈 
const float maxGreen = 253.0;

void main() {
    tint = Color;
    // 마커 칼라 조건, 이 조건을 만족해야 마커인 것을 인식한다
    if (abs(Color.r * 255. - 254.) < .5 && Color.g * 255. > minGreen - .5 && Color.g * 255. < maxGreen + .5) {
        // When marker color
        isMarker = 1.0;
        vec2 screenPos = 0.125 * corners[gl_VertexID % 4] - 1.0;
        gl_Position = vec4(screenPos, 0.0, 1.0);
        vertexDistance = 0.0;
        texCoord0 = vec2(0);
        vertexColor = vec4(0);
    } else {
        isMarker = 0.0;
        /*if(Color.r * 255. == 11. && Color.g * 255. == 97. && Color.b * 255. == 56.){
            isMarker = 2.0;
        }else if(Color.r * 255. == 29. && Color.g * 255. == 194. && Color.b * 255. == 209.){
            isMarker = 2.0;
        }else if(Color.r * 255. == 228. && Color.g * 255. == 154. && Color.b * 255. == 58.){
            isMarker = 2.0;
        }*/
        // Vanilla code + emissive stuff
        gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

        vertexDistance = fog_distance(Position, FogShape);
        texCoord0 = UV0;
        vertexColor = Color;
        lightColor = minecraft_sample_lightmap(Sampler2, UV2);
        maxLightColor = minecraft_sample_lightmap(Sampler2, ivec2(240.0, 240.0));
    }
}
