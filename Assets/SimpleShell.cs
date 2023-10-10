using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleShell : MonoBehaviour {
    public Mesh shellMesh;
    public Shader shellShader;

    public bool updateStatics = true;

    [Range(1, 256)]
    public int shellCount = 16;

    [Range(0.0f, 0.5f)]
    public float shellLength = 0.15f;

    [Range(1.0f, 1000.0f)]
    public float density = 100.0f;

    [Range(-1.0f, 1.0f)]
    public float noiseBias = 0.0f;

    [Range(0.0f, 10.0f)]
    public float thickness = 1.0f;

    public Color shellColor;

    [Range(0.0f, 3.0f)]
    public float occlusionAttenuation = 1.0f;

    private Material shellMaterial;
    private GameObject[] shells;

    void OnEnable() {
        shellMaterial = new Material(shellShader);

        shells = new GameObject[shellCount];

        for (int i = 0; i < shellCount; ++i) {
            shells[i] = new GameObject("Shell 1");
            shells[i].AddComponent<MeshFilter>();
            shells[i].AddComponent<MeshRenderer>();

            Vector3 rotation = new Vector3(90, 0, 0);
            shells[i].transform.eulerAngles = rotation;
            
            shells[i].GetComponent<MeshFilter>().mesh = shellMesh;
            shells[i].GetComponent<MeshRenderer>().material = shellMaterial;
            shells[i].transform.parent = this.transform;
            shells[i].GetComponent<MeshRenderer>().material.SetInt("_ShellCount", shellCount);
            shells[i].GetComponent<MeshRenderer>().material.SetInt("_ShellIndex", i + 1);
            shells[i].GetComponent<MeshRenderer>().material.SetFloat("_ShellLength", shellLength);
            shells[i].GetComponent<MeshRenderer>().material.SetFloat("_Density", density);
            shells[i].GetComponent<MeshRenderer>().material.SetFloat("_NoiseBias", noiseBias);
            shells[i].GetComponent<MeshRenderer>().material.SetFloat("_Thickness", thickness);
            shells[i].GetComponent<MeshRenderer>().material.SetFloat("_Attenuation", occlusionAttenuation);
            shells[i].GetComponent<MeshRenderer>().material.SetVector("_ShellColor", shellColor);
        }
    }

    void Update() {

        if (updateStatics) {
            for (int i = 0; i < shellCount; ++i) {
                shells[i].GetComponent<MeshRenderer>().material.SetInt("_ShellCount", shellCount);
                shells[i].GetComponent<MeshRenderer>().material.SetInt("_ShellIndex", i + 1);
                shells[i].GetComponent<MeshRenderer>().material.SetFloat("_ShellLength", shellLength);
                shells[i].GetComponent<MeshRenderer>().material.SetFloat("_Density", density);
                shells[i].GetComponent<MeshRenderer>().material.SetFloat("_NoiseBias", noiseBias);
                shells[i].GetComponent<MeshRenderer>().material.SetFloat("_Thickness", thickness);
                shells[i].GetComponent<MeshRenderer>().material.SetFloat("_Attenuation", occlusionAttenuation);
                shells[i].GetComponent<MeshRenderer>().material.SetVector("_ShellColor", shellColor);
            }
        }

    }

    void OnDisable() {
        for (int i = 0; i < shells.Length; ++i) {
            Destroy(shells[i]);
        }

        shells = null;
    }
}
