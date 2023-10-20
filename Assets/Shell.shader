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
			float _ShellLength, _Density, _NoiseBias, _Thickness, _Attenuation, _OcclusionBias, _ShellDistanceAttenuation, _Curvature, _DisplacementStrength;
			float3 _ShellColor, _ShellDirection;

			float hash(uint n) {
				// integer hash copied from Hugo Elias
				n = (n << 13U) ^ n;
				n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
				return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
			}

			v2f vp(VertexData v) {
				v2f i;

				float shellIndex = (float)_ShellIndex / (float)_ShellCount;
				shellIndex = pow(shellIndex, _ShellDistanceAttenuation);

				v.vertex.xyz += v.normal.xyz * _ShellLength * shellIndex;

                i.normal = normalize(UnityObjectToWorldNormal(v.normal));
				
				float k = pow(shellIndex, _Curvature);

				v.vertex.xyz += _ShellDirection * k * _DisplacementStrength;

                i.worldPos = mul(unity_ObjectToWorld, v.vertex);
                i.pos = UnityObjectToClipPos(v.vertex);
                i.uv = v.uv;

				return i;
			}


			float4 fp(v2f i) : SV_TARGET {
				float2 newUV = i.uv * _Density;
				float2 localUV = frac(newUV) * 2 - 1;
				
				float localDistanceFromCenter = length(localUV);

                uint2 tid = newUV;
				uint seed = tid.x + 100 * tid.y + 100 * 10;
                float shellIndex = _ShellIndex;
                float shellCount = _ShellCount;

                float rand = saturate(hash(seed) + _NoiseBias);
                float h = shellIndex / shellCount;

				int outsideThickness = (localDistanceFromCenter) > (_Thickness * (rand - h));
				
				if (outsideThickness && _ShellIndex > 0) discard;
                
				float ndotl = DotClamped(i.normal, _WorldSpaceLightPos0) * 0.5f + 0.5f;
				ndotl = ndotl * ndotl;

                return float4(_ShellColor * saturate((pow(h, _Attenuation) + _OcclusionBias)) * ndotl, 1.0);
			}

			ENDCG
		}
	}
}