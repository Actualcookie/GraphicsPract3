//------------------------------------------- Defines -------------------------------------------

#define Pi 3.14159265
//------------------------------------- Top Level Variables -------------------------------------


float3 LightDirection;
float4 DiffuseColor;
float DiffuseStrength = 0.1;
//Variables Specular
float SpecularPower;
float SpecularIntensity;
float4 SpecularColor;

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
	float Intense : TEXCOORD2;
	float3 TNormal : TEXCOORD1;
	float4 Color : COLOR0;
};

//------------------------------------------ Functions ------------------------------------------
float4 Discretization(VertexShaderOutput output)
{
	float4 color = output.Color;
		
		if (output.Intense > 0.95)
			color = (float4(1.0, 1, 1, 1.0) + output.Color);
		else if (output.Intense > 0.5)
			color = (float4(0.7, 0.7, 0.7, 1.0) + output.Color);
		else if (output.Intense > 0.05)
			color = (float4(0.35, 0.35, 0.35, 1.0) + output.Color);
		else
			color = (float4(0.1, 0.1, 0.1, 1.0) + output.Color);
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

	output.TNormal = input.Normal;
	
	float4 Lnormal = normalize(mul(input.Normal,ITWorld));		   // multiply the normal with the Inverse Transposed World matrix, so that normals rotate with the teapot
	float lightStrength = dot(Lnormal, (LightDirection));					   //calculate how much light gets reflected.
	output.Intense = lightStrength;									//setting the Lightstrength to the pixelshader to ease the discretization

	output.Color = saturate(DiffuseColor * DiffuseStrength*3 * ightStrength); // return the color. Our teapot was very dark, so we multiply by 3 to make the differences clearer
	return output;
}

float4 SimplePixelShader(VertexShaderOutput output) : COLOR0
{
	//discretization
	float4 color = Discretization(output);

	float3 light = (LightDirection);
	float3 normal = normalize(output.TNormal);
	float3 r = normalize(2 * dot(light, normal) * normal - light);
	float3 v = normalize(mul(normalize(View), ITWorld));

	float product = dot(r, v);
	float4 Shiny = SpecularIntensity * SpecularColor * max(pow(abs(product), SpecularPower), 0) * length(output.Color);
		return saturate(color);
}

technique Simple
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 SimpleVertexShader();
		PixelShader  = compile ps_2_0 SimplePixelShader();
	}
}