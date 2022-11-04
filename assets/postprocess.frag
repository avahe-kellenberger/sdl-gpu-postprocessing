#version 140

uniform sampler2D tex;

varying vec2 vertex;
varying vec4 color;
varying vec2 texCoord;

uniform float time;
uniform vec2 resolution;

const float PI = 3.14159;

vec2 movingTiles(vec2 st, float zoom, float speed) {
  st *= zoom;
  float time = time * speed;
  if (fract(time) > 0.5) {
      if (fract(st.y * 0.5) > 0.5) {
        st.x += fract(time) * 2.0;
      } else {
        st.x -= fract(time) * 2.0;
      }
  } else {
    if (fract(st.x * 0.5) > 0.5) {
      st.y += fract(time) * 2.0;
    } else {
      st.y -= fract(time) * 2.0;
    }
  }
  return fract(st);
}

float circle(vec2 st, float radius){
  vec2 pos = vec2(0.5) - st;
  return smoothstep(1.0 - radius, 1.0 - radius + radius * 0.2, 1.0 - dot(pos, pos) * PI);
}

void main() {
  vec2 st = gl_FragCoord.xy / resolution.xy;
  st.x *= resolution.x / resolution.y;
  st = movingTiles(st, 10.0, 0.5);

  vec3 color = vec3(1.0 - circle(st, 0.3));
  gl_FragColor = texture(tex, texCoord);
  gl_FragColor.rgb = mix(gl_FragColor.rgb, color, 0.5);
}

