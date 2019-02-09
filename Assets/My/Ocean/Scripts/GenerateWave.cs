using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.InteropServices;

public class GenerateWave : MonoBehaviour
{
	public struct waveSampler
	{
		
		public float x;
		public float z;
		public Vector3 displacement;

	}
	[Header("Wave Parameters")]
	public float S = 200;
	[Range(0.1f,4.0f)]
	public float shoreWaveAttenuation = 2.0f;

	[Header("Wave L=2")]
	[Range(0.0f,1.0f)]
	public float A1;
	[Range(0.0f,1.0f)]
	public float Stp1;
	[Range(0.0f,360.0f)]
	public float D1;

	[Header("Wave L=3")]
	[Range(0.0f,1.0f)]
	public float A2;
	[Range(0.0f,1.0f)]
	public float Stp2;
	[Range(0.0f,360.0f)]
	public float D2;

	[Header("Wave L=5")]
	[Range(0.0f,1.0f)]
	public float A3;
	[Range(0.0f,1.0f)]
	public float Stp3;
	[Range(0.0f,360.0f)]
	public float D3;

	[Header("Wave L=8")]
	[Range(0.0f,1.0f)]
	public float A4;
	[Range(0.0f,1.0f)]
	public float Stp4;
	[Range(0.0f,360.0f)]
	public float D4;

	[Header("Wave L=13")]
	[Range(0.0f,1.0f)]
	public float A5;
	[Range(0.0f,1.0f)]
	public float Stp5;
	[Range(0.0f,360.0f)]
	public float D5;

	[Header("Wave L=21")]
	[Range(0.0f,1.0f)]
	public float A6;
	[Range(0.0f,1.0f)]
	public float Stp6;
	[Range(0.0f,360.0f)]
	public float D6;

	[Header("Wave L=34")]
	[Range(0.0f,1.0f)]
	public float A7;
	[Range(0.0f,1.0f)]
	public float Stp7;
	[Range(0.0f,360.0f)]
	public float D7;

	[Header("Wave L=55")]
	[Range(0.0f,1.0f)]
	public float A8;
	[Range(0.0f,1.0f)]
	public float Stp8;
	[Range(0.0f,360.0f)]
	public float D8;

	[Header("Wave L=89")]
	[Range(0.0f,1.0f)]
	public float A9;
	[Range(0.0f,1.0f)]
	public float Stp9;
	[Range(0.0f,360.0f)]
	public float D9;

	[Header("Wave L=144")]
	[Range(0.0f,1.0f)]
	public float A10;
	[Range(0.0f,1.0f)]
	public float Stp10;
	[Range(0.0f,360.0f)]
	public float D10;

	[Header("Wave L=233")]
	[Range(0.0f,1.0f)]
	public float A11;
	[Range(0.0f,1.0f)]
	public float Stp11;
	[Range(0.0f,360.0f)]
	public float D11;

	[Header("Wave L=377")]
	[Range(0.0f,1.0f)]
	public float A12;
	[Range(0.0f,1.0f)]
	public float Stp12;
	[Range(0.0f,360.0f)]
	public float D12;



	private Vector3 lastFrameLocation;
	private Vector2 uvOffset;
	private Transform mainCam;
	public ComputeShader computeShader;
	public Material seaMaterial;
	public Material foamMaterial;

	public Material testMat;
	ComputeBuffer samplers;
	RenderTexture heightMap;

	RenderTexture foamTexture;
	RenderTexture lastFoamTexture;

	const int WARP_SIZE = 1024;
	int warpCount;
	int kernelIndex;
	waveSampler[] initBuffer;
	int stride;

	int _resolution = 768;
    // Start is called before the first frame update
    void Start()
    {
		int size = _resolution * _resolution;
		foamTexture = new RenderTexture(_resolution, _resolution, 0);
		lastFoamTexture = new RenderTexture(_resolution, _resolution, 0);

		warpCount = Mathf.CeilToInt((float)size / WARP_SIZE);
		stride = Marshal.SizeOf(typeof(waveSampler));

		samplers = new ComputeBuffer(size, stride);

		initBuffer = new waveSampler[size];

		heightMap = HeightGenerator.heightMap;


		for (int i = 0; i < size; i++)
		{
			initBuffer[i] = new waveSampler();

			initBuffer[i].x = (float)(i % _resolution) / (float)_resolution;
			initBuffer[i].z = (float)(i / _resolution) / (float)_resolution;
			initBuffer[i].displacement = Vector3.zero;
			//if (i == 4000) Debug.Log(initBuffer[i].x);

		}
		mainCam = GameObject.FindGameObjectWithTag("MainCamera").transform;

		samplers.SetData(initBuffer);
		kernelIndex = computeShader.FindKernel("Update");
		computeShader.SetBuffer(kernelIndex, "displacementSample", samplers);
		computeShader.SetTexture(kernelIndex, "_heightMap", heightMap);
		seaMaterial.SetInt("_resolution", _resolution);
		seaMaterial.SetBuffer("displacementSample", samplers);
		foamMaterial.SetBuffer("displacementSample", samplers);
		seaMaterial.SetTexture( "_FoamMap", lastFoamTexture);
		testMat.SetTexture( "_Foam", lastFoamTexture);
		//Debug.Log(kernelIndex);
    }

    // Update is called once per frame
    void Update()
    {
		computeShader.SetVector("_playerLocation",mainCam.position);
		computeShader.SetFloat("_A1",A1);
		computeShader.SetFloat("_Stp1",Stp1);
		computeShader.SetFloat("_D1",D1);

		computeShader.SetFloat("_A2",A1);
		computeShader.SetFloat("_Stp2",Stp2);
		computeShader.SetFloat("_D2",D2);

		computeShader.SetFloat("_A3",A3);
		computeShader.SetFloat("_Stp3",Stp3);
		computeShader.SetFloat("_D3",D3);

		computeShader.SetFloat("_A4",A4);
		computeShader.SetFloat("_Stp4",Stp4);
		computeShader.SetFloat("_D4",D4);

		computeShader.SetFloat("_A5",A5);
		computeShader.SetFloat("_Stp5",Stp5);
		computeShader.SetFloat("_D5",D5);

		computeShader.SetFloat("_A6",A6);
		computeShader.SetFloat("_Stp6",Stp6);
		computeShader.SetFloat("_D6",D6);

		computeShader.SetFloat("_A7",A7);
		computeShader.SetFloat("_Stp7",Stp7);
		computeShader.SetFloat("_D7",D7);

		computeShader.SetFloat("_A8",A8);
		computeShader.SetFloat("_Stp8",Stp8);
		computeShader.SetFloat("_D8",D8);

		computeShader.SetFloat("_A9",A9);
		computeShader.SetFloat("_Stp9",Stp9);
		computeShader.SetFloat("_D9",D9);

		computeShader.SetFloat("_A10",A10);
		computeShader.SetFloat("_Stp10",Stp10);
		computeShader.SetFloat("_D10",D10);

		computeShader.SetFloat("_A11",A11);
		computeShader.SetFloat("_Stp11",Stp11);
		computeShader.SetFloat("_D11",D11);

		computeShader.SetFloat("_A12",A12);
		computeShader.SetFloat("_Stp12",Stp12);
		computeShader.SetFloat("_D12",D12);

		computeShader.SetFloat("_S",S);
		computeShader.SetFloat("_ShoreWaveAttenuation",shoreWaveAttenuation);

		seaMaterial.SetFloat("_A1",A1);
		seaMaterial.SetFloat("_Stp1",Stp1);
		seaMaterial.SetFloat("_D1",D1);

		seaMaterial.SetFloat("_A2",A1);
		seaMaterial.SetFloat("_Stp2",Stp2);
		seaMaterial.SetFloat("_D2",D2);

		seaMaterial.SetFloat("_A3",A3);
		seaMaterial.SetFloat("_Stp3",Stp3);
		seaMaterial.SetFloat("_D3",D3);

		seaMaterial.SetFloat("_A4",A4);
		seaMaterial.SetFloat("_Stp4",Stp4);
		seaMaterial.SetFloat("_D4",D4);

		seaMaterial.SetFloat("_A5",A5);
		seaMaterial.SetFloat("_Stp5",Stp5);
		seaMaterial.SetFloat("_D5",D5);

		seaMaterial.SetFloat("_A6",A6);
		seaMaterial.SetFloat("_Stp6",Stp6);
		seaMaterial.SetFloat("_D6",D6);

		seaMaterial.SetFloat("_A7",A7);
		seaMaterial.SetFloat("_Stp7",Stp7);
		seaMaterial.SetFloat("_D7",D7);

		seaMaterial.SetFloat("_A8",A8);
		seaMaterial.SetFloat("_Stp8",Stp8);
		seaMaterial.SetFloat("_D8",D8);

		seaMaterial.SetFloat("_A9",A9);
		seaMaterial.SetFloat("_Stp9",Stp9);
		seaMaterial.SetFloat("_D9",D9);

		seaMaterial.SetFloat("_A10",A10);
		seaMaterial.SetFloat("_Stp10",Stp10);
		seaMaterial.SetFloat("_D10",D10);

		seaMaterial.SetFloat("_A11",A11);
		seaMaterial.SetFloat("_Stp11",Stp11);
		seaMaterial.SetFloat("_D11",D11);

		seaMaterial.SetFloat("_A12",A12);
		seaMaterial.SetFloat("_Stp12",Stp12);
		seaMaterial.SetFloat("_D12",D12);

		seaMaterial.SetFloat("_S",S);
		seaMaterial.SetFloat("_ShoreWaveAttenuation",shoreWaveAttenuation);



		computeShader.Dispatch(kernelIndex, warpCount, 1, 1);


		uvOffset.x  = (lastFrameLocation - mainCam.transform.position).x/600;
		uvOffset.y  = (lastFrameLocation - mainCam.transform.position).z/600;

		foamMaterial.SetVector("_uvOffset",uvOffset);


		Graphics.Blit(lastFoamTexture, foamTexture, foamMaterial);
		Graphics.CopyTexture(foamTexture,lastFoamTexture);

		lastFrameLocation = mainCam.transform.position;
    }

	void OnDestroy()
	{
		if (samplers != null)
			samplers.Release();
	}
}
