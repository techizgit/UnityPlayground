using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SeaLocation : MonoBehaviour
{

	private Transform mainCam;
    // Start is called before the first frame update
    void Start()
    {
		mainCam = GameObject.FindGameObjectWithTag("MainCamera").transform;
    }

    // Update is called once per frame
    void Update()
    {
		Vector3 position = mainCam.position;
		position.y  = 0;
		transform.position = position;
    }
}
