using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraUniform : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		Transform t = Camera.main.transform;
		Shader.SetGlobalVector("_CameraPosition", t.position);
		Shader.SetGlobalVector("_CameraForward", t.forward);
		Shader.SetGlobalVector("_CameraRight", t.right);
		Shader.SetGlobalVector("_CameraUp", t.up);
	}
}
