using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticlesGPU : Particles {

	public Material materialPosition;
	public Transform target;
	public float radius = 10f;
	private Pass pass;

	// Use this for initialization
	void Start () {
		MeshFilter[] filters = GetComponentsInChildren<MeshFilter>();
		Mesh[] meshArray = new Mesh[filters.Length];
		for (int i = 0; i < filters.Length; ++i) {
			meshArray[i] = filters[i].sharedMesh;
		}
		Utils.MapVertexUV(meshArray, width);
		pass = new Pass (materialPosition, meshArray);
		pass.Print(meshArray);
	}
	
	// Update is called once per frame
	void Update () {
		materialPosition.SetTexture("_SpawnTexture", pass.texture);
		materialPosition.SetVector("_Target", target.position);
		materialPosition.SetFloat("_Radius", radius);
		pass.Update();
		material.SetTexture("_PositionTexture", pass.result);
	}

	void OnDrawGizmos ()
	{
		Gizmos.DrawWireSphere(target.position, radius);
	}
}
