; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "AD LCSC Addons"
#define MyAppVersion "0.1.0-beta"
#define MyAppPublisher "TimonPeng"
#define MyAppURL "https://github.com/TimonPeng/AD-LCSC-Addons"

[Setup]
AppId={{4A5E1E4B-AAB8-9F3A-3251-8A88C31BC87F}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={userdocs}\AD-LCSC-Addons
DisableDirPage=yes
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=.\
OutputBaseFilename=AD LCSC Addons v0.1.0-beta
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"; LicenseFile: .\agreement.txt
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"; LicenseFile: .\agreement_cn.txt

[Files]
Source: ".\src\AD-LCSC-Addons.PrjScr"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\src\AD-LCSC-Addons.dfm"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\src\AD-LCSC-Addons.js"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\src\AD-LCSC-Addons.pas"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\src\config.json"; DestDir: "{app}"; DestName: "config.json"; Flags: ignoreversion; Check: IsEn() and not ConfigExisted();
Source: ".\src\config_cn.json"; DestDir: "{app}"; DestName: "config.json"; Flags: ignoreversion; Check: IsCn () and not ConfigExisted();
Source: ".\api\index.js"; DestDir: "{app}\backend"; DestName: "index.js"; Flags: ignoreversion; Check: IsCn () and not ConfigExisted();
Source: ".\api\jsapi.min.js"; DestDir: "{app}\backend"; DestName: "jsapi.min.js"; Flags: ignoreversion; Check: IsCn () and not ConfigExisted();
Source: ".\api\package.json"; DestDir: "{app}\backend"; DestName: "package.json"; Flags: ignoreversion; Check: IsCn () and not ConfigExisted();

; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Dirs]
Name: "{app}\cache"
Name: "{app}\download"
Name: "{app}\backend"

[Icons]
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[Code]
function IsAltiumRunning(const FileName : String): Boolean;
var
    FSWbemLocator: Variant;
    FWMIService   : Variant;
    FWbemObjectSet: Variant;
begin
    Result := False;
    FSWbemLocator := CreateOleObject('WBEMScripting.SWBEMLocator');
    FWMIService := FSWbemLocator.ConnectServer('', 'root\CIMV2', '', '');

    FWbemObjectSet :=
      FWMIService.ExecQuery(
        Format('SELECT Name FROM Win32_Process Where Name="%s"', [FileName]));
    Result := (FWbemObjectSet.Count > 0);

    FWbemObjectSet := Unassigned;
    FWMIService := Unassigned;
    FSWbemLocator := Unassigned;
end;

function GetGuidFolder(const Path: String; out Folder: String): Boolean;
var
  FindRec: TFindRec;
begin
  Result := False;
  if FindFirst(ExpandConstant(AddBackslash(Path) + '*'), FindRec) then
  try
    repeat
      if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY <> 0) and
        (FindRec.Name <> '.') and (FindRec.Name <> '..') and
        (Pos('Altium Designer {', FindRec.Name) <> 0) then
      begin
        Result := True;
        Folder := AddBackslash(Path) + FindRec.Name;
        Exit;
      end;
    until
      not FindNext(FindRec);
  finally
    FindClose(FindRec);
  end;
end;

function InitializeSetup: Boolean;
var
  GuidFolder: String;
  Dxp, X: Boolean;
begin
  Dxp := IsAltiumRunning('DXP.exe');
  X := IsAltiumRunning('X2.exe');

  Result := True;

  if Dxp or X then
  begin
    MsgBox('Altium Designer is running. Please close the application before install', mbError, MB_OK);
    Result := False;
  end;

  if not GetGuidFolder(ExpandConstant('{userappdata}\Altium'), GuidFolder) then
  begin
    MsgBox('Altium Designer not installed', mbError, MB_OK);
    Result := False;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  LanguageName: String;
  Dxp: AnsiString;
  GuidFolder: String;
begin
  if CurStep = ssPostInstall then
    LanguageName := ActiveLanguage();
    if LanguageName <> '' then
      begin
        GetGuidFolder(ExpandConstant('{userappdata}\Altium'), GuidFolder);

        if not FileExists(GuidFolder + '\DXP.RCS') then
        begin
          SaveStringToFile(GuidFolder + '\DXP.RCS', '', True);
        end;

        if LoadStringFromFile(GuidFolder + '\DXP.RCS', Dxp) then
        begin
          FileCopy(GuidFolder + '\DXP.RCS', GuidFolder + '\DXP.RCS.backup', False);
        end;

        if (Pos('AD-LCSC-Addons', Dxp) = 0) then
        begin
          SaveStringToFile(GuidFolder + '\DXP.RCS', 'Tree EditScriptJSCustom Caption=' + #39 + '[Custom]' + #39 + ' TopLevel=' + #39 + 'True' + #39 + ' End' + #13#10, True);
          SaveStringToFile(GuidFolder + '\DXP.RCS', 'PL AD-LCSC-Addons Command=' + #39 + 'ScriptingSystem:RunScript' + #39 + ' Params=' + #39 + 'ProjectName=' + ExpandConstant('{app}') + '\AD-LCSC-Addons.PrjScr|ProcName=AD-LCSC-Addons.js>Prechecks' + #39 + ' Caption=' + #39 + 'AD LCSC Addons' + #39 + ' DefaultChecked=0 End' + #13#10, True);

          SaveStringToFile(GuidFolder + '\DXP.RCS', 'Insertion User TargetID=' + #39 + 'MNNoDocument_File' + #39 + ' RefID0=' + #39 + 'NoDoc' + #39 + ' Link User PLID=' + #39 + 'AD-LCSC-Addons' + #39 + ' End End' + #13#10, True);
          SaveStringToFile(GuidFolder + '\DXP.RCS', 'Insertion User TargetID=' + #39 + 'MNSchematic_File' + #39 + ' RefID0=' + #39 + 'SchDoc_File' + #39 + ' Link User PLID=' + #39 + 'AD-LCSC-Addons' + #39 + ' End End' + #13#10, True);
          SaveStringToFile(GuidFolder + '\DXP.RCS', 'Insertion User TargetID=' + #39 + 'MNSchematic_Tools' + #39 + ' RefID0=' + #39 + 'SchDoc_Tools' + #39 + ' Link User PLID=' + #39 + 'AD-LCSC-Addons' + #39 + ' End End' + #13#10, True);
          SaveStringToFile(GuidFolder + '\DXP.RCS', 'Insertion User TargetID=' + #39 + 'MNSchematic_SchLibMenu' + #39 + ' RefID0=' + #39 + 'SchLib_File' + #39 + ' Link User PLID=' + #39 + 'AD-LCSC-Addons' + #39 + ' End End' + #13#10, True);
          SaveStringToFile(GuidFolder + '\DXP.RCS', 'Insertion User TargetID=' + #39 + 'MNSchematic_SchLibMenuTools' + #39 + ' RefID0=' + #39 + 'SchLib_Tools' + #39 + ' Link User1 PLID=' + #39 + 'AD-LCSC-Addons' + #39 + ' End End' + #13#10, True);
          SaveStringToFile(GuidFolder + '\DXP.RCS', 'Insertion User TargetID=' + #39 + 'MNPCBLib' + #39 + ' RefID0=' + #39 + 'PcbLib_File' + #39 + ' Link User PLID=' + #39 + 'AD-LCSC-Addons' + #39 + ' End End' + #13#10, True);
          SaveStringToFile(GuidFolder + '\DXP.RCS', 'Insertion User TargetID=' + #39 + 'MNPCBLib_Tools' + #39 + ' RefID0=' + #39 + 'PcbLib_Tools' + #39 + ' Link User PLID=' + #39 + 'AD-LCSC-Addons' + #39 + ' End End' + #13#10, True);
          SaveStringToFile(GuidFolder + '\DXP.RCS', 'Insertion User TargetID=' + #39 + 'MNPCB_File' + #39 + ' RefID0=' + #39 + 'PcbDoc_File' + #39 + ' Link User PLID=' + #39 + 'AD-LCSC-Addons' + #39 + ' End End' + #13#10, True);
          SaveStringToFile(GuidFolder + '\DXP.RCS', 'Insertion User TargetID=' + #39 + 'MNPCB_Tools' + #39 + ' RefID0=' + #39 + 'PcbDoc_Tools' + #39 + ' Link User PLID=' + #39 + 'AD-LCSC-Addons' + #39 + ' End End' + #13#10, True);
        end;

      end;
end;

function InitializeUninstall: Boolean;
var
  GuidFolder: String;
  Dxp, X: Boolean;
begin
  Dxp := IsAltiumRunning('DXP.exe');
  X := IsAltiumRunning('X2.exe');

  Result := True;

  if Dxp or X then
  begin
    MsgBox('Altium Designer is running. Please close the application before uninstall', mbError, MB_OK);
    Result := False;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  GuidFolder: String;
begin
    if CurUninstallStep = usDone then
    begin
      GetGuidFolder(ExpandConstant('{userappdata}\Altium'), GuidFolder);

      FileCopy(GuidFolder + '\DXP.RCS.backup', GuidFolder + '\DXP.RCS', False);
      DelTree(ExpandConstant('{app}'), True, True, True);
    end;
end;

function IsEn(): Boolean;
begin
  Result := ActiveLanguage() = 'english';
end;

function IsCn(): Boolean;
begin
  Result := ActiveLanguage() = 'chinesesimplified';
end;

function ConfigExisted: Boolean;
begin
  Result := FileExists(ExpandConstant('{app}\config.json'));
end;
