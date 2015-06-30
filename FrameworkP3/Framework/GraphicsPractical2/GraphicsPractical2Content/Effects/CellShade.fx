//------------------------------------------- Defines -------------------------------------------

#define Pi 3.14159265
//------------------------------------- Top Level Variables -------------------------------------


float3 LightDirection;
float4 DiffuseColor;
float DiffuseStrength = 0.2;
//Variables Specular

float4 AmbientColor;
float AmbientIntensity;
// Matrices for 3D perspective projection 
float4x4 View, Projection, World, ITWorld;
//---------------------------------- Input / Output structures ----------------------------------


struct VertexShaderInput
{
	float4 Position3D : POSITION0;
	float4 Normal : NORMAL0;
	float4 Color : COLOR0;
};


struct VertexShaderOutput
{
	float4 Position2D : POSITION0;
	float Intense : TEXCOORD0;
	float4 Color : COLOR0;
};

//------------------------------------------ Functions ------------------------------------------
float4 Discretization(VertexShaderOutput output)
{
	float4 color;

		if (output.Intense*10 > 0.9)
			color = float4(1.0, 1, 1, 1.0)*output.Color;
		else if (output.Intense*10 > 0.3)
			color = float4(0.7, 0.7, 0.7, 1.0)*output.Color;
		else if (output.Intense*10 > 0.01)
			color = float4(0.35, 0.35, 0.35, 1.0)*output.Color;
		else
			color = float4(0.1, 0.1, 0.1, 1.0)*output.Color;
		return color;
}



//---------------------------------------- Technique: Simple ----------------------------------------

VertexShaderOutput SimpleVertexShader(VertexShaderInput input)
{
	// Allocate an  output struct
	VertexShaderOutput output;
	// Do the matrix multiplications for perspective projection and the world transform
	float4 worldPosition = mul(input.Position3D, World);
    float4 viewPosition  = mul(worldPosition, View);
	output.Position2D    = mul(viewPosition, Projection);
	
	float4 Lnormal = normalize(mul(input.Normal, ITWorld));		   // multiply the normal with the Inverse Transposed World matrix, so that normals rotate with the teapot

	float lightStrength = dot(Lnormal, LightDirection);					   //calculate how much light gets reflected.
	output.Intense = lightStrength;									//setting the Lightstrength to the pixelshader to ease the discretization	
	//with a set color 
	output.Color = AmbientColor; 
	return output;
}

float4 SimplePixelShader(VertexShaderOutput output) : COLOR0
{
	//discretization
	float4 color = Discretization(output);
	//returns the correct color for every part
		return color;
}

technique Cell
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 SimpleVertexShader();
		PixelShader  = compile ps_2_0 SimplePixelShader();
	}
}