using UnityEngine;
using System.Collections;


public class Cloud : MonoBehaviour
{
	public Material cloudMaterial;
	public Material cloudBlendingMaterial;

	[Range(0,2)]
	public int downSampling;
	private static RenderTexture cloud;
	private static RenderTexture cloudLastFrame;
	private Camera cam;
	private Matrix4x4 previousVP;

	void Start()
	{
	}

	void Update()
	{
	}

	void OnEnable()
	{
		cam = GetComponent<Camera>();
		cam.depthTextureMode = DepthTextureMode.Depth;
		//Down-sampling the render texture to improve performance
		cloud = new RenderTexture(1920 >> downSampling, 1080 >> downSampling, 24,RenderTextureFormat.Default);
		//Another render texture to save last frame render result
		cloudLastFrame = new RenderTexture(1920 >> downSampling, 1080 >> downSampling, 24,RenderTextureFormat.Default);
	}
		
	void OnRenderImage(RenderTexture src, RenderTexture dst)
	{
		//Passing last frame's view projection matrix to GPU to apply temporal upsampling
		cloudMaterial.SetMatrix("_LastFrameVPMatrix",previousVP);
		//Passing last frame's render texture to GPU
		cloudMaterial.SetTexture("_LastFrameTex",cloudLastFrame);
		//Passing player position to GPU
		cloudMaterial.SetVector("_CameraPos", transform.position);
		CustomBlit(null, cloud, cloudMaterial);

		//Need to use this method because render texture is reference type (class)
		Graphics.CopyTexture(cloud, cloudLastFrame);
		cloudBlendingMaterial.SetTexture("_CloudTex", cloud);

		//Blend the cloud texture with background
		Graphics.Blit(src, dst, cloudBlendingMaterial);

		//Current frame view projection matrix to be applied in the next frame
		previousVP = cam.projectionMatrix * cam.worldToCameraMatrix;
	}

	void CustomBlit(RenderTexture source, RenderTexture dest, Material mat)
	{

		float camFov = cam.fieldOfView;
		float camAspect = cam.aspect;

		float fovWHalf = camFov * 0.5f;

		Vector3 toRight = cam.transform.right * Mathf.Tan(fovWHalf * Mathf.Deg2Rad) * camAspect;
		Vector3 toTop = cam.transform.up * Mathf.Tan(fovWHalf * Mathf.Deg2Rad);

		Vector3 topLeft = (cam.transform.forward - toRight + toTop);
		Vector3 topRight = (cam.transform.forward + toRight + toTop);
		Vector3 bottomRight = (cam.transform.forward + toRight - toTop);
		Vector3 bottomLeft = (cam.transform.forward - toRight - toTop);

		RenderTexture.active = dest;


		GL.PushMatrix();
		GL.LoadOrtho();

		mat.SetPass(0);

		GL.Begin(GL.QUADS);

		GL.MultiTexCoord2(0, 0.0f, 0.0f);
		GL.MultiTexCoord(1, bottomLeft);
		GL.Vertex3(0.0f, 0.0f, 0.0f);

		GL.MultiTexCoord2(0, 1.0f, 0.0f);
		GL.MultiTexCoord(1, bottomRight);
		GL.Vertex3(1.0f, 0.0f, 0.0f);

		GL.MultiTexCoord2(0, 1.0f, 1.0f);
		GL.MultiTexCoord(1, topRight);
		GL.Vertex3(1.0f, 1.0f, 0.0f);

		GL.MultiTexCoord2(0, 0.0f, 1.0f);
		GL.MultiTexCoord(1, topLeft);
		GL.Vertex3(0.0f, 1.0f, 0.0f);

		GL.End();
		GL.PopMatrix();
	}
}
