using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class CameraComposite : MonoBehaviour


{
	[Range (0, 30)]
	public float Intensity = 5;
	[Range (0.5f, 3)]
	public float EdgeBlurSize = 1;

	public static Material compositeMat;
	public static Material blurMat;
	public static Camera cam;
	private static RenderTexture blurred;


	void OnEnable()
	{

		compositeMat = new Material(Shader.Find("Hidden/ShieldComposite"));
		blurMat = new Material(Shader.Find("Hidden/ShieldBlur"));
		blurred = new RenderTexture(Screen.width >> 0, Screen.height >> 0, 0);
		compositeMat.SetTexture("_ShieldBlurredTex", blurred);
		blurMat.SetVector("_BlurSize", new Vector2(blurred.texelSize.x * EdgeBlurSize, blurred.texelSize.y * EdgeBlurSize));
		cam = GetComponent<Camera>();


	}

	void OnRenderImage(RenderTexture src, RenderTexture dst)
	{
		blurMat.SetVector("_BlurSize", new Vector2(blurred.texelSize.x * EdgeBlurSize, blurred.texelSize.y * EdgeBlurSize));
		Graphics.SetRenderTarget(blurred);
		GL.Clear(false, true, Color.clear);
		Graphics.Blit(src, blurred);

		for (int i = 0; i < 5; i++)
		{
			var temp = RenderTexture.GetTemporary(blurred.width, blurred.height);
			Graphics.Blit(blurred, temp, blurMat, 0);
			Graphics.Blit(temp, blurred, blurMat, 1);
			RenderTexture.ReleaseTemporary(temp);
		}
		compositeMat.SetFloat("_Intensity", Intensity);
		Graphics.Blit(src, dst, compositeMat);

	
	}
}
