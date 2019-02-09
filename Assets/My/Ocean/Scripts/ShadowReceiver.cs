using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowReceiver : MonoBehaviour
{





	public Material mat;
	RenderTexture _shadowMask;
	Camera _shadowMaskCam;

	void Start()
	{
		//Debug.Log(111);
	}

	// Update is called once per frame
	void Update()
	{
		if (_shadowMask == null)
		{
			Camera mainCam = GetComponent<Camera>();
			_shadowMask = new RenderTexture(mainCam.pixelWidth/3, mainCam.pixelHeight/3, 0);
			//_heightMap.format = RenderTextureFormat.RHalf;
			_shadowMask.useMipMap = false;
			_shadowMask.anisoLevel = 0;
		}


		if (_shadowMaskCam == null)
		{
			_shadowMaskCam = new GameObject("ShadowMaskCam").AddComponent<Camera>();
			_shadowMaskCam.cullingMask = (1 << 10) | (1 << 9) | (1 << 0);

			_shadowMaskCam.clearFlags = CameraClearFlags.SolidColor;
			_shadowMaskCam.backgroundColor = Color.white;
			_shadowMaskCam.allowMSAA = false;
			_shadowMaskCam.targetTexture = _shadowMask;
			//_shadowMaskCam.useOcclusionCulling = false;
			_shadowMaskCam.SetReplacementShader(Shader.Find("Hidden/ShadowReceiver"), null);
			_shadowMaskCam.transform.parent = transform;
			_shadowMaskCam.gameObject.SetActive(false);

		}
		//_shadowMaskCam.gameObject.SetActive(true);
		_shadowMaskCam.transform.position = transform.position;
		_shadowMaskCam.transform.rotation = transform.rotation;

		_shadowMaskCam.Render();
		if(mat.HasProperty("_ShadowMask")) mat.SetTexture( "_ShadowMask", _shadowMask);


	}

}