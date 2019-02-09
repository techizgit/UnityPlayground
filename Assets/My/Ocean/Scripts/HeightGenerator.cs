using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HeightGenerator : MonoBehaviour
{
    // Start is called before the first frame update

	public int _resolution = 512;
	public float _MaxTerrainHeight = 300f;
	public Material mat;

	public static RenderTexture heightMap;
	Camera heightSamplingCam;



    void Start()
    {
		RefreshHeightMap();
    }

    // Update is called once per frame
    void Update()
    {

		//RefreshHeightMap();


    }

	void RefreshHeightMap()
	{
		
		if (heightMap == null)
		{
			heightMap = new RenderTexture(_resolution, _resolution, 0);
			heightMap.format = RenderTextureFormat.RHalf;
			heightMap.useMipMap = false;
			heightMap.anisoLevel = 0;
		}

		if (heightSamplingCam == null)
		{
			heightSamplingCam = new GameObject("HeightMapCam").AddComponent<Camera>();
			heightSamplingCam.transform.position = transform.position + Vector3.up * _MaxTerrainHeight;
			heightSamplingCam.transform.parent = transform;
			heightSamplingCam.transform.eulerAngles = new Vector3(90,0,0);
			heightSamplingCam.orthographic = true;
			heightSamplingCam.orthographicSize = 600;
			heightSamplingCam.targetTexture = heightMap;
			heightSamplingCam.cullingMask = 1 << 9;
			heightSamplingCam.clearFlags = CameraClearFlags.SolidColor;
			heightSamplingCam.backgroundColor = Color.black;
			//_heightSamplingCam.enabled = false;
			heightSamplingCam.allowMSAA = false;
			//_heightSamplingCam.gameObject.SetActive(false);
			heightSamplingCam.SetReplacementShader(Shader.Find("Hidden/OrthDepthSampling"), null);
			heightSamplingCam.gameObject.SetActive(false);

		}
		//_heightSamplingCam.enabled = true;
		heightSamplingCam.Render();
		if(mat.HasProperty("_HeightMap")) mat.SetTexture( "_HeightMap", heightMap);

		//_heightSamplingCam.enabled = false;
	}
}
