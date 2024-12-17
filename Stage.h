#pragma once
#include "Engine/GameObject.h"
#include "Engine/Fbx.h"


struct CONSTBUFFER_STAGE
{
    XMFLOAT4 lightPosition;//光源位置
    XMFLOAT4 eyePosition;//視点の位置
};

//◆◆◆を管理するクラス
class Stage : public GameObject
{
    int hModel_;    //モデル番号
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
    //コンストラクタ
    Stage(GameObject* parent);

    //デストラクタ
    ~Stage();

    //初期化
    void Initialize() override;

    //更新
    void Update() override;

    //描画
    void Draw() override;

    //開放
    void Release() override;
};