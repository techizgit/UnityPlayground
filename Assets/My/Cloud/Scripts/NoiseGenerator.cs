using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class NoiseGenerator : MonoBehaviour
{
	private Texture3D tex;
	public int size = 128;

	float r; float phi; float theta;
	void SetPerlinVtx(ref float[,,,] pVtx, int div)
	{
		for (int x = 0; x < size / div; x++) {
			for (int y = 0; y < size / div; y++) {
				for (int z = 0; z < size / div; z++) {
					r = Mathf.Pow(Random.value, 1/3);
					phi = Random.value * 6.2832f;
					theta = Random.value * 3.1416f;
					pVtx[x,y,z,0] = Mathf.Sin(phi)* Mathf.Cos(theta) * r;
					pVtx[x,y,z,1] = Mathf.Sin(phi)* Mathf.Sin(theta) * r;
					pVtx[x,y,z,2] = Mathf.Cos(phi) * r;
				}
			}
		}
	}

	public float GetPerlin(int x, int y, int z, int div,float[,,,] pVtx)
	{
		float xP = (float) x/ (float) div;
		int x1 = (int) Mathf.Floor(xP);
		int x2 = (int) Mathf.Ceil(xP);
		float xF = xP - (float)x1;
		if (x2 == size / div) x2 = 0;

		float yP = (float) y/ (float) div;
		int y1 = (int) Mathf.Floor(yP);
		int y2 = (int) Mathf.Ceil(yP);
		float yF = yP - (float)y1;
		if (y2 == size / div) y2 = 0;

		float zP = (float) z/ (float) div;
		int z1 = (int) Mathf.Floor(zP);
		int z2 = (int) Mathf.Ceil(zP);
		float zF = zP - (float)z1;
		if (z2 == size / div) z2 = 0;

		float p111 = xF * pVtx[x1,y1,z1,0] + yF * pVtx[x1,y1,z1,1] + zF * pVtx[x1,y1,z1,2];
		p111 = (p111 + 1) * 0.5f;
		float p211 = (xF - 1) * pVtx[x2,y1,z1,0] + yF * pVtx[x2,y1,z1,1] + zF * pVtx[x2,y1,z1,2];
		p211 = (p211 + 1) * 0.5f;
		float p121 = xF * pVtx[x1,y2,z1,0] + (yF - 1) * pVtx[x1,y2,z1,1] + zF * pVtx[x1,y2,z1,2];
		p121 = (p121 + 1) * 0.5f;
		float p221 = (xF - 1) * pVtx[x2,y2,z1,0] + (yF - 1) * pVtx[x2,y2,z1,1] + zF * pVtx[x2,y2,z1,2];
		p221 = (p221 + 1) * 0.5f;
		float p112 = xF * pVtx[x1,y1,z2,0] + yF * pVtx[x1,y1,z2,1] + (zF - 1) * pVtx[x1,y1,z2,2];
		p112 = (p112 + 1) * 0.5f;
		float p212 = (xF - 1) * pVtx[x2,y1,z2,0] + yF * pVtx[x2,y1,z2,1] + (zF - 1) * pVtx[x2,y1,z2,2];
		p212 = (p212 + 1) * 0.5f;
		float p122 = xF * pVtx[x1,y2,z2,0] + (yF - 1) * pVtx[x1,y2,z2,1] + (zF - 1) * pVtx[x1,y2,z2,2];
		p122 = (p122 + 1) * 0.5f;
		float p222 = (xF - 1) * pVtx[x2,y2,z2,0] + (yF - 1) * pVtx[x2,y2,z2,1] + (zF - 1) * pVtx[x2,y2,z2,2];
		p222 = (p222 + 1) * 0.5f;

		xF = 3 * xF * xF - 2 * xF * xF * xF;
		yF = 3 * yF * yF - 2 * yF * yF * yF;
		zF = 3 * zF * zF - 2 * zF * zF * zF;

		float low = Mathf.Lerp(Mathf.Lerp(p111,p211,xF), Mathf.Lerp(p121,p221,xF),yF);
		float high = Mathf.Lerp(Mathf.Lerp(p112,p212,xF), Mathf.Lerp(p122,p222,xF),yF);
		return Mathf.Lerp(low, high, zF);
	}

	public void SetWorleyPoint(ref float[,,,] wCellPoint, int div)
	{
		for (int x = 0; x < size / div; x++) {
			for (int y = 0; y < size / div; y++) {
				for (int z = 0; z < size / div; z++) {
					wCellPoint[x,y,z,0] = Random.value;
					wCellPoint[x,y,z,1] = Random.value;
					wCellPoint[x,y,z,2] = Random.value;
				}
			}
		}
	}

	public float GetWorley(int x, int y, int z, int div,float[,,,] wCellPoint)
	{
		float xFrac = (float) x/ (float) div;
		int xW = (int)Mathf.Floor(xFrac);
		float yFrac = (float) y/ (float) div;
		int yW = (int)Mathf.Floor(yFrac);
		float zFrac = (float) z/ (float) div;
		int zW = (int)Mathf.Floor(zFrac);

		float xF = xFrac - (float)xW;
		float yF = yFrac - (float)yW;
		float zF = zFrac - (float)zW;

		Vector3 self = new Vector3(xF,yF,zF);
		Vector3 sample = new Vector3(0,0,0);


		float dist = 10;
		for (int i = xW - 1; i <= xW + 1;i++)
		{
			for (int j = yW - 1; j <= yW + 1;j++)
			{
				for (int k = zW - 1; k <= zW + 1;k++)
				{
					int ii = i; int jj = j; int kk = k;
					if (i == -1) ii = size / div - 1;
					if (i == size / div) ii = 0;
					if (j == -1) jj = size / div - 1;
					if (j == size / div) jj = 0;
					if (k == -1) kk = size / div - 1;
					if (k == size / div) kk = 0;

					sample.x = wCellPoint[ii,jj,kk,0] + (i - xW);
					sample.y = wCellPoint[ii,jj,kk,1] + (j - yW);
					sample.z = wCellPoint[ii,jj,kk,2] + (k - zW);

					float tmp = (sample - self).magnitude;
					if (tmp< dist) dist = tmp;

				}
			}
		}
			
		return 1 - Mathf.Clamp01(dist);

	}


	public void GetNoise(ref Color[] cols, int cellSize, int i,int rgba,float attenuation)
	{

		if (i == 1)
		{
			float[,,,] pVtx = new float[size / cellSize,size / cellSize,size / cellSize,3];
			SetPerlinVtx(ref pVtx,cellSize);
			int idx = 0;
			for (int x = 0; x < size; x++) {
				for (int y = 0; y < size; y++) {
					for (int z = 0; z < size; z++) {

						if (rgba == 1) cols [idx].r += GetPerlin(x,y,z,cellSize,pVtx) * attenuation;
						if (rgba == 2) cols [idx].g += GetPerlin(x,y,z,cellSize,pVtx) * attenuation;
						if (rgba == 3) cols [idx].b += GetPerlin(x,y,z,cellSize,pVtx) * attenuation;
						if (rgba == 4) cols [idx].a += GetPerlin(x,y,z,cellSize,pVtx) * attenuation;

						idx += 1;
					}
				}
			}
		} else 
		{
			float[,,,] wCellPoint = new float[size / cellSize,size / cellSize,size / cellSize,3];
			SetWorleyPoint(ref wCellPoint,cellSize);
			int idx = 0;
			for (int x = 0; x < size; x++) {
				for (int y = 0; y < size; y++) {
					for (int z = 0; z < size; z++) {
						if (rgba == 1) cols [idx].r += GetWorley(x,y,z,cellSize,wCellPoint) * attenuation;
						if (rgba == 2) cols [idx].g += GetWorley(x,y,z,cellSize,wCellPoint) * attenuation;
						if (rgba == 3) cols [idx].b += GetWorley(x,y,z,cellSize,wCellPoint) * attenuation;
						if (rgba == 4) cols [idx].a += GetWorley(x,y,z,cellSize,wCellPoint) * attenuation;

						idx += 1;
					}
				}
			}
		}

	}




	public void GenerateNoise()
	{
		



		tex = new Texture3D (size, size, size, TextureFormat.ARGB32, true);
		var cols = new Color[size * size * size];


		GetNoise(ref cols,8,1,1,1);
		GetNoise(ref cols,16,2,2,1);
		GetNoise(ref cols,8,2,3,1);
		GetNoise(ref cols,4,2,4,1);

		tex.SetPixels (cols);
		tex.Apply ();
		//GetComponent<Renderer>().sharedMaterial.SetTexture ("_Volume", tex);

		AssetDatabase.CreateAsset(tex, "Assets/My/Cloud/Textures/CloudBase.asset");
	}

	void Start ()
	{
		//GenerateNoise();
	}   
}
