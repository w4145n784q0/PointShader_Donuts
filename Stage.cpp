#include "Stage.h"
#include "Engine/Model.h"
#include "Engine/Input.h"
#include "Engine/Camera.h"
#include "imgui/imgui.h"
#include "imgui/imgui_impl_dx11.h"
#include "imgui/imgui_impl_win32.h"



void Stage::InitConstantBuffer()
{
    D3D11_BUFFER_DESC cb;
    cb.ByteWidth = sizeof(CONSTBUFFER_STAGE);
    cb.Usage = D3D11_USAGE_DYNAMIC;
    cb.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
    cb.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
    cb.MiscFlags = 0;
    cb.StructureByteStride = 0;

    HRESULT hr;
    hr = Direct3D::pDevice_->CreateBuffer(&cb, nullptr, &pConstantBuffer_);
    if (FAILED(hr))
    {
        MessageBox(NULL, "コンスタントバッファの作成に失敗しました", "エラー", MB_OK);
    }
}

//コンストラクタ
Stage::Stage(GameObject* parent)
    :GameObject(parent, "Stage"),pConstantBuffer_(nullptr),pFbx_(nullptr)
{
    hModel_ = -1;
    hRoom_ = -1;
    hGround = -1;
    hBunny_ = -1;
    hDonuts_ = -1;
    hDonuts_lambert_notex = -1;
    hDonuts_lambert_tex = -1;
    hDonuts_phong_notex = -1;
    hDonuts_phong_tex = -1;
}

//デストラクタ
Stage::~Stage()
{
}

//初期化
void Stage::Initialize()
{
    hModel_ = Model::Load("Assets\\Ball.fbx");
    hRoom_ = Model::Load("Assets\\room.fbx");
    hGround = Model::Load("Assets\\plane3.fbx");
    hBunny_ = Model::Load("Assets\\stanford-bunny.fbx");

    hDonuts_ = Model::Load("Assets\\Donuts_phong_tex.fbx");
   
    hDonuts_lambert_notex = Model::Load("Assets\\Donuts_lambert_notex.fbx");
    hDonuts_lambert_tex = Model::Load("Assets\\Donuts_lambert_tex.fbx");
    hDonuts_phong_notex = Model::Load("Assets\\Donuts_phong_notex.fbx");
    hDonuts_phong_tex = Model::Load("Assets\\Donuts_phong_tex.fbx");

    Camera::SetPosition(XMFLOAT3{ 0, 0.8, -2.8 });
    Camera::SetTarget(XMFLOAT3{ 0,0.8,0 });

    InitConstantBuffer();
}

//更新
void Stage::Update()
{
    transform_.rotate_.y += 0.5f;
    if (Input::IsKey(DIK_A))
    {
        XMFLOAT4 p = Direct3D::GetLightPos();
        p = { p.x - 0.01f,p.y, p.z,p.w };
        Direct3D::SetLightPos(p);
    }
    if (Input::IsKey(DIK_D))
    {
        XMFLOAT4 p = Direct3D::GetLightPos();
        p = { p.x + 0.01f,p.y, p.z,p.w };
        Direct3D::SetLightPos(p);
    }
    if (Input::IsKey(DIK_W))
    {
        XMFLOAT4 p = Direct3D::GetLightPos();
        p = { p.x,p.y, p.z + 0.01f,p.w };
        Direct3D::SetLightPos(p);
    }
    if (Input::IsKey(DIK_S))
    {
        XMFLOAT4 p = Direct3D::GetLightPos();
        p = { p.x ,p.y, p.z - 0.01f,p.w };
        Direct3D::SetLightPos(p);
    }
    if (Input::IsKey(DIK_UP))
    {
        XMFLOAT4 p = Direct3D::GetLightPos();
        p = { p.x,p.y + 0.01f, p.z,p.w };
        Direct3D::SetLightPos(p);
    }
    if (Input::IsKey(DIK_DOWN))
    {
        XMFLOAT4 p = Direct3D::GetLightPos();
        p = { p.x ,p.y - 0.01f, p.z,p.w };
        Direct3D::SetLightPos(p);
    }

    

    //コンスタントバッファの設定とシェーダへのコンスタントバッファのセットを書く
    CONSTBUFFER_STAGE cb;
    cb.lightPosition = Direct3D::GetLightPos();
    XMStoreFloat4(&cb.eyePosition, Camera::GetPosition());

    D3D11_MAPPED_SUBRESOURCE pdata;
    Direct3D::pContext_->Map(pConstantBuffer_, 0, D3D11_MAP_WRITE_DISCARD, 0, &pdata);	// GPUからのデータアクセスを止める
    memcpy_s(pdata.pData, pdata.RowPitch, (void*)(&cb), sizeof(cb));	// データを値を送る
    Direct3D::pContext_->Unmap(pConstantBuffer_, 0);	//再開

    //コンスタントバッファ
    Direct3D::pContext_->VSSetConstantBuffers(1, 1, &pConstantBuffer_);	//頂点シェーダー用	
    Direct3D::pContext_->PSSetConstantBuffers(1, 1, &pConstantBuffer_);	//ピクセルシェーダー用

}

//描画
void Stage::Draw()
{

    Transform ltr;
    ltr.position_ = { Direct3D::GetLightPos().x,Direct3D::GetLightPos().y,Direct3D::GetLightPos().z };
    ltr.scale_ = { 0.1,0.1,0.1 };
    Model::SetTransform(hModel_, ltr);
    Model::Draw(hModel_);


    Transform tr;
    tr.position_ = { 0, 0, 0 };
    //tr.scale_ = { 5.0f, 5.0f, 5.0f };
    tr.rotate_ = { 0,0,0 };
    //Model::SetTransform(hGround, tr);
    //Model::Draw(hGround);

    Model::SetTransform(hRoom_, tr);
    Model::Draw(hRoom_);

    /*static Transform tbunny;
    tbunny.scale_ = { 1,1,1 };
    tbunny.position_ = { 0,0.0,0 };
    tbunny.rotate_.y += 0.1;
    Model::SetTransform(hBunny_, tbunny);
    Model::Draw(hBunny_);*/

    static Transform tdonuts;
    tdonuts.scale_ = { 0.2,0.2,0.2 };
    tdonuts.position_ = { 0.5,0.3,0 };
    tdonuts.rotate_.y += 0.1;

    static Transform tdonuts2;
    tdonuts2.scale_ = { 0.2,0.2,0.2 };
    tdonuts2.position_ = { -0.5,0.3,0 };
    tdonuts2.rotate_.y += 0.1;

    static Transform tdonuts3;
    tdonuts3.scale_ = { 0.2,0.2,0.2 };
    tdonuts3.position_ = { 0.5,1.0,0 };
    tdonuts3.rotate_.y += 0.1;

    static Transform tdonuts4;
    tdonuts4.scale_ = { 0.2,0.2,0.2 };
    tdonuts4.position_ = { -0.5,1.0,0 };
    tdonuts4.rotate_.y += 0.1;

   /* Model::SetTransform(hDonuts_, tdonuts);
    Model::Draw(hDonuts_);*/

    Model::SetTransform(hDonuts_lambert_notex, tdonuts);
    Model::Draw(hDonuts_lambert_notex);

    Model::SetTransform(hDonuts_lambert_tex, tdonuts2);
    Model::Draw(hDonuts_lambert_tex);

    Model::SetTransform(hDonuts_phong_notex, tdonuts3);
    Model::Draw(hDonuts_phong_notex);

    Model::SetTransform(hDonuts_phong_tex, tdonuts4);
    Model::Draw(hDonuts_phong_tex);

    ImGui::Text("Rotate:%.3f", tdonuts.rotate_.y);

}

//開放
void Stage::Release()
{
}