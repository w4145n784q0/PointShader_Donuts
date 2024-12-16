//───────────────────────────────────────
 // テクスチャ＆サンプラーデータのグローバル変数定義
//───────────────────────────────────────
Texture2D		g_texture : register(t0);	//テクスチャー
SamplerState	g_sampler : register(s0);	//サンプラー

//───────────────────────────────────────
// コンスタントバッファ
// DirectX 側から送信されてくる、ポリゴン頂点以外の諸情報の定義
//───────────────────────────────────────
cbuffer gModel : register(b0)
{
	float4x4	matWVP;			// ワールド・ビュー・プロジェクションの合成行列
    float4x4    matW;			//ワールド変換マトリクス
	float4x4	matNormal;      // ワールド行列
	float4		diffuseColor;	//マテリアルの色＝拡散反射係数
    float2		factor;
    float4		ambientColor; //環境光
    float4		specularColor; //鏡面反射
    float4		shininess;
	bool		isTextured;			//テクスチャーが貼られているかどうか
};

cbuffer gStage : register(b1)
{
    float4 lightPosition;//光源ベクトル
    float4 eyePosition;
};

//───────────────────────────────────────
// 頂点シェーダー出力＆ピクセルシェーダー入力データ構造体
//───────────────────────────────────────
struct VS_OUT
{
    float4 wpos : POSITION0; //位置
	float4 pos  : SV_POSITION;	//位置
	float2 uv	: TEXCOORD;		//UV座標
	float4 color	: COLOR;	//色（明るさ）
    float4 normal : NORMAL;
    float4 eyev : POSITION1;
};

//───────────────────────────────────────
// 頂点シェーダ
//───────────────────────────────────────
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL)
{
	//ピクセルシェーダーへ渡す情報
	VS_OUT outData;

	//ローカル座標に、ワールド・ビュー・プロジェクション行列をかけて
	//スクリーン座標に変換し、ピクセルシェーダーへ
    float4 wpos = mul(pos, matW); //ワールド座標に変換
    outData.wpos = wpos;
	outData.pos = mul(pos, matWVP);
    outData.uv = uv.xy;

	normal = mul(normal , matNormal);
    float4 light = lightPosition;
	light = normalize(light);
	
    
	
	outData.color = clamp(dot(normal, light), 0, 1);
    outData.normal = normal;
    outData.eyev = eyePosition - wpos;
	//まとめて出力
	return outData;
}

//───────────────────────────────────────
// ピクセルシェーダ
//───────────────────────────────────────
float4 PS(VS_OUT inData) : SV_Target
{
	float4 lightSource = float4(1.0, 1.0, 1.0, 1.0);
	float4 ambentSource = float4(0.0, 0.0, 0.0, 1.0);
	float4 diffuse;
	float4 ambient;
	
    float3 dir = normalize(lightPosition.xyz - inData.wpos.xyz); //ピクセル位置のポリゴンの3次元座標＝wpos
    //inData.normal.z = 0;
    float color = saturate(dot(normalize(inData.normal.xyz), dir));
    float3 k = { 0.2f, 0.2f, 1.0f };
    float len = length(lightPosition.xyz - inData.wpos.xyz);
    float dTerm = 1.0 / (k.x + k.y * len + k.z * len * len);
    float4 R = reflect(normalize(inData.normal), normalize(float4(-dir, 0.0))); //正反射ベクトル
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
//スペキュラーの部分も計算に入れる