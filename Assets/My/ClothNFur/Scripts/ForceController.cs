using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ForceController : MonoBehaviour
{
	private Material furMat;

	[Range (-5, 5)]
	public float gravity = 3;
	private Vector4 forceVector;
	private Vector4 targetForceVector;
	private Vector4 lastFrameForceVector;
	private Vector3 lastFramePosition;
	private Vector3 velocity;
	private Vector3 lastFrameVelocity;
	private Vector3 acceleration;

    void Start()
    {
    }

	void OnEnable()
	{
		furMat = GetComponent<Renderer>().sharedMaterial;
		forceVector = new Vector4(0, 0, 0, 0);
		targetForceVector = new Vector4(0, 0, 0, 0);
		lastFrameForceVector = new Vector4(0, 0, 0, 0);
		lastFramePosition = transform.position;
		velocity = new Vector3(0,0,0);
		lastFrameVelocity = new Vector3(0,0,0);

		furMat.SetVector("_Force", forceVector);
	}

    // Update is called once per frame
    void Update()
    {
		//transform.position = new Vector3 (4f * Mathf.Sin (3f * Mathf.Sin(Time.time)), 0, 4f * Mathf.Cos (3f * Mathf.Sin(Time.time)));
		//transform.position = new Vector3 (0, 4f * Mathf.Sin (3f * Mathf.Sin(Time.time)), 0);
		velocity = (transform.position - lastFramePosition) / Time.deltaTime;
		targetForceVector.x = Mathf.Clamp(-velocity.x / 2, -6, 6) ;
		targetForceVector.y = Mathf.Clamp(-velocity.y / 2, -6, 6) ;
		targetForceVector.z = Mathf.Clamp(-velocity.z / 2, -6, 6) ;
		lastFramePosition = transform.position;

		acceleration = (velocity - lastFrameVelocity) / Time.deltaTime;
		targetForceVector.x -= Mathf.Clamp(acceleration.x / 9,-6,6);
		targetForceVector.y -= Mathf.Clamp(acceleration.y / 9,-6,6);
		targetForceVector.z -= Mathf.Clamp(acceleration.z / 9,-6,6);
		lastFrameVelocity = velocity;

		forceVector = Vector4.Lerp(lastFrameForceVector, targetForceVector, 0.05f);
		lastFrameForceVector = forceVector;
		forceVector.y -= gravity;

		//Debug.Log(forceVector);
		furMat.SetVector("_Force", forceVector);
    }
}
