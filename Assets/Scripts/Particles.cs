using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Particles : MonoBehaviour {

	public int width = 256;
	public int height = 256;
	public Material material;
	private int total;
	private const int verticesMax = 65000;

	void Awake ()
	{
		GenerateMesh();
	}

	Vector3 RandomVector (float min, float max)
	{
		return new Vector3(UnityEngine.Random.Range(min, max), UnityEngine.Random.Range(min, max), UnityEngine.Random.Range(min, max));
	}

	public void GenerateMesh ()
	{
		total = width * height;
		int dimension = 4;
		int totalVertices = total * dimension;
		int meshCount = 1 + (int)Mathf.Floor(totalVertices / verticesMax);
		int quadIndex = 0;
		for (int m = 0; m < meshCount; ++m)
		{
			GameObject meshGameObject = new GameObject(gameObject.name + "_mesh" + m);
			MeshRenderer render = meshGameObject.AddComponent<MeshRenderer>();
			MeshFilter filter = meshGameObject.AddComponent<MeshFilter>();

			meshGameObject.transform.parent = transform;
			meshGameObject.layer = gameObject.layer;
			render.material = material;

			int count;
			if (meshCount > 1) {
				if (m == meshCount - 1) {
					count = totalVertices % verticesMax;
				} else {
					count = verticesMax;
				}
			} else {
				count = totalVertices;
			}

			Vector3[] vertices = new Vector3[count];
			Vector2[] uvs = new Vector2[count];
			int[] indices = new int[count];
			int index = 0;

			for (int f = 0; f + dimension - 1 < count; f += dimension) {
				float x = (float)(quadIndex % width)/(float)width;
				float y = (float)(quadIndex / width)/(float)height;
				Vector3 position = new Vector3(x,0,y);
				++quadIndex;
				uvs[index+0] = new Vector2(-1f,-1f);
				uvs[index+1] = new Vector2(1f,-1f);
				uvs[index+2] = new Vector2(1f,1f);
				uvs[index+3] = new Vector2(-1f,1f);
				for (int v = 0; v < dimension; ++v) {
					vertices[index] = position;
					indices[index] = index;
					++index;
				}
			}

			Mesh mesh = new Mesh();
			mesh.vertices = vertices;
			mesh.uv = uvs;
			mesh.SetIndices(indices, MeshTopology.Quads, 0);
			mesh.bounds = new Bounds(Vector3.zero, Vector3.one * 1000f);
			
			filter.mesh = mesh;
		}
	}
}
