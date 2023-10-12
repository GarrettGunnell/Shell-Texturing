using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FXAA : MonoBehaviour {
    public Shader fxaaShader;

    private Material fxaaMaterial;

    void OnEnable() {
        fxaaMaterial = new Material(fxaaShader);
        fxaaMaterial.hideFlags = HideFlags.HideAndDontSave;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Graphics.Blit(source, destination, fxaaMaterial);
    }

    void OnDisable() {
        fxaaMaterial = null;
    }
}
