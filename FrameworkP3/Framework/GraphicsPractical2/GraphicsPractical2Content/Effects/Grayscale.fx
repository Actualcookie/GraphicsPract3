//The texture which the shader will change
texture ScreenTexture;


sampler TextureSampler = sampler_state
{
	Texture = <ScreenTexture>;
};

float4 PixelShaderGray(float2 TextureCoordinate : TEXCOORD0) : COLOR0
{

	float4 color = tex2D(TextureSampler, TextureCoordinate);

	//calculate the weighted sum of the colors of a pixel
	float sum = (color.r*0.3 + color.g*0.59 + color.b*0.11);

	//set the rgb values to the value of the sum, creating a grey color
	color.r = sum;
	color.g = sum;
	color.b = sum;
	return color;
}

technique Simple
{
	pass Pass1
	{
		PixelShader = compile ps_2_0 PixelShaderGray();
	}
}