using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ShaderPass : MonoBehaviour
{
	public Shader shader;
	public string uniformName = "_ShaderPassTexture";
	public RenderTextureFormat textureFormat = RenderTextureFormat.ARGB32;
	public FilterMode filterMode = FilterMode.Point;
	public float frameRate = 60;
	[Range(1,16)] public int levelOfDetails = 1;

	private FrameBuffer frameBuffer;
	private RenderTexture output;
	private float firedAt;
	private Material materialShader;

	void Start ()
	{
		frameBuffer = new FrameBuffer(Screen.width, Screen.height, 2, textureFormat, filterMode);
		firedAt = -1f/frameRate;
		materialShader = new Material(shader);
	}

	void Update ()
	{
		if (materialShader && firedAt + 1f / frameRate < Time.time) {
			firedAt = Time.time;
			Shader.SetGlobalTexture(uniformName, frameBuffer.Apply(materialShader));
		}
	}

	public void ChangeLevelOfDetails (int dt)
	{
		levelOfDetails = (int)Mathf.Clamp(levelOfDetails + dt, 1, 16);
		frameBuffer = new FrameBuffer(Screen.width/levelOfDetails, Screen.height/levelOfDetails, 2, textureFormat, filterMode);
	}
}
