#version 150

uniform sampler2D DiffuseSampler;

in vec2 texCoord; //in -> in
in vec2 oneTexel; //in -> in

uniform vec2 InSize;

out vec4 fragColor;

void main() {

    vec4 InTexel = texture(DiffuseSampler, texCoord);
    fragColor = InTexel;
    
}