using UnityEngine;
using System.Collections;
using UnityEditor;

[CustomEditor(typeof(GradientTexture))]
public class ObjectBuilderEditor : Editor
{
	public override void OnInspectorGUI()
	{
		DrawDefaultInspector();

		GradientTexture myScript = (GradientTexture)target;
		if(GUILayout.Button("Generate Texture"))
		{
			myScript.Refresh();
			myScript.GenerateFile();
		}
	}
}