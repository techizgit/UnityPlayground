using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
	public GameObject[] targetObject = null;
    // Start is called before the first frame update
	[SerializeField]
	private Renderer _depthHackQuad;

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
		
//		if (i <=4)
//		{
//			StartCoroutine(Coroutine1(i));
//			i++;
//		}
    }

//	IEnumerator Coroutine1(int a)
//	{
//		Debug.Log(a);
//		yield return null;
//		Debug.Log(a+100);
//	}
}
