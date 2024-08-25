#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D ParticlesSampler;

uniform float GameTime;

in vec2 texCoord;

out vec4 fragColor;  //controller buffer에 저장 (transparency.json 참고)

// 인자로 받아온 값의 정보가 실제 값(ParticlesSampler에서 가져온) 것과 매치되는 지 확인, 맞으면 특정 입력을 받았다고 가정한다
// 값이 다르면 lastvalue에 임시저장된 값으로 복원한다.
void readMarker(inout vec4 fragColor, vec4 lastValue, ivec2 markerPos, vec2 markerColor, int row) {
    if (int(gl_FragCoord.x) == 0) {
        vec4 marker = texelFetch(ParticlesSampler, markerPos, 0);
        if (marker.rg * 255. == markerColor) {
            fragColor = marker;
        }
    } else {
        vec4 target = texelFetch(DiffuseSampler, ivec2(0, row), 0);
        fragColor = lastValue + sign(target - lastValue)/255.;
    }
}

void main() {
    vec4 lastValue = texture(DiffuseSampler, texCoord);
    fragColor = lastValue;
    switch (int(gl_FragCoord.y)) {
        case 0:
            // Row 0: GameTime,    첫 쉐이더 작동 후의 시간의 흐름을 인식하게 해준다. 이걸로 애니메이션 연출 이론상 가능
            float time1 = lastValue.y + (floor(lastValue.x*255.) > ceil(GameTime*255.) ? 1./255. : 0.0);

            float time2 = lastValue.z + floor(time1)/255.;

            fragColor = vec4(GameTime, fract(time1), fract(time2), 1);
            break;
        case 1:
            // Row 1: 
            readMarker(fragColor, lastValue, ivec2(0, 0), vec2(254., 253.), 1); // 손전등 온을 위한 마커
            break;
        case 2:
            readMarker(fragColor, lastValue, ivec2(0, 2), vec2(254., 252.), 2); // 왼쪽위 배터리를 위한 마커
            break;
            /*vec4 markerf = texelFetch(ParticlesSampler, ivec2(0,2),0);
            // Row 2:
            if (markerf.rg * 255 == vec2(254.,250.)){
                readMarker(fragColor, lastValue, ivec2(0, 2), vec2(254., 250.), 2);
            }else{
                readMarker(fragColor, lastValue, ivec2(0, 2), vec2(254., 252.), 2);
            }
            break;*/
		// 테스트용
		/*case 3:
			readMarker(fragColor, lastValue, ivec2(0, 4), vec2(254., 250.), 4);
			break;*/
    }
}