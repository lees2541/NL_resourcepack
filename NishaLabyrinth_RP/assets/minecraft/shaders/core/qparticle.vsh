#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec2 UV0;
in vec4 Color;
in ivec2 UV2;

uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec2 texCoord0;
out vec4 vertexColor;
flat out float isMarker; // 마커 판별
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
        sphericalVertexDistance = 0;
        cylindricalVertexDistance = 0;
        texCoord0 = vec2(0);
        vertexColor = vec4(0);
    } else {
        isMarker = 0.0;

        gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

        sphericalVertexDistance = fog_spherical_distance(Position);
        cylindricalVertexDistance = fog_cylindrical_distance(Position);
        texCoord0 = UV0;
        vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    }
}
