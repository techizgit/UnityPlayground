# Unity Playground
## Ocean Shader
![](https://upload-images.jianshu.io/upload_images/16037344-9e9f4abbe25da73f.png)
![](https://upload-images.jianshu.io/upload_images/16037344-313c512ff0e4a11b.png)
![](https://upload-images.jianshu.io/upload_images/16037344-d7580d01f4fe3225.png)

### Wave Simulation
Using 12 groups of Gerstner wave with different wave length to form the shape of surface,  each group has 6 single Gerster wave with different direction. The calculated displacement data will be applied on a 400x400 plane mesh after in the ocean vertex shader. The calculating process is done in another shader, and we can change this method to FFT (using the spectrum of real world water waveforms) to get more accurate result of the surface shape.

### Reflective Color
In this part I still used the method of mirror reflecting. Basically we need another camera which is placed in a symmetrical position of the main camera relative to the water surface, and use the render texture of this camera to simulate mirror reflection. To avoid reflect objects under water which can produce false result, we need to change the near clip plane of the mirror camera by using `cam.CalculateObliqueMatrix(clipPlane)` to calculate a camera projection matrix with its near clip plane setting to `clipPlane` and passing this new matrix to the camera. Then we use the world space normal's XZ component to distort the UV, and use the Y component of fragment world position to adjust the sampling point of the reflection texture to simulate the wave height. It looks good until we apply a very big wave onto the water surface, but this approximation is good and simple enough.

### Refractive Color
This part I used `GrabPass` to get the transparent texture under water. Still, I used world space normal's XZ component to distort the UV,and then use the view ray depth in water to decide the "transparency".  However we need to fix this:

![](https://upload-images.jianshu.io/upload_images/16037344-7da537823a5226c1.png)

This is caused by false distortion of background above water. So after distortion we need to sample the ray depth in water again to remove the false distortion. If the depth is smaller than 0, it means that this sampled point should be "above water" so we need to remove the distortion effect.

### Shallow Water Scattering
First we need to have a height map to tell us which part of the water is shallow. At first I simply exported the 8-bit height map from terrain in Unity and did some processing in Photoshop, but then I realized the precision is really low because we have only 4~5 height magnitude near the surface. Besides, after modifying the terrain we need to remake a texture again, which is annoying. So we can put a orthogonal camera above the terrain with culling mask only set to terrain, then pass the render texture to water shader.
The generated height map looks like this:

![](https://upload-images.jianshu.io/upload_images/16037344-6b7cef1e06853632.png)

Then we give additive light to shallow parts of the water:

![](https://upload-images.jianshu.io/upload_images/16037344-54c138a82547a96a.png)


### Fake Sub-surface Scattering
This part I referenced the following page:
[GDC 2011 – Approximating Translucency for a Fast, Cheap and Convincing Subsurface Scattering Look](https://colinbarrebrisebois.com/2011/03/07/gdc-2011-approximating-translucency-for-a-fast-cheap-and-convincing-subsurface-scattering-look/)
Simulating the sub-surface scattering makes our water "clear" and "transparent".
The basic calculating method can be explained by the following picture:

![](https://upload-images.jianshu.io/upload_images/16037344-0de1851e4b4d3911.png)

This simulate how light can "go through" the material then go into our eyes.
Before and after applying this effect, the water looks like:

![](https://upload-images.jianshu.io/upload_images/16037344-01765a924c87b529.png)


### Specular
Not much to talk about in this part. Simply used Phong specular.

### Fake Water Surface Shadow
This part basically talks about how to give correct surface color rather than simulate shadow. When water surface cannot receive the light from the sun, we should not add the sub-surface scattering to our final result. Or the result would look like this:
![](https://upload-images.jianshu.io/upload_images/16037344-1052e1b01743e816.png)
We can notice that the surface is very bright but, unnatural. But the water render queue is set to transparent, how can we get the surface shadow? Now we have to remove this effect by sampling a shadow render texture from another shader, with an invisible plane to receive the shadow.

![](https://upload-images.jianshu.io/upload_images/16037344-db0961767dcb3113.png)

And one more thing, we also need to fix the specular using similar technique.
Now we have the correct result:

![](https://upload-images.jianshu.io/upload_images/16037344-a67285d60556ca4e.png)

### Whitecap(not completed)
We use Jacobian determinant of the displacement XZ component to calculate how much "tearing" is happening at one specific point. The more "tearing" happens, the more foam and whitecap should appear. 
