using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Uniforms : MonoBehaviour {

	public Transform targetTornado;
	public Color color;
	public float slide;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		Shader.SetGlobalVector("_TargetTornado", targetTornado.position);
		Shader.SetGlobalFloat("_Slide", slide);
		Shader.SetGlobalColor("_Colour", color);
	}
}
