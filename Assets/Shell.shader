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

			float hash(uint n) {
				// integer hash copied from Hugo Elias
				n = (n << 13U) ^ n;
				n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
				return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
			}

			v2f vp(VertexData v) {
				v2f i;

				float shellIndex = (float)_ShellIndex / (float)_ShellCount;

				v.vertex.xyz += v.normal.xyz * 0.1f * shellIndex;
				v.vertex.x += (sin(_Time.y * 2) * 0.5f + 0.5f) * 0.01f * shellIndex;

                i.worldPos = mul(unity_ObjectToWorld, v.vertex);
                i.normal = normalize(UnityObjectToWorldNormal(v.normal));
                i.pos = UnityObjectToClipPos(v.vertex);
                i.uv = v.uv;

				return i;
			}


			float4 fp(v2f i) : SV_TARGET {
				uint2 tid = i.uv * 100;
                uint seed = tid.x + 100 * tid.y + 100 * 10;
                float shellIndex = _ShellIndex;
                float shellCount = _ShellCount;

                float rand = hash(seed) + 0.1f;

                float3 pos = float3(i.uv.x, shellIndex / shellCount, i.uv.y);
                //pos = pos * 2 - 1;
                
                clip((pos.y < rand) - 1);
                
                return float4(0.25, 0.75, 0.1, 1.0) * pos.y;
			}

			ENDCG
		}
	}
}