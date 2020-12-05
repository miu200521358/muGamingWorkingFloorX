////////////////////////////////////////////////////////////////////////////////////////////////
//
//  WorkingFloorX.fx ver0.0.6  �I�t�X�N���[�������_���g�������ʋ����`�� & X�V���h�[�`��
//  �쐬: �j��P( ���͉��P����Mirror.fx, full.fx,���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

#define UseMirror  1    // X�e�݂̂ŏ��ʋ����`����g��Ȃ��ꍇ�͂�����0�ɂ���

#define XFileMirror  0  // �A�N�Z�T��(XFile)�����������鎞�͂�����1�ɂ���

#define FLG_EXCEPTION  0  // MMD�Ń��f������������ɕ`�悳��Ȃ��ꍇ�͂�����1�ɂ���


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////

// ���W�ϊ��s��
float4x4 WorldMatrix     : WORLD;
float4x4 ViewMatrix      : VIEW;
float4x4 ProjMatrix      : PROJECTION;
float4x4 ViewProjMatrix  : VIEWPROJECTION;

//�J�����ʒu
float3 CameraPosition : POSITION  < string Object = "Camera"; >;

// ���ߒl
float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;


#ifndef MIKUMIKUMOVING
    #if(FLG_EXCEPTION == 0)
        #define OFFSCREEN_FX_OBJECT  "WF_Object.fxsub"      // �I�t�X�N���[�������`��G�t�F�N�g
    #else
        #define OFFSCREEN_FX_OBJECT  "WF_ObjectExc.fxsub"   // �I�t�X�N���[�������`��G�t�F�N�g
    #endif
    #define ADD_HEIGHT   (0.05f)
    #define GET_VPMAT(p) (ViewProjMatrix)
#else
    #define OFFSCREEN_FX_OBJECT  "WF_Object_MMM.fxsub"  // �I�t�X�N���[�������`��G�t�F�N�g
    #define ADD_HEIGHT   (0.03f)
    #define GET_VPMAT(p) (MMM_IsDinamicProjection ? mul(ViewMatrix, MMM_DynamicFov(ProjMatrix, length(CameraPosition-p.xyz))) : ViewProjMatrix)
#endif


#if(UseMirror == 1)
// ���ʋ����`��̃I�t�X�N���[���o�b�t�@
texture WorkingFloorRT : OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for WorkingFloorX.fx";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = hide;"

        "*.pmd =" OFFSCREEN_FX_OBJECT ";"
        "*.pmx =" OFFSCREEN_FX_OBJECT ";"
        #if(XFileMirror == 1)
        "*.x=   " OFFSCREEN_FX_OBJECT ";"
        "*.vac =" OFFSCREEN_FX_OBJECT ";"
        #endif

        "* = hide;" ;
>;
sampler WorkingFloorView = sampler_state {
    texture = <WorkingFloorRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
#endif

// X�e�`��Ɏg���I�t�X�N���[���o�b�t�@
texture FloorXShadowRT : OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for XShadow of WorkingFloorX.fx";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1.0;
    bool AntiAlias = false;
    int MipLevels = 1;
    string Format = "D3DFMT_A8R8G8B8";
    string DefaultEffect = 
        "self = hide;"
        "*.pmd = WF_XShadow.fxsub;"
        "*.pmx = WF_XShadow.fxsub;"
        "*.x = hide;"
        "* = hide;" ;
>;
sampler XShadowSmp = sampler_state {
    texture = <FloorXShadowRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = float2(0.5f, 0.5f)/ViewportSize;

////////////////////////////////////////////////////////////////////////////////////////////////
// ���ʋ����`��

struct VS_OUTPUT {
    float4 Pos  : POSITION;
    float4 VPos : TEXCOORD1;
};

#if(UseMirror == 1)

// ���_�V�F�[�_
VS_OUTPUT VS_Mirror(float4 Pos : POSITION)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    Pos = mul( Pos, WorldMatrix );
    Pos.y += ADD_HEIGHT;  // ���Əd�Ȃ��Ă�����̂�������邽��

    // �J�������_�̃r���[�ˉe�ϊ�
    Pos = mul( Pos, GET_VPMAT(Pos) );

    Out.Pos = Pos;
    Out.VPos = Pos;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 PS_Mirror(VS_OUTPUT IN) : COLOR
{
    // �����̃X�N���[���̍��W(���E���]���Ă���̂Ō��ɖ߂�)
    float2 texCoord = float2( 1.0f - ( IN.VPos.x/IN.VPos.w + 1.0f ) * 0.5f,
                              1.0f - ( IN.VPos.y/IN.VPos.w + 1.0f ) * 0.5f ) + ViewportOffset;

    // �����̐F
    float4 Color = tex2D(WorkingFloorView, texCoord);
    Color.a *= AcsTr;

    return Color;
}

#endif

////////////////////////////////////////////////////////////////////////////////////////////////
// X�e�`��

// ���_�V�F�[�_
VS_OUTPUT VS_XShadow(float4 Pos : POSITION)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    Pos = mul( Pos, WorldMatrix );
    Pos.y += ADD_HEIGHT;  // ���Əd�Ȃ��Ă�����̂�������邽��

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, GET_VPMAT(Pos) );
    Out.VPos = mul( Pos, ViewProjMatrix );

    return Out;
}

// �s�N�Z���V�F�[�_
float4 PS_XShadow(VS_OUTPUT IN) : COLOR
{
    // X�e�̃X�N���[���̍��W
    float2 texCoord = float2( ( IN.VPos.x/IN.VPos.w + 1.0f ) * 0.5f,
                              1.0f - ( IN.VPos.y/IN.VPos.w + 1.0f ) * 0.5f ) + ViewportOffset;
    float4 Color = tex2D(XShadowSmp, texCoord);
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�e�N�j�b�N

technique MainTec{
    #if(UseMirror == 1)
    pass DrawObject{
        VertexShader = compile vs_2_0 VS_Mirror();
        PixelShader  = compile ps_2_0 PS_Mirror();
    }
    #endif
    pass DrawXShadow{
        VertexShader = compile vs_2_0 VS_XShadow();
        PixelShader  = compile ps_2_0 PS_XShadow();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////



