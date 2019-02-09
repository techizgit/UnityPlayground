using UnityEngine;
using System.Collections;
using System.IO;

public class GradientTexture : MonoBehaviour 
{
	public Gradient gradient = new Gradient();
	public int resolution = 256;
	public string fileName;

	private Texture2D texture;

	public Texture2D Generate(bool makeNoLongerReadable = false)
	{
		Texture2D tex = new Texture2D(resolution, 1, TextureFormat.ARGB32, false, true);
		tex.filterMode = FilterMode.Bilinear;
		tex.wrapMode = TextureWrapMode.Clamp;
		tex.anisoLevel = 1;


		Color[] colors = new Color[resolution];
		float div = (float)resolution;
		for (int i = 0; i < resolution; ++i)
		{
			float t = (float)i/div;
			colors[i] = gradient.Evaluate(t);
		}
		tex.SetPixels(colors);
		tex.Apply(false, makeNoLongerReadable);

		return tex;
	}

	public void GenerateFile()
	{
		byte[] bytes = texture.EncodeToPNG();
		File.WriteAllBytes(Application.dataPath + "/Textures/" + fileName + ".png", bytes);
	}

	public void Refresh()
	{
		if (texture != null)
		{
			DestroyImmediate(texture);
		}
		texture = Generate();

	}
		
	void OnDestroy()
	{
		if (texture != null)
		{
			DestroyImmediate(texture);
		}
	}
}