using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
public class GlowComposite : MonoBehaviour

{
	[Range (0, 10)]
	public float Intensity = 2;
	public GameObject glowTargets = null;

	public static Material compositeMat;

	public static Material pureColorMaterial;
	public static Material blurMat;

	private CommandBuffer commandBuffer = null;


	private static RenderTexture prePass;
	private static RenderTexture blurred;
	private static RenderTexture temp;

	void OnEnable()
	{
		prePass = new RenderTexture(Screen.width, Screen.height, 24,RenderTextureFormat.Default);
		blurred = new RenderTexture(Screen.width >> 2, Screen.height >> 2, 0);

		pureColorMaterial = new Material(Shader.Find("Hidden/WhiteReplace"));
		blurMat = new Material(Shader.Find("Hidden/Blur"));
		blurMat.SetVector("_BlurSize", new Vector2(blurred.texelSize.x * 1.5f, blurred.texelSize.y * 1.5f));

		Renderer[] renderers = glowTargets.GetComponentsInChildren<Renderer>();
		commandBuffer = new CommandBuffer();
		commandBuffer.SetRenderTarget(prePass);
		commandBuffer.ClearRenderTarget(true, true, Color.black);
		foreach (Renderer r in renderers)
		{
			commandBuffer.DrawRenderer(r, pureColorMaterial);
		}

		temp = RenderTexture.GetTemporary(blurred.width, blurred.height);
		commandBuffer.Blit(prePass,blurred);

		for (int i = 0; i < 5; i++)
		{
			commandBuffer.Blit(blurred, temp,blurMat, 0);
			commandBuffer.Blit(temp, blurred,blurMat, 1);
		}
			
		compositeMat = new Material(Shader.Find("Hidden/GlowComposite"));
		compositeMat.SetTexture("_GlowPrePassTex", prePass);
		compositeMat.SetTexture("_GlowBlurredTex", blurred);

	}

	void OnRenderImage(RenderTexture src, RenderTexture dst)
	{
		Graphics.ExecuteCommandBuffer(commandBuffer);
		compositeMat.SetFloat("_Intensity", Intensity);
		Graphics.Blit(src, dst, compositeMat, 0);
	}
		
	void OnDisable()
	{
		RenderTexture.ReleaseTemporary(temp);
	}
}
