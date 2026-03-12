#version 330

uniform sampler2D MainSampler;
uniform sampler2D ControlSampler;

in vec2 texCoord;
in vec2 oneTexel;

out vec4 fragColor;

void main() {
    vec4 controlColor = texelFetch(ControlSampler, ivec2(0, 1), 0);

    if (int(controlColor.r * 255.0) == 254 &&
        int(controlColor.g * 255.0) == 253 &&
        int(controlColor.b * 255.0) == 4) {

        vec4 center = texture(MainSampler, texCoord);
        vec4 left   = texture(MainSampler, texCoord - vec2(oneTexel.x, 0.0));
        vec4 right  = texture(MainSampler, texCoord + vec2(oneTexel.x, 0.0));
        vec4 up     = texture(MainSampler, texCoord - vec2(0.0, oneTexel.y));
        vec4 down   = texture(MainSampler, texCoord + vec2(0.0, oneTexel.y));

        vec4 total = clamp(
            (center - left) +
            (center - right) +
            (center - up) +
            (center - down),
            0.0,
            1.0
        );

        fragColor = vec4(total.rgb, 1.0);
    } else {
        fragColor = texture(MainSampler, texCoord);
    }
}
