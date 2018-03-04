unit Engine.Globals;

interface

{$INCLUDE PXL.Config.inc}

uses
  PXL.Types, PXL.SwapChains, PXL.Canvas, PXL.Images, PXL.Fonts, PXL.Archives, PXL.Timing;

var
    DisplaySize: TPoint2i;

    EngineDevice: TCustomSwapChainDevice = nil;
    EngineCanvas: TCustomCanvas = nil;
    EngineImages: TAtlasImages = nil;
    EngineFonts: TBitmapFonts = nil;
    EngineTimer: TMultimediaTimer = nil;
    EngineArchive: TArchive = nil;


    ImageBackground: Integer = -1;
    ImageLogo: Integer = -1;
    ImageBody: Integer = -1;
    ImageFood: Integer = -1;
    ImageGameOver: Integer = -1;

    FontTahoma: Integer = -1;

implementation

end.
