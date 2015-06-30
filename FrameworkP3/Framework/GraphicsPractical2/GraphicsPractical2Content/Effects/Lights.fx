#define MAX_LIGHTS 5

float4x4 World;
float4x4 View;
float4x4 Projection;
float4x4 ITWorld;
//array of light positions
float4 lightPosition[MAX_LIGHTS];
//all colors for said lights
float4 diffuseColors[MAX_LIGHTS];
//Red
float4 DiffuseColor;



struct VertexShaderInput
{
    float4 Position : POSITION0;
	float3 Normals : NORMAL0;
	float4 Color : COLOR0;

};

struct VertexShaderOutput
{
    float4 Position : POSITION0;
	float3 normal : TEXCOORD0;
	float4 PositionT : TEXCOORD1;
	float4 Color : COLOR0;
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
	output.Color = DiffuseColor;
    return output;
}
//-------------------------------------------Functions-------------------------------------------------------------------------------
float4 ColorFixing(VertexShaderOutput input)
{ 
	//set a standard color
	float4 color = (0, 0, 0, 1);
		//makes the array variable in size Tho not any bigger than 7 or 8 because that would mean overriding the max possible calculations
		for (int i = 0; i < MAX_LIGHTS; i++)
		{
		//normal calculations
		float3 normLightVector = normalize((float3)lightPosition[i] - (float3)input.PositionT);
		float3 worldNormals = normalize(mul((float3)input.normal, (float3x3)ITWorld));
		float a = dot(normLightVector, worldNormals);
		//light strenght times the calculation
		float4 color0 = diffuseColors[i] * a;
		//getting that color
	    color = color0 + color;
		}
	return color;
}


//-----------------------------------------------------------------------------------------------------------------------------------
float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0
{
	float4 color = ColorFixing(input);
	return (color*input.Color);

}

technique Simple
{
    pass Pass1
    {
        

        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
