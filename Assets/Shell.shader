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
			float _ShellLength, _Density, _NoiseBias, _Thickness, _Attenuation, _ShellDistanceAttenuation, _DirectionalVariance, _Curvature, _DisplacementStrength;
			float3 _ShellColor, _Direction;

			float hash(uint n) {
				// integer hash copied from Hugo Elias
				n = (n << 13U) ^ n;
				n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
				return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
			}

			v2f vp(VertexData v) {
				v2f i;

				float2 newUV = v.uv * _Density;
				uint2 tid = newUV;
				uint seed = tid.x + 2000 * tid.y + 2000 * 10;
				float3 rand = float3(hash(seed), hash(seed + 12312), hash(seed + 2321124)) * 2 - 1;
				rand *= _DirectionalVariance;

				float shellIndex = (float)_ShellIndex / (float)_ShellCount;
				shellIndex = pow(shellIndex, _ShellDistanceAttenuation);

				float length = _ShellLength;
				v.vertex.xyz += normalize(v.normal.xyz + rand) * length * shellIndex;

                i.normal = normalize(UnityObjectToWorldNormal(v.normal));
				
				float k = pow(shellIndex, _Curvature);

				v.vertex.xyz += _Direction * k * _DisplacementStrength;

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
				float ndotl = DotClamped(i.normal, _WorldSpaceLightPos0) * 0.5f + 0.5f;
				ndotl = ndotl * ndotl;

                return float4(color * pow(h, _Attenuation) * ndotl, 1.0);
			}

			ENDCG
		}
	}
}