#version 150

uniform sampler2D InSampler;
uniform sampler2D ParticlesSampler;

//uniform float GameTime;

in vec2 texCoord;

out vec4 fragColor;

void readMarker(inout vec4 fragColor, vec4 lastValue, ivec2 markerPos, vec2 markerColor, int row) {
    if (int(gl_FragCoord.x) == 0) {
        vec4 marker = texelFetch(ParticlesSampler, markerPos, 0);
        if (marker.rg * 255. == markerColor) {
            fragColor = marker;
        }
    } else {
        vec4 target = texelFetch(InSampler, ivec2(0, row), 0);
        fragColor = lastValue + sign(target - lastValue)/255.;
    }
}

void main() {
    vec4 lastValue = texture(InSampler, texCoord);
    fragColor = lastValue;
    switch (int(gl_FragCoord.y)) {
        case 4:
            // Row 1: 
            readMarker(fragColor, lastValue, ivec2(0, 6), vec2(254., 248.), 4);
            break;
    }
        
}