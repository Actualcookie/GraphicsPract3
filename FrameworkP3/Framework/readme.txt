Lars Bruggeman	4279395
Tim Schut		4255410

gebruikte references Tim:
http://www.gamedev.net/topic/545762-pixel-shader-spotlight-with-hlsl/
http://rbwhitaker.wikidot.com/toon-shader
http://www.rastertek.com/dx11tut30.html
Implementations Tim:
I implemented multiple lights and the Cell Shader which did not go completely according to plan.
For the multiple lights I made a method that automatically fills both arrays (light colors and lightpositions) with random values so I could do sanity checks quicker they are slightly bright,
but for that reason you can uncomment a hard coded array that shows that the system works with slightly ever so slightly less bright pixels aswell. 
The CellShader puts each pixel in a group of 3 either dark medium or light (based on the intensity of each pixel) this way the Pixel shader gives a clear edge where 
the lines seperate. 
