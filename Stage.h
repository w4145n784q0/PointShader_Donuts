#pragma once
#include "Engine/GameObject.h"
#include "Engine/Fbx.h"


struct CONSTBUFFER_STAGE
{
    XMFLOAT4 lightPosition;//�����ʒu
    XMFLOAT4 eyePosition;//���_�̈ʒu
};

//���������Ǘ�����N���X
class Stage : public GameObject
{
    int hModel_;    //���f���ԍ�
    int hRoom_;
    int hGround;
    int hBunny_;
    int hDonuts_;

    int hDonuts_lambert_notex;
    int hDonuts_lambert_tex;
    int hDonuts_phong_notex;
    int hDonuts_phong_tex;

    int arr[4] = { hDonuts_lambert_notex , hDonuts_lambert_tex , hDonuts_phong_notex , hDonuts_phong_tex };
  

    ID3D11Buffer* pConstantBuffer_;
    void InitConstantBuffer();
    Fbx* pFbx_;
public:
    //�R���X�g���N�^
    Stage(GameObject* parent);

    //�f�X�g���N�^
    ~Stage();

    //������
    void Initialize() override;

    //�X�V
    void Update() override;

    //�`��
    void Draw() override;

    //�J��
    void Release() override;
};