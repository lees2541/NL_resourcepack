#version 150

#define MINECRAFT_LIGHT_POWER   (0.6) // 기본: 0.6
#define MINECRAFT_AMBIENT_LIGHT (0.4) // 기본 0.4

vec4 minecraft_mix_light(vec3 lightDir0, vec3 lightDir1, vec3 normal, vec4 color) {
    lightDir0 = normalize(lightDir0);
    lightDir1 = normalize(lightDir1);
    float light0 = max(0.0, dot(lightDir0, normal));
    float light1 = max(0.0, dot(lightDir1, normal));
    float lightAccum = min(1.0, (light0 + light1) * MINECRAFT_LIGHT_POWER + MINECRAFT_AMBIENT_LIGHT);
    return vec4(color.rgb * lightAccum, color.a);// 여기에 뭘 곱하냐에 따라 이 함수를 이용하는 쉐이더의 대상의 밝기가 달라짐
}

vec4 minecraft_sample_lightmap(sampler2D lightMap, ivec2 uv) {
    return texture(lightMap, clamp(uv / 256.0, vec2(3.0 / 16.0), vec2(15.5 / 16.0)));// vec2 안의 숫자를 조정해서 블럭의 최소밝기, 최대밝기를 수정 가능 기본 최솟값: 0.5
}
