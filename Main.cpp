//�C���N���[�h
#include <Windows.h>
#include <stdlib.h>
#include "Engine/Direct3D.h"
#include "Engine/Camera.h"
#include "Engine/Input.h"
#include "Engine/RootJob.h"
#include "Engine/Model.h"
#include "imgui/imgui.h"
#include "imgui/imgui_impl_dx11.h"
#include "imgui/imgui_impl_win32.h"

#pragma comment(lib, "winmm.lib")

//�萔�錾
const char* WIN_CLASS_NAME = "SampleGame";  //�E�B���h�E�N���X��
const int WINDOW_WIDTH = 800;  //�E�B���h�E�̕�
const int WINDOW_HEIGHT = 600; //�E�B���h�E�̍���

RootJob* pRootJob = nullptr;

//�v���g�^�C�v�錾
LRESULT CALLBACK WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);



//�G���g���[�|�C���g
int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE hPrevInst, LPSTR lpCmdLine, int nCmdShow)
{
	//�E�B���h�E�N���X�i�݌v�}�j���쐬
	WNDCLASSEX wc;
	wc.cbSize = sizeof(WNDCLASSEX);             //���̍\���̂̃T�C�Y
	wc.hInstance = hInstance;                   //�C���X�^���X�n���h��
	wc.lpszClassName = WIN_CLASS_NAME;            //�E�B���h�E�N���X��
	wc.lpfnWndProc = WndProc;                   //�E�B���h�E�v���V�[�W��
	wc.style = CS_VREDRAW | CS_HREDRAW;         //�X�^�C���i�f�t�H���g�j
	wc.hIcon = LoadIcon(NULL, IDI_APPLICATION); //�A�C�R��
	wc.hIconSm = LoadIcon(NULL, IDI_WINLOGO);   //�������A�C�R��
	wc.hCursor = LoadCursor(NULL, IDC_ARROW);   //�}�E�X�J�[�\��
	wc.lpszMenuName = NULL;                     //���j���[�i�Ȃ��j
	wc.cbClsExtra = 0;
	wc.cbWndExtra = 0;
	wc.hbrBackground = (HBRUSH)GetStockObject(WHITE_BRUSH); //�w�i�i���j
	RegisterClassEx(&wc); //�N���X��o�^

	//�E�B���h�E�T�C�Y�̌v�Z
	RECT winRect = { 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT };
	AdjustWindowRect(&winRect, WS_OVERLAPPEDWINDOW, FALSE);
	int winW = winRect.right - winRect.left;     //�E�B���h�E��
	int winH = winRect.bottom - winRect.top;     //�E�B���h�E����

	//�E�B���h�E���쐬
	HWND hWnd = CreateWindow(
		WIN_CLASS_NAME,         //�E�B���h�E�N���X��
		"�T���v���Q�[��",     //�^�C�g���o�[�ɕ\��������e
		WS_OVERLAPPEDWINDOW, //�X�^�C���i���ʂ̃E�B���h�E�j
		CW_USEDEFAULT,       //�\���ʒu���i���܂����j
		CW_USEDEFAULT,       //�\���ʒu��i���܂����j
		winW,               //�E�B���h�E��
		winH,               //�E�B���h�E����
		NULL,                //�e�E�C���h�E�i�Ȃ��j
		NULL,                //���j���[�i�Ȃ��j
		hInstance,           //�C���X�^���X
		NULL                 //�p�����[�^�i�Ȃ��j
	);

	//�E�B���h�E��\��
	ShowWindow(hWnd, nCmdShow);

	//Direct3D������
	HRESULT hr;
	hr = Direct3D::Initialize(winW, winH, hWnd);
	if (FAILED(hr))
	{
		PostQuitMessage(0); //�G���[�N�����狭���I��
	}

	{
		IMGUI_CHECKVERSION();
		ImGui::CreateContext();
		ImGuiIO& io = ImGui::GetIO();
		ImGui_ImplWin32_Init(hWnd);
		ImGui_ImplDX11_Init(Direct3D::pDevice_, Direct3D::pContext_);
		ImGui::StyleColorsLight();
	}
	


	//�J�����̏�����
	Camera::Initialize();

	//DirectInput�̏�����
	Input::Initialize(hWnd);

	pRootJob = new RootJob(nullptr);
	pRootJob->Initialize();


	//���b�Z�[�W���[�v�i�����N����̂�҂j
	MSG msg;
	ZeroMemory(&msg, sizeof(msg));
	while (msg.message != WM_QUIT)
	{
		//���b�Z�[�W����
		if (PeekMessage(&msg, NULL, 0U, 0U, PM_REMOVE))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}

		//���b�Z�[�W�Ȃ�
		else
		{
			timeBeginPeriod(1);

			static DWORD countFps = 0;
			static DWORD startTime = timeGetTime();
			DWORD nowTime = timeGetTime();
			static DWORD lastUpdateTime = nowTime;

			if (nowTime - startTime >= 1000)
			{
				char str[16];
				wsprintf(str, "%u", countFps);
				SetWindowText(hWnd, str);

				countFps = 0;
				startTime = nowTime;
			}

			if ((nowTime - lastUpdateTime) * 60 <= 1000)
			{
				continue;
			}
			lastUpdateTime = nowTime;


			countFps++;

			timeEndPeriod(1);

			//���Q�[���̏���
			//�J�����̍X�V
			Camera::Update();

			//���͂̏���
			Input::Update();
			pRootJob->UpdateSub();

			//���`��
			Direct3D::BeginDraw();

			//���[�g�W���u����A���ׂẴI�u�W�F�N�g�̃h���[���Ă�
			pRootJob->DrawSub();

			Direct3D::EndDraw();


		}
	}


	Model::Release();
	pRootJob->ReleaseSub();
	SAFE_DELETE(pRootJob);

	Input::Release();
	Direct3D::Release();

	return 0;
}

//  ImGui�̃��b�Z�[�W����
extern IMGUI_IMPL_API LRESULT ImGui_ImplWin32_WndProcHandler(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);


//�E�B���h�E�v���V�[�W���i�������������ɂ�΂��֐��j
LRESULT CALLBACK WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	if (ImGui_ImplWin32_WndProcHandler(hWnd, msg, wParam, lParam))
		return true;

	switch (msg)
	{
	case WM_DESTROY:
		PostQuitMessage(0);  //�v���O�����I��
		return 0;
	}
	return DefWindowProc(hWnd, msg, wParam, lParam);
}