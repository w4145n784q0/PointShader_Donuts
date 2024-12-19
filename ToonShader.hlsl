//������������������������������������������������������������������������������
 // �e�N�X�`�����T���v���[�f�[�^�̃O���[�o���ϐ���`
//������������������������������������������������������������������������������
Texture2D g_texture : register(t0); //�e�N�X�`���[
SamplerState g_sampler : register(s0); //�T���v���[

//������������������������������������������������������������������������������
// �R���X�^���g�o�b�t�@
// DirectX �����瑗�M����Ă���A�|���S�����_�ȊO�̏����̒�`
//������������������������������������������������������������������������������
cbuffer gModel : register(b0)
{
    float4x4 matWVP; // ���[���h�E�r���[�E�v���W�F�N�V�����̍����s��
    float4x4 matW; //���[���h�ɕϊ�����}�g���N�X�i�X�P�[���͂����Ȃ��j���[�J�����W��ϊ�����
    float4x4 matNormal; // ���[���h�ϊ��p�̍s��@�@����ϊ�����
    float4 diffuseColor; //�}�e���A���̐F���g�U���ˌW��
    float2 factor; //�g�U���̔��ˌW��
    float4 ambientColor; //�����i�g��Ȃ��j
    float4 specularColor; //���ʔ��ˁi�g��Ȃ��j
    float4 shininess; //�i�g��Ȃ��j
    bool isTextured; //�e�N�X�`���[���\���Ă��邩�ǂ���
};


cbuffer gStage : register(b1)
{
    float4 lightPosition; //�����x�N�g��
    float4 eyePosition;
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_�[�o�́��s�N�Z���V�F�[�_�[���̓f�[�^�\����
//������������������������������������������������������������������������������
struct VS_OUT
{
    //float4 wpos : POSITION0; //�ʒu(���[���h)
    float4 pos : SV_POSITION; //�ʒu(���[�J��)
    float2 uv : TEXCOORD; //UV���W
    float4 color : COLOR; //�F�i���邳�j
    float4 normal : NORMAL;
   // float4 eyev : POSITION1;
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
    outData.pos = mul(pos, matWVP);
	
	//uv�͂��̂܂�
    outData.uv = uv;

	//�@���x�N�g���Ƀ��[���h�s���������
    normal = mul(normal, matNormal);
	
	//�����x�N�g���𐳋K��
    float4 light = lightPosition;
    light = normalize(light);
	
	//�����x�N�g���Ɩ@���̓��ς��Ƃ���0~1.0�łƂ�
    outData.color = clamp(dot(normal, light), 0, 1);

    //float4 OutColor;
    //if (outData.color < 1.0f / 4)
    //{
    //    OutColor = float4(0 / 3.0f, 0 / 3.0f, 0 / 3.0f, 1.0f);

    //}
    //else if (outData.color < 2.0f / 4)
    //{
    //    OutColor = float4(1 / 3.0f, 1 / 3.0f, 1 / 3.0f, 1.0f);
    //}
    //else if (outData.color < 3.0f / 4)
    //{
    //    OutColor = float4(2 / 3.0f, 2 / 3.0f, 2 / 3.0f, 1.0f);
    //}
    //else
    //{
    //    OutColor = float4(3 / 3.0f, 3 / 3.0f, 3 / 3.0f, 1.0f);
    //}
    //outData.color = OutColor;
	
	//�܂Ƃ߂ďo��
    return outData;
}

//������������������������������������������������������������������������������
// �s�N�Z���V�F�[�_
//������������������������������������������������������������������������������
float4 PS(VS_OUT inData) : SV_Target
{
    float4 lightSource = float4(1.0, 1.0, 1.0, 1.0);
    float4 ambentSource = float4(0.2 ,0.2, 0.2, 1.0);
    float4 diffuse;
    float4 ambient;
	
    float4 NL = saturate(dot(inData.normal, normalize(lightPosition)));
    float4 n1 = float4(1 / 4.0, 1 / 4.0, 1 / 4.0, 1.0);
    float4 n2 = float4(2 / 4.0, 2 / 4.0, 2 / 4.0, 1.0);
    float4 n3 = float4(3 / 4.0, 3 / 4.0, 3 / 4.0, 1.0);
    float4 n4 = float4(4 / 4.0, 4 / 4.0, 4 / 4.0, 1.0);
    
    float4 tI = 0.1 * step(n1, inData.color) + 0.3 * 
    step(n2, inData.color) + 0.3 * step(n3, inData.color) /*+ 0.6 * step(n4, NL)*/;
    
    //float4 OutColor;
    //if (NL.x < 1.0f / 4)
    //{
    //    OutColor = float4(0 / 3.0f, 0 / 3.0f, 0 / 3.0f, 1.0f);

    //}
    //else if (NL.x < 2.0f / 4)
    //{
    //    OutColor = float4(1 / 3.0f, 1 / 3.0f, 1 / 3.0f, 1.0f);
    //}
    //else if (NL.x < 3.0f / 4)
    //{
    //    OutColor = float4(2 / 3.0f, 2 / 3.0f, 2 / 3.0f, 1.0f);
    //}
    //else
    //{
    //    OutColor = float4(3 / 3.0f, 3 / 3.0f, 3 / 3.0f, 1.0f);
    //}
    
    //inData.color = OutColor;
    
    if (isTextured == false)
    {
        diffuse = diffuseColor * tI * factor.x;
        ambient = diffuseColor * ambentSource ;
    }
    else
    {
        diffuse = g_texture.Sample(g_sampler, inData.uv) * tI * factor.x;
        ambient = g_texture.Sample(g_sampler, inData.uv) * ambentSource ;
    }
    return diffuse + ambient;
}