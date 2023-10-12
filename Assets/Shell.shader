Shader "Custom/Water" {
	SubShader {
		Tags {
			"LightMode" = "ForwardBase"
		}

		Pass {
            Cull Off

			CGPROGRAM

			#pragma vertex vp
			#pragma fragment fp

			#include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"

			struct VertexData {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

            int _ShellIndex, _ShellCount;
			float _ShellLength, _Density, _NoiseBias, _Thickness, _Attenuation;
			float3 _ShellColor, _Direction;

			float hash(uint n) {
				// integer hash copied from Hugo Elias
				n = (n << 13U) ^ n;
				n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
				return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
			}

			v2f vp(VertexData v) {
				v2f i;

				float shellIndex = (float)_ShellIndex / (float)_ShellCount;

				float length = _ShellLength;
				v.vertex.xyz += v.normal.xyz * length * shellIndex;

                i.normal = normalize(UnityObjectToWorldNormal(v.normal));

				float3 G = (_Direction);
				float k = pow(shellIndex, 5.0f);

				v.vertex.xyz += G * k * 0.1f;

                i.worldPos = mul(unity_ObjectToWorld, v.vertex);
                i.pos = UnityObjectToClipPos(v.vertex);
                i.uv = v.uv;

				return i;
			}


			float4 fp(v2f i) : SV_TARGET {
				float density = _Density;
				float2 newUV = i.uv * density;
				float2 localUV = frac(newUV) * 2 - 1;
				
				float localDistanceFromCenter = length(localUV);
				float2 dirFromCenter = localUV;
				float3 normal = normalize(float3(dirFromCenter.x, 1.0f, dirFromCenter.y));

                uint2 tid = newUV;
				uint seed = tid.x + 100 * tid.y + 100 * 10;
                float shellIndex = _ShellIndex;
                float shellCount = _ShellCount;

				float noiseBias = _NoiseBias;
                float rand = saturate(hash(seed) + noiseBias);
                float h = shellIndex / shellCount;

				float thickness = _Thickness;
				int insideThickness = (localDistanceFromCenter) < (thickness * (rand - h));

                clip(insideThickness - 1 * saturate(_ShellIndex - 1));
                
				float3 color = _ShellColor;
				float ndotl = dot(normal, _WorldSpaceLightPos0) * 0.5f + 0.5f;
				ndotl = ndotl * ndotl;
				//color = _Direction;

				//return dot(i.normal, normalize(_Direction));

                return float4(color * pow(h, _Attenuation) * ndotl, 1.0);
			}

			ENDCG
		}
	}
}