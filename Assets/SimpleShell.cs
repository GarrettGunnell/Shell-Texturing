using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleShell : MonoBehaviour {
    public Mesh shellMesh;
    public Shader shellShader;

    public bool updateStatics = true;

    [Range(1, 256)]
    public int shellCount = 16;

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
        }
    }

    void Update() {

        if (updateStatics) {
            for (int i = 0; i < shellCount; ++i) {
                shells[i].GetComponent<MeshRenderer>().material.SetInt("_ShellCount", shellCount);
                shells[i].GetComponent<MeshRenderer>().material.SetInt("_ShellIndex", i + 1);
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
