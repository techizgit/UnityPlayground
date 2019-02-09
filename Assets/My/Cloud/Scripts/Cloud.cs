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

	// Demo Code

	void Start()
	{
		//_scannables = FindObjectsOfType<Scannable>();
	}

	void Update()
	{
		//Debug.Log(previousVP[1,1]);
	}
	// End Demo Code

	void OnEnable()
	{
		cam = GetComponent<Camera>();
		cam.depthTextureMode = DepthTextureMode.Depth;
		//cloud = new RenderTexture(Screen.width >> downSampling, Screen.height >> downSampling, 24,RenderTextureFormat.Default);
		cloud = new RenderTexture(1920 >> downSampling, 1080 >> downSampling, 24,RenderTextureFormat.Default);
		cloudLastFrame = new RenderTexture(1920 >> downSampling, 1080 >> downSampling, 24,RenderTextureFormat.Default);
	}

	//[ImageEffectOpaque]
	void OnRenderImage(RenderTexture src, RenderTexture dst)
	{
		cloudMaterial.SetMatrix("_LastFrameVPMatrix",previousVP);
		cloudMaterial.SetTexture("_LastFrameTex",cloudLastFrame);
		cloudMaterial.SetVector("_CameraPos", transform.position);
		CustomBlit(null, cloud, cloudMaterial);
		Graphics.CopyTexture(cloud, cloudLastFrame);
		cloudBlendingMaterial.SetTexture("_CloudTex", cloud);
		Graphics.Blit(src, dst, cloudBlendingMaterial);
		previousVP = cam.projectionMatrix * cam.worldToCameraMatrix;
	}

	void CustomBlit(RenderTexture source, RenderTexture dest, Material mat)
	{
		// Compute Frustum Corners
		//float camFar = cam.farClipPlane;
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

		//mat.SetTexture("_MainTex", source);

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
