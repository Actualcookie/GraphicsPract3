//------------------------------------------- Defines -------------------------------------------

#define MAXLIGHTS 4
//------------------------------------- Top Level Variables -------------------------------------

// Top level variables can and have to be set at runtime
// Top level variables for Lambertian shading

float3 LightDirection;
float4 DiffuseColor;
float DiffuseStrength = 0.1;
//Variables Specular
float SpecularPower;
float SpecularIntensity;
float4 SpecularColor;
float4 lightPosition[MAXLIGHTS];

//Variables for Lambertian shading + Ambient colors
float4 AmbientColor;
float AmbientIntensity;
// Matrices for 3D perspective projection 
float4x4 View, Projection, World, ITWorld;

struct VertexInputType
{
	float4 position : POSITION;
	float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
};