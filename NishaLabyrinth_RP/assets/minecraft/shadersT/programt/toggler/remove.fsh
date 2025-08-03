#version 150

uniform sampler2D InSampler;

in vec2 texCoord;
flat in vec2 oneTexel;

out vec4 fragColor;

void main() {
    vec4 col = texture(InSampler, texCoord);
    bool isMarker = col.rg * 255. == vec2(254., 253.);
    if (isMarker) {
        col = texture(InSampler,texCoord + vec2(0.0, oneTexel.y));
    }
    fragColor = col;
}