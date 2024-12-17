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
    float4x4	matW;			//ワールドに変換するマトリクス（スケールはかけない）ローカル座標を変換する
	float4x4	matNormal;      // ワールド変換用の行列　法線を変換する
	float4		diffuseColor;	//マテリアルの色＝拡散反射係数
    float2		factor;			//拡散光の反射係数
    float4		ambientColor;   //環境光（使わない）
    float4		specularColor;  //鏡面反射（使わない）
    float4		shininess;		//（使わない）
	bool		isTextured;		//テクスチャーが貼られているかどうか
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
    //float4 wpos : POSITION0; //位置(ワールド)
	float4 pos  : SV_POSITION;	//位置(ローカル)
	float2 uv	: TEXCOORD;		//UV座標
	float4 color	: COLOR;	//色（明るさ）
    float4 normal : NORMAL;     //法線の情報
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
	outData.pos = mul(pos, matWVP);
	
	//uvはそのまま
    outData.uv = uv;

	//法線ベクトルにワールド行列をかける
	//頂点間の色は補完してくれる
	normal = mul(normal , matNormal);
    outData.normal = normal;
	
	//光源ベクトルを正規化
    float4 light = lightPosition;
	light = normalize(light);
	
	//光源ベクトルと法線の内積をとって-1.0~1.0でとる
	outData.color = clamp(dot(normal, light), 0, 1);
    //outData.normal = normal;
	
	//まとめて出力
	return outData;
}

//───────────────────────────────────────
// ピクセルシェーダ
//───────────────────────────────────────
float4 PS(VS_OUT inData) : SV_Target
{
	float4 lightSource = float4(1.0, 1.0, 1.0, 1.0);
    float4 ambentSource = float4(0.5, 0.5, 0.5, 1.0);
	float4 diffuse;
	float4 ambient;
	
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
	return diffuse + ambient;
}