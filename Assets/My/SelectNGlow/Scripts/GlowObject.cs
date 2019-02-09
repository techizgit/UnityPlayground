using UnityEngine;
using System.Collections.Generic;

public class GlowObject : MonoBehaviour
{
	public float LerpFactor = 10;

	public Renderer[] Renderers
	{
		get;
		private set;
	}

	public Camera mainCam;

	private List<Material> _materials = new List<Material>();
	private float _currentColor;
	private float _targetColor;

	private Material pureColorMaterial;

	void Start()
	{

			
	}

	private void OnMouseEnter()
	{
		_targetColor = 1.0f;

		enabled = true;

	}

	private void OnMouseExit()
	{
		_targetColor = 0.0f;
		enabled = true;
	}

	/// <summary>
	/// Loop over all cached materials and update their color, disable self if we reach our target color.
	/// </summary>
	private void Update()
	{
		_currentColor = Mathf.Lerp(_currentColor, _targetColor, Time.deltaTime * LerpFactor);


		if (_currentColor<=0.01)
		{
			enabled = false;

		}

		if (enabled)
		{
			Vector3 screenPos = mainCam.WorldToScreenPoint(transform.position);
			Vector2 sPos = new Vector2(screenPos.x/Screen.height,screenPos.y/Screen.height);
			GlowComposite.compositeMat.SetVector("_ObjPoint", sPos);
			GlowComposite.blurMat.SetFloat("_Distance", screenPos.z);
			GlowComposite.pureColorMaterial.SetFloat("_GlowFactor", _currentColor);
		}
	}
}
