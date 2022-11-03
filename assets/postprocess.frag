#version 140

uniform sampler2D tex;

varying vec2 vertex;
varying vec4 color;
varying vec2 texCoord;

uniform float time;
uniform vec2 resolution;

void main(void) {
  gl_FragColor = texture(tex, texCoord);
  gl_FragColor.rg *= 0.5;
}
