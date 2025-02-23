#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D FinalSampler;
uniform sampler2D DataSampler;
uniform sampler2D PrevSampler;
uniform sampler2D ControlSampler;

in vec2 texCoord; //in -> in
in vec2 oneTexel; // in -> in

//uniform float GameTime;
uniform vec2 InSize;

uniform vec2 Frequency;
uniform vec2 WobbleAmount;
uniform vec3 Phosphor;

out vec4 fragColor;

// GLOWING SHADER
void glowing(float rIn, float gIn, float bIn){
    vec4 center = texture(FinalSampler, texCoord);
    vec4 left = texture(FinalSampler, texCoord - vec2(oneTexel.x, 0.0));
    vec4 right = texture(FinalSampler, texCoord + vec2(oneTexel.x, 0.0));
    vec4 up = texture(FinalSampler, texCoord - vec2(0.0, oneTexel.y));
    vec4 down = texture(FinalSampler, texCoord + vec2(0.0, oneTexel.y));
    float leftDiff  = abs(center.a - left.a);
    float rightDiff = abs(center.a - right.a);
    float upDiff    = abs(center.a - up.a);
    float downDiff  = abs(center.a - down.a);
    float total = clamp(leftDiff + rightDiff + upDiff + downDiff, 0.0, 1.0);
    vec3 outColor = center.rgb * center.a + left.rgb * left.a + right.rgb * right.a + up.rgb * up.a + down.rgb * down.a;
    fragColor = vec4(rIn, gIn, bIn, total);//fragColor -> fragColor
}

// Player Blur
void pblur() {
	vec2 BlurDir = vec2(2.0, 2.0);
	float Radius = 5.0;
	vec4 blurred = vec4(0.0);
	float totalStrength = 0.0;
	float totalAlpha = 0.0;
	float totalSamples = 0.0;
	float count = 0.0;
	for(float r = -Radius; r <= Radius; r += 1.0) {
		vec4 FinalTexel = texture(FinalSampler, texCoord + oneTexel * r * BlurDir);
		if(FinalTexel.r > 0.1 || FinalTexel.g > 0.1 || FinalTexel.b > 0.1) {
			vec4 sampleValue = texture(DiffuseSampler, texCoord + oneTexel * r * BlurDir);
			// Accumulate average alpha
			totalAlpha = totalAlpha + sampleValue.a;
			totalSamples = totalSamples + 1.0;

			// Accumulate smoothed blur
			float strength = 1.0 - abs(r / Radius);
			totalStrength = totalStrength + strength;
			blurred = blurred + sampleValue;
			
			count = count + 1.0;
		}
	}
	if(count > 0.0) {
		fragColor = vec4(blurred.rgb / count, 0.5);//fragColor -> fragColor
	} else {
		fragColor = vec4(1.0, 1.0, 1.0, 0.0);//fragColor -> fragColor
	}
}


void wobble() {
	vec4 PrevTexel = texture(PrevSampler, texCoord);

    float xOffset = sin(texCoord.y * Frequency.x + 3.1415926535 * 2.0 * PrevTexel.g) * WobbleAmount.x;
    float yOffset = cos(texCoord.x * Frequency.y + 3.1415926535 * 2.0 * PrevTexel.b) * WobbleAmount.y;
    vec2 offset = vec2(xOffset, yOffset);
    vec4 center = texture(FinalSampler, texCoord + offset);
    vec4 left = texture(FinalSampler, texCoord - vec2(oneTexel.x, 0.0) + offset);
    vec4 right = texture(FinalSampler, texCoord + vec2(oneTexel.x, 0.0) + offset);
    vec4 up = texture(FinalSampler, texCoord - vec2(0.0, oneTexel.y) + offset);
    vec4 down = texture(FinalSampler, texCoord + vec2(0.0, oneTexel.y) + offset);
    float total = clamp(left.a + right.a + up.a + down.a, 0.0, 1.0);
    vec3 outColor = center.rgb * center.a + left.rgb * left.a + right.rgb * right.a + up.rgb * up.a + down.rgb * down.a;
    fragColor = vec4(max(outColor * 0.2, vec3(0.8,0.8,0.8)), total);//fragColor -> fragColor
}


/*
// Main Function
*/
void main() {
    
    vec4 InTexel = texture(DiffuseSampler, texCoord);
    vec3 InData = texture(DataSampler, vec2(1.0, 1.0)).rgb;
    vec4 control_color = texelFetch(ControlSampler, ivec2(0, 1), 0);
    if(InTexel == InTexel) {

		//  Detect Color
        if (InData == vec3(0.33333333, 1.0, 1.0)) { 
			// Aqua
            pblur();
        } else if (InData == vec3(0.33333333, 0.33333333, 1.0)) { 
			// Blue
            glowing(0.33, 0.33, 1.0);
        } else if (InData == vec3(0.0, 0.66666666, 0.66666666)) { 
			// Dark Aqua
            wobble();
        } else if (InData == vec3(0.0, 0.0, 0.66666666)) { 
			// Dark Blue
			glowing(0.0, 0.0, 0.66);
        } else if (InData == vec3(0.33333333, 0.33333333, 0.33333333)) { 
			// Dark Gray
            glowing(0.33, 0.33, 0.33);
        } else if (InData == vec3(0.0, 0.66666666, 0.0)) { 
			// Dark Green
            glowing(0.0, 0.66, 0.0);
        } else if (InData == vec3(0.66666666, 0.0, 0.66666666)) { 
			// Dark Purple
            glowing(0.66, 0.0, 0.66);
        } else if (InData == vec3(0.66666666, 0.0, 0.0)) { 
			// Dark Red
            glowing(0.66, 0.0, 0.0);
        } else if (InData == vec3(1.0, 0.66666666, 0.0)) {
			// Gold
            glowing(1.0, 0.66, 0.0);
        } else if (InData == vec3(0.66666666, 0.66666666, 0.66666666)) { 
			//Gray
           glowing(0.66, 0.66, 0.66);
        } else if (InData == vec3(0.33333333, 1.0, 0.33333333)) { 
			// Green
            glowing(0.33, 1.0, 0.33);
        } else if (InData == vec3(1.0, 0.33333333, 1.0)) { 
			// Light Purple
			 glowing(1.0, 0.33, 1.0);
        } else if (InData == vec3(1.0, 0.33333333, 0.33333333)) { 
			// Red
			glowing(1.0, 0.33, 0.33);
        } else if (InData == vec3(1.0, 1.0, 1.0)) { 
			// White
           glowing(1.0, 1.0, 1.0);
        } else if (InData == vec3(1.0, 1.0, 0.33333333)) { 
		   // Yellow
            glowing(1.0, 1.0, 0.33);
        } else { 
			// No Color (Black) - UNUSED
            fragColor = vec4(0.0, 0.0, 0.0, 0.0); //fragColor -> fragColor
        }

    }
    
}