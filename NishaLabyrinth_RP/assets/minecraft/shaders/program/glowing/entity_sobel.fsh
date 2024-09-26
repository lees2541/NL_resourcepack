#version 150

uniform sampler2D InSampler;
uniform sampler2D DataSampler;


in vec2 texCoord;
in vec2 oneTexel;

out vec4 fragColor;

void main(){
    vec4 center = texture(InSampler, texCoord);
    vec4 left = texture(InSampler, texCoord - vec2(oneTexel.x, 0.0));
    vec4 right = texture(InSampler, texCoord + vec2(oneTexel.x, 0.0));
    vec4 up = texture(InSampler, texCoord - vec2(0.0, oneTexel.y));
    vec4 down = texture(InSampler, texCoord + vec2(0.0, oneTexel.y));
    float leftDiff  = abs(center.a - left.a);
    float rightDiff = abs(center.a - right.a);
    float upDiff    = abs(center.a - up.a);
    float downDiff  = abs(center.a - down.a);
    float total = clamp(leftDiff + rightDiff + upDiff + downDiff, 0.0, 1.0);
    vec3 outColor = center.rgb * center.a + left.rgb * left.a + right.rgb * right.a + up.rgb * up.a + down.rgb * down.a;
    fragColor = vec4(outColor * 0.2, total);



    /*vec3 InData = texture(DataSampler, vec2(1.0, 1.0)).rgb;
    
    if (InData == vec3(1.0, 1.0, 1.0)){//white
        
        fragColor = vec4(0.4,0.0,0.0 , total);
       
    }*/
}
