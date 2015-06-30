//------------------------------------------- Defines -------------------------------------------

#define Pi 3.14159265
//------------------------------------- Top Level Variables -------------------------------------

// Top level variables can and have to be set at runtime
// Top level variables for Lambertian shading

float3 LightDirection;
float3 LightPosition;
float4 DiffuseColor;
float DiffuseStrength = 0.1;
//Variables Specular
float SpecularPower;
float SpecularIntensity;
float4 SpecularColor;

//Variables for Lambertian shading + Ambient colors
float4 AmbientColor;
float AmbientIntensity;
// Matrices for 3D perspective projection 
float4x4 View, Projection, World, ITWorld;
float4 Color;
//---------------------------------- Input / Output structures ----------------------------------


struct VertexShaderInput
{
	float4 Position3D : POSITION0;
	float4 Normal : NORMAL0;
	float4 Color : COLOR0;
};

struct VertexShaderOutput
{
	float3 LightDirect : TEXCOORD0; // Direction of the light
	float3 Normal : TEXCOORD1; // Direction of the normal of a vertex
	float3 eye : TEXCOORD2; // view vector of camera
	float4 Position : POSITION0;
	
};


//---------------------------------------- Technique: Simple ----------------------------------------

VertexShaderOutput SimpleVertexShader(VertexShaderInput input)
{
	// Allocate an  output struct
	VertexShaderOutput output;

	// Do the matrix multiplications for perspective projection and the world transform
	float4 worldPosition = mul(input.Position3D, World);
	float4 viewPosition = mul(worldPosition, View);
	output.Position = mul(viewPosition, Projection);

	
	float3 LDirection = LightPosition - viewPosition; //Calculate the direction of a ray coming out of the point light
	output.LightDirect = LDirection;

	float4 LNormal = mul((input.Normal), (ITWorld));		   // multiply the normal with the Inverse Transposed World matrix, so that normals rotate with the model
	output.Normal = LNormal;

	output.eye = -viewPosition;
				 
	return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	//The angles used for the soft edge of the spotlight. 
	float  outerConeAngle = 0.7;
	float  innerConeAngle = 0.8;
	float  difference = 0.1; //outerConeAngle - innerConeAngle

	float4 finColor = (AmbientColor * AmbientIntensity);

		float3 normal = normalize(input.Normal); //normalize the vertex normal
		float3 light = normalize(input.LightDirect); // normalize light  direction
		float3 spotDirection = normalize(LightDirection); //The direction of the spotlight

	if (dot(-light, spotDirection) > innerConeAngle) // If the lightray is within the inner cone, calculate light normally
	{
		float lambert = dot(normal, light); //dot product between normal and light

		if (lambert > 0){
			finColor += DiffuseStrength * DiffuseColor * lambert; // add lambert product to the final color

			float3 Eye = normalize(input.eye);
			float3 R = reflect(-light, normal);

				float specular = pow(max(dot(R, Eye), 0.001), SpecularIntensity); // add specular highlight

			finColor += SpecularColor*specular;
		}
	}

	else if (dot(-light, spotDirection) > outerConeAngle) // if inside the edge area of the spotlight
	{
		float falloff = (dot(-light, spotDirection) - outerConeAngle) / difference; // calculate how much less light a pixel receives
		float lambert = dot(normal, light);

		if (lambert > 0)
		{
			finColor += DiffuseStrength * DiffuseColor * lambert * falloff;

			float3 Eye = normalize(input.eye);
				float3 R = reflect(-light, normal);

				float specular = pow(max(dot(R, Eye), 0.001), SpecularIntensity);

			finColor += SpecularColor*specular*falloff;
		}

	} 

		return saturate(finColor);

}
technique Simple
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 SimpleVertexShader();
		PixelShader  = compile ps_2_0 SimplePixelShader();
	}
}