#version 150

#moj_import <fog.glsl>

#define tau 6.283185307179586

uniform sampler2D Sampler0;
uniform sampler2D DiffuseSampler;
uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform float GameTime;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 UV0;
in ivec2 UV2;
in vec4 normal;
in vec3 Position;

out vec4 fragColor;

float rand( vec2 co ){
    return fract(sin(dot( co, vec2( 12.9898, 78.233 ) )) * 43758.5453);
}

vec4 getColor( int effect ){
    float time = mod( GameTime*100.0, tau );

    vec2 noise_position = texCoord0;

    // Noise Lines
    float noise = rand(vec2( rand(vec2( time, noise_position.y/1024 )) ));
    vec3 col = (vec3 ( noise * 0.8 ) + 1.2) * 0.5;

    // BG Noise
    col *= rand(vec2( rand(vec2( noise_position )), time )) * 0.6 + 0.4;

    // White Bars
    vec3 wbar = vec3( round(mod( ( noise_position.y + 0.05*sin( (3.6*(tau/2) * (time-1.69)) / 7.86 ) - 0.035*cos( (3.6*(tau/2) * (time+0.5708)) / (tau/2) ) + 0.05 ) * 512, 1.0 ) - 0.1) ) * 0.16;

    if ( effect == 2 ){
        // Warp
        col.rb = col.rb*0.2 + vec2(0.8);
    } else if ( effect == 3 ){
        // Underridge
        col.g = col.g*0.9 - 0.2;
        col.rb *= 0.1;
    } else if ( effect == 4 ){
        // Nether
        col.r = col.r*1.2 - 0.2;
        col.gb *= 0.1;
    } else if ( effect == 5 ){
        // Overworld
        col.gb = col.gb*0.3 + vec2(0.5, 0.7);
    } else if ( effect == 6 ){
        // Upper Sky
        col.b = col.b*0.3 + 0.7;
    } else if ( effect == 7 ){
        // End
        col.rb = col.rb*1.2 - vec2(0.2,0.1);
        col.g *= 0.1;
    }

    return vec4( col + wbar, 1.0 );
}

void main(){
    vec4 currentPixel = texture( Sampler0, texCoord0 );
    if ( currentPixel.a < 0.1 ) {
        discard;
    }

    int effect = 0;
    if ( currentPixel.a < 0.185 && currentPixel.a > 0.184 ) {
        if ( currentPixel.r == 1.0 && currentPixel.g < 0.185 && currentPixel.g > 0.184 && currentPixel.b < 0.185 && currentPixel.b > 0.184 ){
            effect = 1;
        } else if ( currentPixel.r == 1.0 && currentPixel.g < 0.185 && currentPixel.g > 0.184 && currentPixel.b < 0.189 && currentPixel.b > 0.188 ){
            effect = 2;
        } else if ( currentPixel.r == 1.0 && currentPixel.g < 0.185 && currentPixel.g > 0.184 && currentPixel.b < 0.193 && currentPixel.b > 0.192 ){
            effect = 3;
        } else if ( currentPixel.r == 1.0 && currentPixel.g < 0.185 && currentPixel.g > 0.184 && currentPixel.b < 0.197 && currentPixel.b > 0.196 ){
            effect = 4;
        } else if ( currentPixel.r == 1.0 && currentPixel.g < 0.185 && currentPixel.g > 0.184 && currentPixel.b < 0.201 && currentPixel.b > 0.198 ){
            effect = 5;
        } else if ( currentPixel.r == 1.0 && currentPixel.g < 0.185 && currentPixel.g > 0.184 && currentPixel.b < 0.204 && currentPixel.b > 0.203 ){
            effect = 6;
        } else if ( currentPixel.r == 1.0 && currentPixel.g < 0.185 && currentPixel.g > 0.184 && currentPixel.b < 0.208 && currentPixel.b > 0.207 ){
            effect = 7;
        }
    }
    
  	if ( effect != 0 ){
        vec4 color = getColor( effect );
        fragColor = linear_fog( color, vertexDistance, FogStart, FogEnd, FogColor );
    } else {
        vec4 color = texture( Sampler0, texCoord0 ) * vertexColor * ColorModulator;
        fragColor = linear_fog( color, vertexDistance, FogStart, FogEnd, FogColor );
    }
}
