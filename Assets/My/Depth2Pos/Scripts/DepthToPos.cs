using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class DepthToPos : MonoBehaviour
{
	public Transform effectOrigin;
	public Material effectMaterial;
	public float radius;
	public bool moveWithMouse;

	private Camera cam;

	// Demo Code

	void Start()
	{
		//_scannables = FindObjectsOfType<Scannable>();
	}

	void Update()
	{


		if (Input.GetMouseButtonDown(0) || moveWithMouse)
		{
			Ray ray = cam.ScreenPointToRay(Input.mousePosition);
			RaycastHit hit;

			if (Physics.Raycast(ray, out hit))
			{
				//radius = 50;
				effectOrigin.position = hit.point;
			}
		}
	}
	// End Demo Code

	void OnEnable()
	{
		cam = GetComponent<Camera>();
		cam.depthTextureMode = DepthTextureMode.Depth;
	}

	[ImageEffectOpaque]
	void OnRenderImage(RenderTexture src, RenderTexture dst)
	{
		effectMaterial.SetVector("_WorldSpaceEffectPos", effectOrigin.position);
		effectMaterial.SetFloat("_Radius", radius);
		CustomBlit(src, dst, effectMaterial);
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

		mat.SetTexture("_MainTex", source);

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
