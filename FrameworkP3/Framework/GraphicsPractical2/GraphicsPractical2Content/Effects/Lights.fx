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
	float3 lightPos1 : TEXCOORD1;
	float3 lightPos2 : TEXCOORD2;
	float3 lightPos3 : TEXCOORD3;
	float3 lightPos4 : TEXCOORD4;
	float3 lightPos5 : TEXCOORD5;
};

VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
    VertexShaderOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);

	output.normal =  normalize(mul(input.Normals, (float3x3)ITWorld));
	//gives the lightpositions to the pixelshader from the array
	output.lightPos1.xyz = normalize(lightPosition[0].xyz - worldPosition.xyz);
	output.lightPos2.xyz = normalize(lightPosition[1].xyz - worldPosition.xyz);
	output.lightPos3.xyz = normalize(lightPosition[2].xyz - worldPosition.xyz);
	output.lightPos4.xyz = normalize(lightPosition[3].xyz - worldPosition.xyz);
	output.lightPos5.xyz = normalize(lightPosition[4].xyz - worldPosition.xyz);

    return output;
}

float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0
{
	float lightIntensity1, lightIntensity2, lightIntensity3, lightIntensity4, lightIntensity5;
	float4 color0, color1, color2, color3, color4, color;
	//sets all the lights at the right intensity
	lightIntensity1 = saturate(dot(input.normal, input.lightPos1));
	lightIntensity2 = saturate(dot(input.normal, input.lightPos2));
	lightIntensity3 = saturate(dot(input.normal, input.lightPos3));
	lightIntensity4 = saturate(dot(input.normal, input.lightPos4));
	lightIntensity5 = saturate(dot(input.normal, input.lightPos5));
	//sets all the colors with the right lights
	/*
	for(int i= 0; i<MAX_LIGHTS;i++) 
	*/
	color0 = diffuseColors[0] * lightIntensity1;
	color1 = diffuseColors[1] * lightIntensity2;
	color2 = diffuseColors[2] * lightIntensity3;
	color3 = diffuseColors[3] * lightIntensity4;
	color4 = diffuseColors[4] * lightIntensity5;
	//calculate the total light
	color = saturate(color1 + color2 + color3 + color4 + color0);
	//return the color
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
