#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D ControlSampler;
uniform vec4 ColorModulate;

in vec2 texCoord;
in vec2 oneTexel;

out vec4 fragColor;

void main(){
    //fragColor = texture(DiffuseSampler, texCoord) * ColorModulate;
    vec4 control_color = texelFetch(ControlSampler, ivec2(0, 1), 0); 


    if(int(control_color.r * 255.)==254 && int(control_color.g * 255.)==253 && int(control_color.b * 255.) == 4){
        vec4 center = texture(DiffuseSampler, texCoord);
        vec4 left   = texture(DiffuseSampler, texCoord - vec2(oneTexel.x, 0.0));
        vec4 right  = texture(DiffuseSampler, texCoord + vec2(oneTexel.x, 0.0));
        vec4 up     = texture(DiffuseSampler, texCoord - vec2(0.0, oneTexel.y));
        vec4 down   = texture(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y));
        vec4 leftDiff  = center - left;
        vec4 rightDiff = center - right;
        vec4 upDiff    = center - up;
        vec4 downDiff  = center - down;
        vec4 total = clamp(leftDiff + rightDiff + upDiff + downDiff, 0.0, 1.0);
        fragColor = vec4(total.rgb, 1.0);
    }else{
        fragColor = texture(DiffuseSampler, texCoord);
    }
}