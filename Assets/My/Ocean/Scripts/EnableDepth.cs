using UnityEngine;

[ExecuteInEditMode]
public class EnableDepth : MonoBehaviour {

	private Camera cam;

	void Start () {
		cam = GetComponent<Camera>(); 
		cam.depthTextureMode = DepthTextureMode.Depth;
	}
}