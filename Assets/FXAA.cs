using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FXAA : MonoBehaviour {
    public Shader fxaaShader;

    [Range(0.0312f, 0.0833f)]
    public float contrastThreshold = 0.0312f;

    [Range(0.063f, 0.333f)]
    public float relativeThreshold = 0.063f;

    [Range(0.0f, 1.0f)]
    public float subpixelBlending = 1.0f;

    private Material fxaaMaterial;

    void OnEnable() {
        fxaaMaterial = new Material(fxaaShader);
        fxaaMaterial.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        var luminanceTex = RenderTexture.GetTemporary(source.width, source.height, 0, RenderTextureFormat.RHalf);
        
        fxaaMaterial.SetFloat("_ContrastThreshold", contrastThreshold);
        fxaaMaterial.SetFloat("_RelativeThreshold", relativeThreshold);
        fxaaMaterial.SetFloat("_SubpixelBlending", subpixelBlending);

        Graphics.Blit(source, luminanceTex, fxaaMaterial, 0);

        fxaaMaterial.SetTexture("_LuminanceTex", luminanceTex);

        Graphics.Blit(source, destination, fxaaMaterial, 1);
        RenderTexture.ReleaseTemporary(luminanceTex);
    }

    void OnDisable() {
        fxaaMaterial = null;
    }
}
