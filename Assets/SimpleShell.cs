using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleShell : MonoBehaviour {
    public Mesh shellMesh;
    public Shader shellShader;

    private Material shellMaterial;
    private GameObject[] shells;

    void Start() {
        shellMaterial = new Material(shellShader);

        shells = new GameObject[1];
        shells[0] = new GameObject("Shell 1");
        shells[0].AddComponent<MeshFilter>();
        shells[0].AddComponent<MeshRenderer>();

        Vector3 rotation = new Vector3(90, 0, 0);
        shells[0].transform.eulerAngles = rotation;
        
        shells[0].GetComponent<MeshFilter>().mesh = shellMesh;
        shells[0].GetComponent<MeshRenderer>().material = shellMaterial;
    }

    void Update() {
        
    }
}
