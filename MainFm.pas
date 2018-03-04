unit MainFm;
{
                                                                                   >/.
                                                                                  (__)
                                                               ____          .\<
                *         __       __       __       __       /  * \.<       (__)
                 \       /  \     /  \     /  \     /  \     /  ___/
   ______________\_\____/  __\___/  __\___/  __\___/  __\___/  /___________________
|-|____________________/  /_____/  /_____/  /_____/  /_____/  /____________________|-|
||                 \     /   \    /   \    /   \    /   \    /                      ||
||                  \___/     \__/     \__/     \__/     \__/                       ||
||                                                                                  ||
||                                                                                  ||
||				                            PXL Snake                                     ||
||                                                                                  ||
||  .\<                             By H@PPyZERØ5                                   ||
|| (__)                      Email: happy05@programmer.net                          ||
||      >/.                                                                         ||
||     (__)        ____                                                             ||
||              >./ *  \       __       __       __       __         *              ||
||                \___  \     /  \     /  \     /  \     /  \       /               ||
|| ___________________\  \___/__  \___/__  \___/__  \___/__  \____/_/______________ ||
|-|____________________\  \_____\  \_____\  \_____\  \_____\  \____________________|-|
                        \    /   \    /   \    /   \    /   \     /
                         \__/     \__/     \__/     \__/     \___/


You can download the latest version of Platform eXtended Library from the links below.
 --> http://asphyre.net/products/pxl
 --> http://asphyre.sourceforge.net
}

interface

{$INCLUDE PXL.Config.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.UITypes, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.ExtCtrls, PXL.TypeDef, PXL.Types,
  PXL.Timing, PXL.ImageFormats, PXL.Devices, PXL.SwapChains, PXL.Images, PXL.Providers, System.IniFiles;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    FileBtn: TMenuItem;
    NewBtn: TMenuItem;
    HelpBtn: TMenuItem;
    N1: TMenuItem;
    SoundBtn: TMenuItem;
    N2: TMenuItem;
    ExitBtn: TMenuItem;
    AboutBtn: TMenuItem;
    EnableSndBtn: TMenuItem;
    DisableSndBtn: TMenuItem;
    LevelBtn: TMenuItem;
    NewBtn1: TMenuItem;
    N3: TMenuItem;
    ImportBtn: TMenuItem;
    ExportBtn: TMenuItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure NewBtnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EnableSndBtnClick(Sender: TObject);
    procedure DisableSndBtnClick(Sender: TObject);
    procedure ExportBtnClick(Sender: TObject);
    procedure ImportBtnClick(Sender: TObject);
    procedure NewBtn1Click(Sender: TObject);
  private
    { Déclarations privées }
    ImageFormatManager: TImageFormatManager;
    ImageFormatHandler: TCustomImageFormatHandler;

    DeviceProvider: TGraphicsDeviceProvider;

    EngineTicks: Integer;

    GameisOver: Boolean;
    PressSpace: Boolean;

	  Keys: array[0..255] of Boolean;

    procedure ApplicationIdle(Sender: TObject; var Done: Boolean);

    procedure EngineTiming(const Sender: TObject);
    procedure EngineProcess(const Sender: TObject);

    procedure RenderWindow;
    procedure RenderScene;

    procedure NewLevel;
    procedure BeginLevel;
    procedure ControlSnake;
    procedure gameover;
    { Sound. }
    procedure InitBass;
    procedure DoneBass;
    procedure LoadSounds;
    procedure Channel_PauseAll;
    procedure Channel_ResumeAll;

    { Limiting A Forms Size. }
    procedure WMGetMinMaxInfo( var Message :TWMGetMinMaxInfo ); message WM_GETMINMAXINFO;
  public
    { Déclarations publiques }
  end;

var
  MainForm: TMainForm;

  SnakeDir: Byte;
  SnakeLong: Byte;
  SnakeBody: array[0..400] of Tpoint;
  I: Integer;
  Food: Tpoint;
  XCollision: Boolean;
  PlaySound: Boolean;
  Level: Byte;
  SnakeSpeed: Byte;
  Score: Integer;
  YourScore : Integer;
  HighScore : Integer;
  IniScore: TIniFile;
  IniLevel: TIniFile;

implementation

{$R *.dfm}

uses
  PXL.Classes, PXL.ImageFormats.Auto, PXL.Providers.Auto, PXL.Archives.Loading, PXL.Fonts, PXL.Archives,
  Engine.Globals, Sound.Globals, AboutFm, bass;

Const
  ClientH = 672;
  ClientW = 640;

//=======================================================================
procedure TMainForm.FormCreate(Sender: TObject);
begin
 { Enable Delphi's memory manager to show memory leaks. }
  ReportMemoryLeaksOnShutdown := True;

  { Specify that Default provider is to be used. }
  DeviceProvider := CreateDefaultProvider(ImageFormatManager);
  
  { Create PXL Device. }
  EngineDevice := DeviceProvider.CreateDevice as TCustomSwapChainDevice;
  DisplaySize := Point2i(ClientWidth, ClientHeight);
  EngineDevice.SwapChains.Add(Handle, DisplaySize);

  if not EngineDevice.Initialize then
  begin
    MessageDlg('Failed to initialize PXL Device.', mtError, [mbOk], 0);
    Application.Terminate;
    Exit;
  end;

  { Create PXL Canvas compoment. }
  EngineCanvas := DeviceProvider.CreateCanvas(EngineDevice);
  if not EngineCanvas.Initialize then
  begin
    MessageDlg('Failed to initialize PXL Canvas.', mtError, [mbOk], 0);
    Application.Terminate;
    Exit;
  end;

  { Create PXL Archive compoment. }
  EngineArchive := TArchive.Create;
  EngineArchive.OpenMode := TArchive.TOpenMode.ReadOnly;

  if not EngineArchive.OpenFile('data.asvf') then
  begin
    MessageDlg('Failed to open media archive.', mtError, [mbOK], 0);
    Application.Terminate;
    Exit;
  end;

  { General-purpose Image Format Manager. }
  ImageFormatManager := TImageFormatManager.Create;
  { Creates image format handler. }
  ImageFormatHandler := CreateDefaultImageFormatHandler(ImageFormatManager);

  { Create PXL Images compoment. }
  EngineImages := TAtlasImages.Create(EngineDevice);

  ImageBackground := LoadImageFromArchive('Background.Image', EngineImages, EngineArchive);
  ImageLogo := LoadImageFromArchive('Logo.image', EngineImages, EngineArchive);
  ImageBody := LoadImageFromArchive('Snake.image', EngineImages, EngineArchive);
  ImageFood := LoadImageFromArchive('Food.image', EngineImages, EngineArchive);
  ImageGameOver := LoadImageFromArchive('GameOver.image', EngineImages, EngineArchive);

  { Create PXL Fonts compoment. }
  EngineFonts := TBitmapFonts.Create(EngineDevice);
  EngineFonts.Canvas := EngineCanvas;

  FontTahoma := EngineFonts.AddFromBinaryFile(CrossFixFileName('Tahoma9b.font'));
  if FontTahoma = -1 then
  begin
    MessageDlg('Could not load Tahoma font.', mtError, [mbOk], 0);
    Application.Terminate;
    Exit;
  end;

  { Initialize and prepare the timer. }
  EngineTimer := TMultimediaTimer.Create;
  EngineTimer.OnTimer := EngineTiming;
  EngineTimer.OnProcess := EngineProcess;
  EngineTimer.MaxFPS := 4000;

  Application.OnIdle := ApplicationIdle;
  EngineTicks := 0;

  MainForm.Caption:= 'Snake Game - Technology: ' + GetFullDeviceTechString(EngineDevice);
  MainForm.ClientHeight := ClientH;
  MainForm.ClientWidth := ClientW;
  { Configure the current window to be placed in the centre of screen. }
  MainForm.Left := (Screen.Width - MainForm.Width) div 2;
  MainForm.Top := (Screen.Height - MainForm.Height) div 2;

  { initialize bass.dll }
  InitBass;

  { load  Best score if exist. }
  if FileExists(ExtractFilePath(Application.ExeName) + '\Score.dat') then
    begin
      IniScore := TIniFile.Create(  ExtractFilePath(Application.ExeName) + '\Score.dat' );
        try
        HighScore := IniScore.ReadInteger( 'highscore', 'Score', 0);
        finally
        IniScore.Free;
       end;
    end;

  BeginLevel;
end;

//=======================================================================
procedure TMainForm.FormDestroy(Sender: TObject);
begin
  { Save Best score. }
  if Yourscore > HighScore then
  begin
    IniScore := TIniFile.Create(  ExtractFilePath(Application.ExeName) + '\Score.dat' );
      try
       IniScore.WriteInteger( 'highscore', 'Score', YourScore);
      finally
        IniScore.Free;
     end;
  end;

  DoneBass;
  { Release all Asphyre components. }
  EngineTimer.Free;
  EngineFonts.Free;
  EngineImages.Free;
  EngineCanvas.Free;
  EngineDevice.Free;
  DeviceProvider.Free;
  ImageFormatHandler.Free;
  ImageFormatManager.Free;
  EngineArchive.Free;
end;

//=======================================================================
procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key <= 255 then
    Keys[Key] := True;
end;

//=======================================================================
procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key <= 255 then
    Keys[Key] := False;
end;

//=======================================================================
procedure TMainForm.ControlSnake;
begin

  if Keys[VK_LEFT] and (SnakeDir<>4) then
    SnakeDir:=3; //Snake direction := Left;

  if Keys[VK_RIGHT] and (SnakeDir<>3) then
    SnakeDir:=4; //Snake direction := Right;

  if Keys[VK_UP] and (SnakeDir<>2) then
    SnakeDir:=1; //Snake direction := Top;

  if Keys[VK_DOWN] and (SnakeDir<>1) then
    SnakeDir:=2; //Snake direction := Down;
	
  { Press space to Start game! }
  if Keys[VK_SPACE] then 
  begin
    PressSpace := True;
    GameIsOver := False;
  end;

  if Keys[VK_ESCAPE] then
    Close;
end;

//=======================================================================
procedure TMainForm.FormResize(Sender: TObject);
begin
  DisplaySize := Point2i(ClientWidth, ClientHeight);

  if (EngineDevice <> nil) and (EngineTimer <> nil) and EngineDevice.Initialized then
  begin
    EngineDevice.Resize(0, DisplaySize);
    RenderWindow;
    EngineTimer.Reset;
  end;
end;

//=======================================================================
{ Limiting A Forms Size
 http://www.angelfire.com/home/jasonvogel/delphi_source_limiting_a_forms_size.html }
procedure TMainForm.WMGetMinMaxInfo( var Message :TWMGetMinMaxInfo );
begin
  with Message.MinMaxInfo^ do
  begin
    if (MainForm.ClientHeight = 672) and (MainForm.ClientWidth = 640) then  begin
      ptMaxSize.X := MainForm.Width;                              //Width when maximized
      ptMaxSize.Y := MainForm.Height;                             //Height when maximized
      ptMaxPosition.X := (Screen.Width - MainForm.Width) div 2;   //Left position when maximized
      ptMaxPosition.Y := (Screen.Height - MainForm.Height) div 2; //Top position when maximized
      ptMinTrackSize.X := MainForm.Width;                         //Minimum width
      ptMinTrackSize.Y := MainForm.Height;                        //Minimum height
      ptMaxTrackSize.X := MainForm.Width;                         //Maximum width
      ptMaxTrackSize.Y := MainForm.Height;                        //Maximum height
    end;
  end;
  Message.Result := 0; //Tell windows you have changed minmaxinfo
  inherited;
end;

//=======================================================================
procedure TMainForm.ApplicationIdle(Sender: TObject; var Done: Boolean);
begin
  EngineTimer.NotifyTick;
  Done := False;
end;

//=======================================================================
procedure TMainForm.AboutBtnClick(Sender: TObject);
begin
  Beep;
  AboutForm.Left := (Screen.Width - AboutForm.Width) div 2;
  AboutForm.Top := (Screen.Height - AboutForm.Height) div 2;
  AboutForm.ShowModal;
end;

//=======================================================================
procedure TMainForm.NewLevel;
begin
  Level := 1;
  Score := 0;
  SnakeSpeed := 25;
  SnakeDir := 1; //Snake direction := Top;
  SnakeLong := 5;
  SnakeBody[1].X :=128;
  SnakeBody[1].y:=416;
  SnakeBody[2].x:=128;
  SnakeBody[2].y:=448;
  SnakeBody[3].x:=128;
  SnakeBody[3].y:=480;
  SnakeBody[4].X :=128;
  SnakeBody[4].Y :=512;
  SnakeBody[5].X :=128;
  SnakeBody[5].Y :=544;
  Food.X :=384;
  Food.Y :=224;
end;

//=======================================================================
procedure TMainForm.BeginLevel;
begin
  PlaySound := True;
  EnableSndBtn.Checked := True;

  PressSpace := False;
  GameisOver := False;

  NewLevel;
end;

//=======================================================================
procedure TMainForm.gameover;
begin
  { Play Dead.wav Sound }
  if PlaySound then
    PlaySample(EffectSamples[2], 10);

  Yourscore := Score;
  GameisOver := True;

  PressSpace := False;

  NewLevel;
end;

//=======================================================================
procedure TMainForm.EngineTiming(const Sender: TObject);
begin
  RenderWindow;
end;

//=======================================================================
procedure TMainForm.ExitBtnClick(Sender: TObject);
begin
  Close;
end;

//=======================================================================
procedure TMainForm.NewBtnClick(Sender: TObject);
begin
  NewLevel;
end;

//=======================================================================
procedure TMainForm.NewBtn1Click(Sender: TObject);
begin
  NewLevel;
end;

//=======================================================================
procedure TMainForm.EngineProcess(const Sender: TObject);
begin
  Inc(EngineTicks);
  ControlSnake;
end;

//=======================================================================
procedure TMainForm.RenderWindow;
begin
  if EngineDevice.BeginScene then
  try
    EngineDevice.Clear([TClearType.Color], 0);

    if EngineCanvas.BeginScene then
    try
      RenderScene;
    finally
      EngineCanvas.EndScene;
    end;

    EngineTimer.Process;
  finally
    EngineDevice.EndScene;
  end;
end;

//=======================================================================
procedure TMainForm.EnableSndBtnClick(Sender: TObject);
begin
  PlaySound := True;
  EnableSndBtn.Checked := True;
  DisableSndBtn.Checked := False;
  Channel_ResumeAll;
end;

//=======================================================================
procedure TMainForm.DisableSndBtnClick(Sender: TObject);
begin
  PlaySound := False;
  DisableSndBtn.Checked := True;
  EnableSndBtn.Checked := False;
  Channel_PauseAll;
end;

//=======================================================================
procedure TMainForm.RenderScene;
begin
  { Play BG.wav Sound. }
  if PlaySound then
    PlaySample(EffectSamples[0], 10);

  if not GameisOver then
  begin
    { Show "PXL Snake" logo. }
    EngineCanvas.UseImageRegion(EngineImages[ImageLogo], 0);
    EngineCanvas.TexQuad(Quad(110.0, 90.0, 420.0, 420.0), ColorRectWhite);

    { Press space to Start ! }
    EngineFonts[FontTahoma].DrawText(
    Point2f(250.0, 520.0),
    'Press space to Start !',
    ColorPair($FFE8FFAA, $FF12C312));
  end;

  { Start game. }
  if PressSpace = true then
  begin
    { Show Background image. }
    EngineCanvas.UseImageRegion(EngineImages[ImageBackground], 0);
    EngineCanvas.TexQuad(Quad(0, 0, 640.0, 672.0), ColorRectWhite);

    { Show Apple image. }
    EngineCanvas.UseImage(EngineImages[ImageFood]);
    EngineCanvas.TexQuad(Quad(Food.X , Food.y, 32.0, 32.0), ColorRectWhite);

    for i:= SnakeLong downto 2 do
      SnakeBody[i] := SnakeBody[i-1];
    case SnakeDir of
      1:SnakeBody[1].y := SnakeBody[1].y -32;
      2:SnakeBody[1].Y := SnakeBody[1].Y +32;
      3:SnakeBody[1].X := SnakeBody[1].X -32;
      4:SnakeBody[1].X := SnakeBody[1].X +32;
    end;
	
    { Show Snake Body.}
    for i:=1 to SnakeLong do
    begin
      EngineCanvas.UseImage(EngineImages[ImageBody]);
      EngineCanvas.TexQuad(Quad(SnakeBody[i].X, SnakeBody[i].Y, 32.0, 32.0), ColorRectWhite);
      sleep(SnakeSpeed);
    end;

    { Collision with MainForm border. }
    if (SnakeBody[1].X <16) or (SnakeBody[1].X >576) or (SnakeBody[1].y <48) or (SnakeBody[1].y >608) then
      gameover;

    { Display Level. }
    EngineFonts[FontTahoma].DrawText(
    Point2f(80.0, 11.0),
    'Level: ' + IntToStr(Level),
    ColorPair($FFFFE887, $FFFF0000));
    { Display Score. }
    EngineFonts[FontTahoma].DrawText(
    Point2f(160.0, 11.0),
    'Score: ' + IntToStr(Score),
    ColorPair($FFFFE887, $FFFF0000));
    { Display Snake body[1].X position. }
    EngineFonts[FontTahoma].DrawText(
    Point2f(240.0, 11.0),
    'X: ' + IntToStr(SnakeBody[1].X),
    ColorPair($FFFFE887, $FFFF0000));
    { Display Snake body[1].Y position. }
    EngineFonts[FontTahoma].DrawText(
    Point2f(290.0, 11.0),
    'Y: ' + IntToStr(SnakeBody[1].Y),
    ColorPair($FFFFE887, $FFFF0000));

    { Collision with himself. }
    for i := 2 to SnakeLong do
    begin
      if (SnakeBody[i].X = SnakeBody[1].x) and (SnakeBody[i].y = SnakeBody[1].Y) then
        gameover;
    end;

    { Collision with the Apple //Eat the Food. }
    if (SnakeBody[1].X = Food.X) and (SnakeBody[1].Y = Food.Y)  then
    begin
      { Play Coin.wav Sound }
      if PlaySound then
        PlaySample(EffectSamples[1], 20);

      Score := Score + (Level * 2);

      if (Score >= (Level * 20)) then
      begin
        Score:=0;
        SnakeSpeed := SnakeSpeed - 2;
        Level := Level + 1;
        SnakeDir := 1;
        SnakeLong := 5;
        SnakeBody[1].X := 128;
        SnakeBody[1].y := 416;
        SnakeBody[2].x := 128;
        SnakeBody[2].y := 448;
        SnakeBody[3].x := 128;
        SnakeBody[3].y := 480;
        SnakeBody[4].X := 128;
        SnakeBody[4].Y := 512;
        SnakeBody[5].X := 128;
        SnakeBody[5].Y := 544;
    end;

    repeat
      XCollision := true;
      Food.X := (2+random(16))*32;
      Food.Y := (2+random(16))*32;
      for i := 1 to SnakeLong do
      begin
        if (Food.X = SnakeBody[i].x) and (Food.Y = SnakeBody[i].Y) then
          XCollision := false;
      end;
    until XCollision;

    SnakeLong := SnakeLong + 1;
    SnakeBody[SnakeLong].X := SnakeBody[SnakeLong-1].X +32;
    SnakeBody[SnakeLong].Y := SnakeBody[SnakeLong-1].Y ;
   end;

   ExportBtn.Enabled := True;
   NewBtn.Enabled := True;
   NewBtn1.Enabled := True;
  end;

  if GameisOver then
  begin
    { Draw the image of GameOver. }
    EngineCanvas.UseImageRegion(EngineImages[ImageGameOver], 0);
    EngineCanvas.TexQuad(Quad(150.0, 90.0, 340.0, 70.0), ColorRectWhite);

    { Display Your score. }
    EngineFonts[FontTahoma].DrawText(
    Point2f(250.0, 200.0),
    '--> Your score : ' + IntToStr(Yourscore),
    ColorPair($FFFFE887, $FFFF0000));

    { Display Best score. }
    if HighScore > Yourscore then
    EngineFonts[FontTahoma].DrawText(
    Point2f(250.0, 230.0),
    '--> Best score : ' + IntToStr(HighScore),
    ColorPair($FFFFE887, $FFFF0000))
    else
    EngineFonts[FontTahoma].DrawText(
    Point2f(250.0, 230.0),
    '--> Best score : ' + IntToStr(Yourscore),
    ColorPair($FFFFE887, $FFFF0000));

    { Show "PXL Snake" logo. }
    EngineCanvas.UseImageRegion(EngineImages[ImageLogo], 0);
    EngineCanvas.TexQuad(Quad(210.0, 280.0, 220.0, 220.0), ColorRectWhite);

    { Display "Press space to Restart !". }
    EngineFonts[FontTahoma].DrawText(
    Point2f(240.0, 520.0),
    'Press space to Restart !',
    ColorPair($FFE8FFAA, $FF12C312));

    ExportBtn.Enabled := False;
    NewBtn.Enabled := False;
    NewBtn1.Enabled := False;
  end;

  { Display current status. }
  EngineFonts[FontTahoma].DrawText(
  Point2f(6.0, 11.0),
  'FPS: ' + IntToStr(EngineTimer.FrameRate),
  ColorPair($FFFFE887, $FFFF0000));
end;

//=======================================================================
procedure TMainForm.ImportBtnClick(Sender: TObject);
begin
  if opendialog1.Execute then
  begin
    IniLevel := TIniFile.Create(opendialog1.FileName);
      try
       PlaySound := IniLevel.ReadBool( 'PXLSnakeLevel', 'PlaySound', True);
       if PlaySound = True then
         begin
           EnableSndBtn.Checked := True;
           DisableSndBtn.Checked := False;
           Channel_ResumeAll;
         end else
         begin
           EnableSndBtn.Checked := False;
           DisableSndBtn.Checked := True;
           Channel_PauseAll;
         end;
       GameisOver := False;
       Level := IniLevel.ReadInteger( 'PXLSnakeLevel', 'Level', 1);
       Score := IniLevel.ReadInteger( 'PXLSnakeLevel', 'Score', 50);
       SnakeSpeed := IniLevel.ReadInteger( 'PXLSnakeLevel', 'SnakeSpeed', SnakeSpeed);
       SnakeDir := IniLevel.ReadInteger( 'PXLSnakeLevel', 'SnakeDir', SnakeDir);
       SnakeLong := IniLevel.ReadInteger( 'PXLSnakeLevel', 'SnakeLong', SnakeLong);
       Level := IniLevel.ReadInteger( 'PXLSnakeLevel', 'Level', Level);
       for i := 1 to SnakeLong do
         begin
           SnakeBody[i].X := IniLevel.ReadInteger( 'PXLSnakeLevel', 'SnakeBody[' + inttostr(i) + '].X', SnakeBody[i].X);
           SnakeBody[i].Y := IniLevel.ReadInteger( 'PXLSnakeLevel', 'SnakeBody[' + inttostr(i) + '].Y', SnakeBody[i].Y);
         end;
       Food.X := IniLevel.ReadInteger( 'PXLSnakeLevel', 'Food.X', Food.X);
       Food.Y := IniLevel.ReadInteger( 'PXLSnakeLevel', 'Food.Y', Food.Y);
      finally
        IniLevel.Free;
     end;
  end;
  PressSpace := True;
end;

//=======================================================================
procedure TMainForm.ExportBtnClick(Sender: TObject);
begin
  if savedialog1.Execute then
  begin
    IniLevel := TIniFile.Create(savedialog1.FileName);
      try
       IniLevel.WriteBool( 'PXLSnakeLevel', 'PlaySound', PlaySound);
       IniLevel.WriteInteger( 'PXLSnakeLevel', 'Level', Level);
       IniLevel.WriteInteger( 'PXLSnakeLevel', 'Score', Score);
       IniLevel.WriteInteger( 'PXLSnakeLevel', 'SnakeSpeed', SnakeSpeed);
       IniLevel.WriteInteger( 'PXLSnakeLevel', 'SnakeDir', SnakeDir);
       IniLevel.WriteInteger( 'PXLSnakeLevel', 'SnakeLong', SnakeLong);
       IniLevel.WriteInteger( 'PXLSnakeLevel', 'Level', Level);
       for i := 1 to SnakeLong do
         begin
           IniLevel.WriteInteger( 'PXLSnakeLevel', 'SnakeBody[' + inttostr(i) + '].X', SnakeBody[i].X);
           IniLevel.WriteInteger( 'PXLSnakeLevel', 'SnakeBody[' + inttostr(i) + '].Y', SnakeBody[i].Y);
         end;
       IniLevel.WriteInteger( 'PXLSnakeLevel', 'Food.X', Food.X);
       IniLevel.WriteInteger( 'PXLSnakeLevel', 'Food.Y', Food.Y);
      finally
        IniLevel.Free;
     end;
  end;
end;

//=======================================================================
procedure TMainForm.InitBass;
begin
  if not BASS_Init(-1, 44100, 0, 0, nil) then
  begin
    MessageDlg('Failed to initialize bass.dll!', mtError, [mbOK], 0);
    Application.Terminate;
    Exit;
	 end;

  LoadSounds;
end;

//=======================================================================
procedure TMainForm.DoneBass;
var
  I: Integer;
begin
  for I := 0 to High(EffectSamples) do
    if EffectSamples[I] <> 0 then
    begin
      BASS_SampleFree(EffectSamples[I]);
      EffectSamples[I] := 0;
    end;

  BASS_Free;
end;

//=======================================================================
procedure TMainForm.LoadSounds;
const
  SoundKeys: array[0..2] of StdString = ('BG.wav', 'Coin.wav', 'Dead.wav');
var
  Stream: TMemoryStream;
  I: Integer;
begin
  Stream := TMemoryStream.Create;
  try
    for I := 0 to 2 do
    begin
      Stream.Clear;

      if not EngineArchive.ReadStream(SoundKeys[I], Stream) then
      begin
        DoneBass;
        MessageDlg('Failed to load sample sounds!', mtError, [mbOK], 0);
        Application.Terminate;
        Exit;
      end;

      EffectSamples[I] := BASS_SampleLoad(True, Stream.Memory, 0, Stream.Size, 8, 0);
      if EffectSamples[I] = 0 then
      begin
        DoneBass;
        MessageDlg('Failed to load sample sounds!', mtError, [mbOK], 0);
        Application.Terminate;
        Exit;
      end;
    end;
  finally
    Stream.Free;
  end;
end;

//=======================================================================
procedure TMainForm.Channel_PauseAll;
begin
    BASS_Pause;
end;

//=======================================================================
procedure TMainForm.Channel_ResumeAll;
begin
    BASS_Start;
end;

end.
