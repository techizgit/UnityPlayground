using UnityEngine;
using System.Collections;
using UnityEditor;

[CustomEditor(typeof(NoiseGenerator))]
public class CloudBaseGeneratorEditor : Editor
{
	public override void OnInspectorGUI()
	{
		DrawDefaultInspector();

		NoiseGenerator myScript = (NoiseGenerator)target;
		if(GUILayout.Button("Generate Texture"))
		{
			myScript.GenerateNoise();
		}
	}
}