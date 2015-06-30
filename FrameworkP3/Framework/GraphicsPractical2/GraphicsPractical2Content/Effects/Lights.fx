#define MAX_LIGHTS 5

float4x4 World;
float4x4 View;
float4x4 Projection;
float4x4 ITWorld;
//array of light positions
float4 lightPosition[MAX_LIGHTS];
float4 diffuseColors[MAX_LIGHTS];


struct VertexShaderInput
{
    float4 Position : POSITION0;
	float3 Normals : NORMAL0;

};

struct VertexShaderOutput
{
    float4 Position : POSITION0;
	float3 normal : TEXCOORD0;
	float4 PositionT : TEXCOORD1;
};

VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
    VertexShaderOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);

	output.normal =  normalize(mul(input.Normals, (float3x3)ITWorld));
	//gives the lightpositions to the pixelshader from the array
	output.PositionT = mul(viewPosition, Projection);

    return output;
}
//-------------------------------------------Functions-------------------------------------------------------------------------------
float4 ColorFixing(VertexShaderOutput input)
{ 
	float4 color = (1, 0, 0, 1);
		for (int i = 0; i < MAX_LIGHTS; i++)
		{

		float3 normLightVector = (float3)lightPosition[i] - (float3)input.PositionT;
		float3 worldNormals = normalize(mul((float3)input.normal, (float3x3)ITWorld));
		float a = dot(normLightVector, worldNormals);
		float4 color0 = diffuseColors[i] * a;
			color = color0 + color;
		}
	return color;
}


//-----------------------------------------------------------------------------------------------------------------------------------
float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0
{
	float4 color = ColorFixing(input);
	return color;

}

technique Simple
{
    pass Pass1
    {
        

        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
