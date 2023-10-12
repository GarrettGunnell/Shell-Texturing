Shader "Hidden/FXAA" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader {

        CGINCLUDE

        #include "UnityCG.cginc"

        struct VertexData {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        v2f vp(VertexData v) {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            return o;
        }

        sampler2D _MainTex, _LuminanceTex;
        float4 _MainTex_TexelSize;

        float _ContrastThreshold, _RelativeThreshold, _SubpixelBlending;

        ENDCG

        // Luminance Pass
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            float4 fp(v2f i) : SV_Target {
                return LinearRgbToLuminance(saturate(tex2D(_MainTex, i.uv).rgb));
            }
            ENDCG
        }

        // Luminance Pass
        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            #define EDGE_STEP_COUNT 10
            #define EDGE_STEPS 1, 1.5, 2, 2, 2, 2, 2, 2, 2, 4
            #define EDGE_GUESS 8

            static const float edgeSteps[EDGE_STEP_COUNT] = { EDGE_STEPS };

            float4 fp(v2f i) : SV_Target {
                float4 col = tex2D(_MainTex, i.uv);

                // Luminance Neighborhood
                float m = tex2D(_LuminanceTex, i.uv + float2(0, 0) * _MainTex_TexelSize.xy);
                
                float n = tex2D(_LuminanceTex, i.uv + float2(0, 1) * _MainTex_TexelSize.xy);
                float e = tex2D(_LuminanceTex, i.uv + float2(1, 0) * _MainTex_TexelSize.xy);
                float s = tex2D(_LuminanceTex, i.uv + float2(0, -1) * _MainTex_TexelSize.xy);
                float w = tex2D(_LuminanceTex, i.uv + float2(-1, 0) * _MainTex_TexelSize.xy);
                
                float ne = tex2D(_LuminanceTex, i.uv + float2(1, 1) * _MainTex_TexelSize.xy);
                float nw = tex2D(_LuminanceTex, i.uv + float2(-1, 1) * _MainTex_TexelSize.xy);
                float se = tex2D(_LuminanceTex, i.uv + float2(1, -1) * _MainTex_TexelSize.xy);
                float sw = tex2D(_LuminanceTex, i.uv + float2(-1, -1) * _MainTex_TexelSize.xy);

                // Apply Thresholding From Cardinals
                float maxL = max(max(max(max(m, n), e), s), w);
                float minL = min(min(min(min(m, n), e), s), w);
                float contrast = maxL - minL;

                if (contrast < max(_ContrastThreshold, _RelativeThreshold * maxL)) return col;

                // Determine Blend Factor
                float filter = 2 * (n + e + s + w) + ne + nw + se + sw;
                filter *= 1.0f / 12.0f;
                filter = abs(filter - m);
                filter = saturate(filter / contrast);

                float blendFactor = smoothstep(0, 1, filter);
                blendFactor *= blendFactor * _SubpixelBlending;

                // Edge Prediction
                float horizontal = abs(n + s - 2 * m) * 2 + abs(ne + se - 2 * e) + abs(nw + sw - 2 * w);
                float vertical = abs(e + w - 2 * m) * 2 + abs(ne + nw - 2 * n) + abs(se + sw - 2 * s);
                bool isHorizontal = horizontal >= vertical;

                float pLuminance = isHorizontal ? n : e;
                float nLuminance = isHorizontal ? s : w;
                float pGradient = abs(pLuminance - m);
                float nGradient = abs(nLuminance - m);

                float pixelStep = isHorizontal ? _MainTex_TexelSize.y : _MainTex_TexelSize.x;

                float oppositeLuminance = pLuminance;
                float gradient = pGradient;

                if (pGradient < nGradient) {
                    pixelStep = -pixelStep;
                    oppositeLuminance = nLuminance;
                    gradient = nGradient;
                }

                float2 uvEdge = i.uv;
                float2 edgeStep;
                if (isHorizontal) {
                    uvEdge.y += pixelStep * 0.5f;
                    edgeStep = float2(_MainTex_TexelSize.x, 0);
                } else {
                    uvEdge.x += pixelStep * 0.5f;
                    edgeStep = float2(0, _MainTex_TexelSize.y);
                }

                float edgeLuminance = (m + oppositeLuminance) * 0.5f;
                float gradientThreshold = gradient * 0.25f;

                float2 puv = uvEdge + edgeStep * edgeSteps[0];
                float pLuminanceDelta = tex2D(_LuminanceTex, puv) - edgeLuminance;
                bool pAtEnd = abs(pLuminanceDelta) >= gradientThreshold;

                UNITY_UNROLL
                for (int j = 1; j < EDGE_STEP_COUNT && !pAtEnd; ++j) {
                    puv += edgeStep * edgeSteps[j];
                    pLuminanceDelta = tex2D(_LuminanceTex, puv) - edgeLuminance;
                    pAtEnd = abs(pLuminanceDelta) >= gradientThreshold;
                }

                if (!pAtEnd)
                    puv += edgeStep * EDGE_GUESS;

                float2 nuv = uvEdge - edgeStep * edgeSteps[0];
                float nLuminanceDelta = tex2D(_LuminanceTex, nuv) - edgeLuminance;
                bool nAtEnd = abs(nLuminanceDelta) >= gradientThreshold;

                UNITY_UNROLL
                for (int k = 1; k < EDGE_STEP_COUNT && !nAtEnd; ++k) {
                    nuv -= edgeStep * edgeSteps[k];
                    nLuminanceDelta = tex2D(_LuminanceTex, nuv) - edgeLuminance;
                    nAtEnd = abs(nLuminanceDelta) >= gradientThreshold;
                }

                if (!nAtEnd)
                    nuv -= edgeStep * EDGE_GUESS;


                float pDistance, nDistance;
                if (isHorizontal) {
                    pDistance = puv.x - i.uv.x;
                    nDistance = i.uv.x - nuv.x;
                } else {
                    pDistance = puv.y - i.uv.y;
                    nDistance = i.uv.y - nuv.y;
                }

                float shortestDistance = nDistance;
                bool deltaSign = nLuminanceDelta >= 0;

                if (pDistance <= nDistance) {
                    shortestDistance = pDistance;
                    deltaSign = pLuminanceDelta >= 0;
                }

                if (deltaSign == (m - edgeLuminance >= 0)) return col;

                float edgeBlendFactor = 0.5f - shortestDistance / (pDistance + nDistance);

                float finalBlendFactor = max(blendFactor, edgeBlendFactor);

                float2 uv = i.uv;

                if (isHorizontal) 
                    uv.y += pixelStep * finalBlendFactor;
                else 
                    uv.x += pixelStep * finalBlendFactor;

                return tex2Dlod(_MainTex, float4(uv, 0, 0));
            }
            ENDCG
        }
    }
}