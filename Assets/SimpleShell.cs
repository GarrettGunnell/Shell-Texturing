using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleShell : MonoBehaviour {
    public Mesh shellMesh;
    public Shader shellShader;

    [Range(0, 16)]
    public int shellIndex = 0;

    private Material shellMaterial;
    private GameObject[] shells;

    void Start() {
        shellMaterial = new Material(shellShader);

        shells = new GameObject[2];
        shells[0] = new GameObject("Shell 1");
        shells[0].AddComponent<MeshFilter>();
        shells[0].AddComponent<MeshRenderer>();

        Vector3 rotation = new Vector3(90, 0, 0);
        shells[0].transform.eulerAngles = rotation;
        
        shells[0].GetComponent<MeshFilter>().mesh = shellMesh;
        shells[0].GetComponent<MeshRenderer>().material = shellMaterial;
        shells[0].transform.parent = this.transform;

        shells[1] = new GameObject("Shell 2");
        shells[1].AddComponent<MeshFilter>();
        shells[1].AddComponent<MeshRenderer>();

        shells[1].transform.eulerAngles = rotation;
        
        shells[1].GetComponent<MeshFilter>().mesh = shellMesh;
        shells[1].GetComponent<MeshRenderer>().material = shellMaterial;
        shells[1].transform.parent = this.transform;
    }

    void Update() {
        shells[0].GetComponent<MeshRenderer>().material.SetInt("_ShellIndex", shellIndex);
        shells[1].GetComponent<MeshRenderer>().material.SetInt("_ShellIndex", shellIndex + 1);
        
    }
}
