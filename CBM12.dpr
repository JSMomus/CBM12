program CBM12;

uses
  System.StartUpCopy,
  FMX.Forms,
  unMain in 'unMain.pas' {fmMain},
  unHFuncs1 in 'Misc\unHFuncs1.pas',
  unDataMod in 'Bases\unDataMod.pas' {dmMain: TDataModule},
  unMarketBase in 'Market\unMarketBase.pas',
  unMarketTypes in 'Market\unMarketTypes.pas',
  unMYobit in 'Market\Samples\unMYobit.pas',
  unMYobitPars in 'Market\Samples\unMYobitPars.pas',
  unPrefFile in 'Additional\unPrefFile.pas',
  unCoins in 'Bases\unCoins.pas' {fmCoins},
  unGlobals in 'unGlobals.pas',
  unRateFuncs in 'Misc\unRateFuncs.pas',
  unAddish in 'Additional\unAddish.pas' {fmAddish},
  unPrefs in 'Additional\unPrefs.pas' {fmPrefs},
  unYobitRun in 'Threads\unYobitRun.pas',
  unYobitInfo in 'Threads\unYobitInfo.pas',
  unGenFuncs in 'Misc\unGenFuncs.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Portrait];
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TdmMain, dmMain);
  Application.Run;
end.
