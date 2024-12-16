//������������������������������������������������������������������������������
 // �e�N�X�`�����T���v���[�f�[�^�̃O���[�o���ϐ���`
//������������������������������������������������������������������������������
Texture2D		g_texture : register(t0);	//�e�N�X�`���[
SamplerState	g_sampler : register(s0);	//�T���v���[

//������������������������������������������������������������������������������
// �R���X�^���g�o�b�t�@
// DirectX �����瑗�M����Ă���A�|���S�����_�ȊO�̏����̒�`
//������������������������������������������������������������������������������
cbuffer gModel : register(b0)
{
	float4x4	matWVP;			// ���[���h�E�r���[�E�v���W�F�N�V�����̍����s��
    float4x4    matW;			//���[���h�ϊ��}�g���N�X
	float4x4	matNormal;      // ���[���h�s��
	float4		diffuseColor;	//�}�e���A���̐F���g�U���ˌW��
    float2		factor;
    float4		ambientColor; //����
    float4		specularColor; //���ʔ���
    float4		shininess;
	bool		isTextured;			//�e�N�X�`���[���\���Ă��邩�ǂ���
};

cbuffer gStage : register(b1)
{
    float4 lightPosition;//�����x�N�g��
    float4 eyePosition;
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_�[�o�́��s�N�Z���V�F�[�_�[���̓f�[�^�\����
//������������������������������������������������������������������������������
struct VS_OUT
{
    float4 wpos : POSITION0; //�ʒu
	float4 pos  : SV_POSITION;	//�ʒu
	float2 uv	: TEXCOORD;		//UV���W
	float4 color	: COLOR;	//�F�i���邳�j
    float4 normal : NORMAL;
    float4 eyev : POSITION1;
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_
//������������������������������������������������������������������������������
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL)
{
	//�s�N�Z���V�F�[�_�[�֓n�����
	VS_OUT outData;

	//���[�J�����W�ɁA���[���h�E�r���[�E�v���W�F�N�V�����s���������
	//�X�N���[�����W�ɕϊ����A�s�N�Z���V�F�[�_�[��
    float4 wpos = mul(pos, matW); //���[���h���W�ɕϊ�
    outData.wpos = wpos;
	outData.pos = mul(pos, matWVP);
    outData.uv = uv.xy;

	normal = mul(normal , matNormal);
    float4 light = lightPosition;
	light = normalize(light);
	
    
	
	outData.color = clamp(dot(normal, light), 0, 1);
    outData.normal = normal;
    outData.eyev = eyePosition - wpos;
	//�܂Ƃ߂ďo��
	return outData;
}

//������������������������������������������������������������������������������
// �s�N�Z���V�F�[�_
//������������������������������������������������������������������������������
float4 PS(VS_OUT inData) : SV_Target
{
	float4 lightSource = float4(1.0, 1.0, 1.0, 1.0);
	float4 ambentSource = float4(0.0, 0.0, 0.0, 1.0);
	float4 diffuse;
	float4 ambient;
	
    float3 dir = normalize(lightPosition.xyz - inData.wpos.xyz); //�s�N�Z���ʒu�̃|���S����3�������W��wpos
    //inData.normal.z = 0;
    float color = saturate(dot(normalize(inData.normal.xyz), dir));
    float3 k = { 0.2f, 0.2f, 1.0f };
    float len = length(lightPosition.xyz - inData.wpos.xyz);
    float dTerm = 1.0 / (k.x + k.y * len + k.z * len * len);
    float4 R = reflect(normalize(inData.normal), normalize(float4(-dir, 0.0))); //�����˃x�N�g��
    float4 specular = pow(saturate(dot(R, normalize(inData.eyev))), shininess) * specularColor;
   
	if (isTextured == false)
	{
		diffuse = diffuseColor * inData.color * factor.x;
        ambient = diffuseColor * ambentSource * factor.x;
    }
	else
	{
        diffuse = g_texture.Sample(g_sampler, inData.uv) * inData.color * factor.x;
        ambient = g_texture.Sample(g_sampler, inData.uv) * ambentSource * factor.x;

    }
	//return g_texture.Sample(g_sampler, inData.uv);// (diffuse + ambient);]
	//float4 diffuse = lightSource * inData.color;
	//float4 ambient = lightSource * ambentSource;
	return diffuse + ambient;
}
//�X�y�L�����[�̕������v�Z�ɓ����