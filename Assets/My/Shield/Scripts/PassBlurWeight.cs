using UnityEngine;

//[ExecuteInEditMode]
public class PassBlurWeight : MonoBehaviour {

	[SerializeField]
	private float deviation = 1.0f;

	private float currentDeviation = 0.0f;

	private Material material;

	//https://en.wikipedia.org/wiki/Gaussian_blur
	float[] GaussianMatrix = new float[49]{
		0.00000067f,  0.00002292f,  0.00019117f,  0.00038771f,  0.00019117f,  0.00002292f,  0.00000067f,
		0.00002292f,  0.00078634f,  0.00655965f,  0.01330373f,  0.00655965f,  0.00078633f,  0.00002292f,
		0.00019117f,  0.00655965f,  0.05472157f,  0.11098164f,  0.05472157f,  0.00655965f,  0.00019117f,
		0.00038771f,  0.01330373f,  0.11098164f,  0.22508352f,  0.11098164f,  0.01330373f,  0.00038771f,
		0.00019117f,  0.00655965f,  0.05472157f,  0.11098164f,  0.05472157f,  0.00655965f,  0.00019117f,
		0.00002292f,  0.00078633f,  0.00655965f,  0.01330373f,  0.00655965f,  0.00078633f,  0.00002292f,
		0.00000067f,  0.00002292f,  0.00019117f,  0.00038771f,  0.00019117f,  0.00002292f,  0.00000067f
	};

	void Start () {
		#if UNITY_EDITOR
		currentDeviation = 0;
		CalculateGaussianMatrix(deviation);
		currentDeviation = deviation;
		#endif
	}

	void Update () {
		Vector3 screenPos = CameraComposite.cam.WorldToScreenPoint(transform.position);
		CameraComposite.blurMat.SetFloat("_Distance", screenPos.z);
		#if UNITY_EDITOR
		if (currentDeviation == deviation) return;
		CalculateGaussianMatrix(deviation);
		currentDeviation = deviation;
		#endif


	}

	void CalculateGaussianMatrix(float d) {
		int x = 0;
		int y = 0;

		float sum = 0.0f;
		for (x = -3; x <= 3; ++x) {
			for (y = -3; y <= 3; ++y) {
				GaussianMatrix[y * 7 + x + 24] = Mathf.Exp(-(x * x + y * y)/(2.0f * d * d)) / (2.0f * Mathf.PI * d * d);
				sum += GaussianMatrix [y * 7 + x + 24];
			}
		}

		//normalize
		sum = 1.0f / sum;
		for (int i = 0; i < GaussianMatrix.Length; i++) {
			GaussianMatrix [i] *= sum;
		}

		material = GetComponent<MeshRenderer>().sharedMaterial;
		material.SetFloatArray ("_BlurWeight", GaussianMatrix);
	}

}
