/*

Many thanks to http://www.brucelindbloom.com/

Very basic effect to test the CIE LAB color space.

*/

//#region Includes

#include "ReShade.fxh"
#include "ReShadeUI.fxh"
#include "ColorLab.fxh"

//#endregion

namespace FXShaders
{

//#region Uniforms

static const float3 limits = float3(116.0, 500, 200);
static const float3 invLimits = 1 / limits;

uniform float3 Multiplier
<
	__UNIFORM_DRAG_FLOAT3

	ui_tooltip =
		"Generic multiplier to each component of the L*a*b color space.\n"
		"\nDefault: 1.0 1.0 1.0";
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 2.0;
	ui_step = 0.01;
> = 1.0;

uniform float3 Gamma
<
	__UNIFORM_DRAG_FLOAT3

	ui_tooltip =
		"Curvature of each component of L*a*b color space.\n"
		"\nDefault: 1.0 1.0 1.0";
	ui_type = "drag";
	ui_min = 0.1;
	ui_max = 4.0;
	ui_step = 0.01;
> = 1.0;

uniform float3 LimitsCoeff
<
	__UNIFORM_DRAG_FLOAT3

	ui_tooltip =
		"Modify the limits for the curvature. Coeff of 1 is the entire range";
	ui_type = "drag";
	ui_min = 0.1;
	ui_max = 10.0;
	ui_step = 0.01;
> = 1.0;

uniform float3 Offset
<
	__UNIFORM_DRAG_FLOAT3

	ui_tooltip =
		"Generic multiplier to each component of the L*a*b color space.\n"
		"\nDefault: 1.0 1.0 1.0";
	ui_type = "drag";
	ui_min = -1;
	ui_max = 1;
	ui_step = 0.01;
> = 0.0;

//#endregion

sampler BackBuffer
{
	Texture = ReShade::BackBufferTex;
	SRGBTexture = true;
	MinFilter = POINT;
	MagFilter = POINT;
	MipFilter = POINT;
};

float4 MainPS(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
	float4 color = tex2D(BackBuffer, uv);
	color.xyz = ColorLab::rgb_to_lab(color.rgb);

	color.xyz = pow(abs(color.xyz * invLimits / LimitsCoeff), Gamma) * sign(color.xyz) * limits * LimitsCoeff;
	color.xyz *= Multiplier;
	color.xyz += Offset * limits * 0.5;

	color.rgb = ColorLab::lab_to_rgb(color.xyz);
	return color;
}

technique ColorLab_2
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MainPS;
		SRGBWriteEnable = true;
	}
}

}
