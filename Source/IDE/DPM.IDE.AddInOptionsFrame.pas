{***************************************************************************}
{                                                                           }
{           Delphi Package Manager - DPM                                    }
{                                                                           }
{           Copyright � 2019 Vincent Parrett and contributors               }
{                                                                           }
{           vincent@finalbuilder.com                                        }
{           https://www.finalbuilder.com                                    }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit DPM.IDE.AddInOptionsFrame;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Variants, System.Classes, System.Actions,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ActnList, Vcl.ImgList, Vcl.CheckLst,
  Vcl.Buttons, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.StdCtrls,
  DPM.Core.Logging,
  DPM.Core.Configuration.Interfaces ;

type
  TDPMOptionsFrame = class(TFrame)
    Panel1: TPanel;
    dpmOptionsActionList: TActionList;
    dpmOptionsImageList: TImageList;
    Panel2: TPanel;
    Panel3: TPanel;
    lvSources: TListView;
    Label1: TLabel;
    txtName: TEdit;
    Label2: TLabel;
    Label4: TLabel;
    Label3: TLabel;
    txtPackageCacheLocation: TButtonedEdit;
    txtUri: TButtonedEdit;
    actAddSource: TAction;
    actRemoveSource: TAction;
    actMoveSourceUp: TAction;
    actMoveSourceDown: TAction;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Label5: TLabel;
    Label6: TLabel;
    txtUserName: TEdit;
    txtPassword: TEdit;
    FolderSelectDialog: TFileOpenDialog;
    cboSourceType: TComboBox;
    Label8: TLabel;
    procedure lvSourcesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure txtNameChange(Sender: TObject);
    procedure txtUriChange(Sender: TObject);
    procedure actAddSourceExecute(Sender: TObject);
    procedure actRemoveSourceExecute(Sender: TObject);
    procedure dpmOptionsActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actMoveSourceUpExecute(Sender: TObject);
    procedure actMoveSourceDownExecute(Sender: TObject);
    procedure txtUserNameChange(Sender: TObject);
    procedure txtPasswordChange(Sender: TObject);
    procedure txtPackageCacheLocationRightButtonClick(Sender: TObject);
    procedure txtUriRightButtonClick(Sender: TObject);
    procedure cboSourceTypeChange(Sender: TObject);
  private
    { Private declarations }
    FConfigFile : string;
    FConfigManager : IConfigurationManager;
    FConfiguration : IConfiguration;
    FLogger : ILogger;
    procedure ExchangeItems(const a, b: Integer);
  protected
  public
    constructor Create(AOwner : TComponent);override;
    { Public declarations }
    procedure LoadSettings;
    procedure SaveSettings;
    procedure SetConfigManager(const manager : IConfigurationManager; const configFile : string = '');
    procedure SetLogger(const logger : ILogger);
    function Validate : boolean;
  end;

  //Note not using virtual mode on list view as it doesn't do checkboxes???

implementation

uses
  System.SysUtils,
  VSoft.Uri,
  DPM.Core.Types,
  DPM.Core.Configuration.Classes,
  DPM.Core.Utils.Config,
  DPM.Core.Utils.Enum;

{$R *.dfm}

{ TDPMOptionsFrame }

procedure TDPMOptionsFrame.actAddSourceExecute(Sender: TObject);
var
  newItem : TListItem;
begin
  newItem := lvSources.Items.Add;
  newItem.Caption := 'New Source';
  newItem.Checked := false;
  newItem.SubItems.Add(''); //uri
  newItem.SubItems.Add(''); //type
  newItem.SubItems.Add(''); //username
  newItem.SubItems.Add(''); //password
  lvSources.ItemIndex := newItem.Index;
end;

procedure TDPMOptionsFrame.actMoveSourceDownExecute(Sender: TObject);
var
  selected : TListItem;
begin
  selected := lvSources.Selected;
  if selected = nil then
    exit;

  ExchangeItems(selected.Index, selected.Index+1);
  lvSources.ItemIndex := selected.Index + 1;

end;

procedure TDPMOptionsFrame.ExchangeItems(const a, b : Integer);
var
  tmpItem : TListItem;
begin
  lvSources.Items.BeginUpdate;
  try
    tmpItem := lvSources.Items.Add;
    tmpItem.Assign(lvSources.Items[a]);
    lvSources.Items.Item[a].Assign(lvSources.Items.Item[b]);
    lvSources.Items.Item[b].Assign(tmpItem);
    tmpItem.Free;
  finally
    lvSources.Items.EndUpdate;
  end;

end;

procedure TDPMOptionsFrame.actMoveSourceUpExecute(Sender: TObject);
var
  selected : TListItem;
begin
  selected := lvSources.Selected;
  if selected = nil then
    exit;

  ExchangeItems(selected.Index, selected.Index-1);

  lvSources.ItemIndex := selected.Index -1;

end;

procedure TDPMOptionsFrame.actRemoveSourceExecute(Sender: TObject);
var
  selectedItem : TListItem;
begin
  selectedItem := lvSources.Selected;
  if selectedItem <> nil then
    lvSources.DeleteSelected;
end;

procedure TDPMOptionsFrame.cboSourceTypeChange(Sender: TObject);
var
  item : TListItem;
begin
  item := lvSources.Selected;
  if item <> nil then
    item.SubItems[1] := cboSourceType.Items[cboSourceType.ItemIndex];
end;

constructor TDPMOptionsFrame.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TDPMOptionsFrame.dpmOptionsActionListUpdate(Action: TBasicAction; var Handled: Boolean);
var
  selected : TListItem;
begin
  selected := lvSources.Selected;
  actRemoveSource.Enabled := selected <> nil;
  actMoveSourceUp.Enabled := (selected <> nil) and (selected.Index > 0);
  actMoveSourceDown.Enabled := (selected <> nil) and (lvSources.Items.Count > 1) and (selected.Index < lvSources.Items.Count -1 );
end;

procedure TDPMOptionsFrame.LoadSettings;
var
  sourceConfig : ISourceConfig;
  item : TListItem;
begin
  FConfigManager.EnsureDefaultConfig; //make sure we have a default config file.
  if FConfigFile = '' then
    FConfigFile := TConfigUtils.GetDefaultConfigFileName;
  FConfiguration := FConfigManager.LoadConfig(FConfigFile);

  txtPackageCacheLocation.Text := FConfiguration.PackageCacheLocation;

  lvSources.Clear;
  for sourceConfig in FConfiguration.Sources do
  begin
    item := lvSources.Items.Add;
    item.Caption := sourceConfig.Name;
    item.Checked := sourceConfig.IsEnabled;
    item.SubItems.Add(sourceConfig.Source);
    item.SubItems.Add(TEnumUtils.EnumToString<TSourceType>(sourceConfig.SourceType));
    item.SubItems.Add(sourceConfig.UserName);
    item.SubItems.Add(sourceConfig.Password);
  end;

end;

procedure TDPMOptionsFrame.lvSourcesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected then
  begin
    txtName.Text := Item.Caption;
    if item.SubItems.Count > 0 then
      txtUri.Text := item.SubItems[0]
    else
      txtUri.Text := '';

    if item.SubItems.Count > 1 then
      cboSourceType.ItemIndex := cboSourceType.Items.IndexOf(item.SubItems[1]);

    if item.SubItems.Count > 2 then
      txtUserName.Text := item.SubItems[2]
    else
      txtUserName.Text := '';

    if item.SubItems.Count > 3 then
      txtPassword.Text := item.SubItems[3]
    else
      txtPassword.Text := '';

  end;
end;

procedure TDPMOptionsFrame.SaveSettings;
var
  i: Integer;
  sourceConfig : ISourceConfig;
  item : TListItem;
begin
  FConfiguration.PackageCacheLocation := txtPackageCacheLocation.Text;
  FConfiguration.Sources.Clear;

  for i := 0 to lvSources.Items.Count -1 do
  begin
    item := lvSources.Items[i];
    sourceConfig := TSourceConfig.Create(FLogger);
    sourceConfig.Name := item.Caption;
    sourceConfig.IsEnabled := item.Checked;
    if item.SubItems.Count > 0 then
      sourceConfig.Source := item.SubItems[0];
    if item.SubItems.Count > 1 then
      sourceConfig.SourceType := TEnumUtils.StringToEnum<TSourceType>(item.SubItems[1]);
    if item.SubItems.Count > 2 then
      sourceConfig.UserName := item.SubItems[2];
    if item.SubItems.Count > 3 then
      sourceConfig.Password := item.SubItems[3];
    FConfiguration.Sources.Add(sourceConfig);
  end;

  FConfigManager.SaveConfig(FConfiguration);
end;

procedure TDPMOptionsFrame.SetConfigManager(const manager: IConfigurationManager; const configFile : string);
begin
  FConfigManager := manager;
  FConfigFile    := configFile;
end;

procedure TDPMOptionsFrame.SetLogger(const logger: ILogger);
begin
  FLogger := logger;
end;

procedure TDPMOptionsFrame.txtNameChange(Sender: TObject);
var
  item : TListItem;
begin
  item := lvSources.Selected;
  if item <> nil then
    item.Caption := txtName.Text;
end;

procedure TDPMOptionsFrame.txtPackageCacheLocationRightButtonClick(Sender: TObject);
begin
  FolderSelectDialog.Title := 'Select Package Cache Folder';
  FolderSelectDialog.DefaultFolder := txtPackageCacheLocation.Text;
  if FolderSelectDialog.Execute then
    txtPackageCacheLocation.Text := FolderSelectDialog.FileName;

end;

procedure TDPMOptionsFrame.txtPasswordChange(Sender: TObject);
var
  item : TListItem;
begin
  item := lvSources.Selected;
  if item <> nil then
    item.SubItems[3] := txtPassword.Text;
end;

procedure TDPMOptionsFrame.txtUriChange(Sender: TObject);
var
  item : TListItem;
begin
  item := lvSources.Selected;
  if item <> nil then
    item.SubItems[0] := txtUri.Text;
end;

procedure TDPMOptionsFrame.txtUriRightButtonClick(Sender: TObject);
begin
  FolderSelectDialog.Title := 'Select Package Source Folder';
  FolderSelectDialog.DefaultFolder := txtUri.Text;
  if FolderSelectDialog.Execute then
    txtUri.Text := FolderSelectDialog.FileName;

end;

procedure TDPMOptionsFrame.txtUserNameChange(Sender: TObject);
var
  item : TListItem;
begin
  item := lvSources.Selected;
  if item <> nil then
    item.SubItems[2] := txtUserName.Text;
end;

function TDPMOptionsFrame.Validate: boolean;
var
  i, j: Integer;
  enabledCount : integer;
  sErrorMessage : string;
  nameList : TStringList;
  uriList : TStringList;
  sName : string;
  sUri : string;
  uri : IUri;
  sourceType : string;
begin
  enabledCount := 0;
  nameList := TStringList.Create;
  uriList := TStringList.Create;
  try
    for i := 0 to lvSources.Items.Count -1 do
    begin
      if lvSources.Items[i].Checked then
        Inc(enabledCount);
      sName := lvSources.Items[i].Caption;
      if nameList.IndexOf(sName) > -1 then
        sErrorMessage := sErrorMessage + 'Duplicate Source Name [' + sName +']' + #13#10;
      nameList.Add(sName);

      if (lvSources.Items[i].SubItems.Count > 0 ) then
        sUri := lvSources.Items[i].SubItems[0]
      else
        sUri := '';
      if (lvSources.Items[i].SubItems.Count > 1 ) then
        sourceType := lvSources.Items[i].SubItems[1]
      else
        sourceType := 'Folder';

      if sUri = '' then
        sErrorMessage := sErrorMessage + 'No Uri for Source  [' + sName +']' + #13#10
      else
      begin
        j := uriList.IndexOfName(sUri);
        if j > -1 then
        begin
          //duplicate uri, check if the type is the same.
          if SameText(sourceType, uriList.ValueFromIndex[j]) then
            sErrorMessage := sErrorMessage + 'Duplicate Uri/type  [' + sName +']' + #13#10;
        end;
      end;

      uriList.Add(sUri + '=' + sourceType);
      try
        uri := TUriFactory.Parse(sUri);
//          if not (uri.IsFile or uri.IsUnc) then
//          begin
//            sErrorMessage := sErrorMessage + 'only folder uri type is supported at the moment' + #13#10;
//          end;
      except
        on e : Exception do
        begin
          sErrorMessage := sErrorMessage + 'Invalid Uri for Source  [' + sName +'] : ' + e.Message + #13#10;
        end;
      end;
    end;

  finally
    nameList.Free;
    uriList.Free;
  end;



  if enabledCount = 0 then
    sErrorMessage := sErrorMessage +  'At least 1 source must be defined and enabled!';

  result := sErrorMessage = '';
  if not result then
  begin
    sErrorMessage := 'DPM Package Manage Options Validation Errors:' + #13#10#13#10 + sErrorMessage;
    ShowMessage(sErrorMessage);
  end;

end;

end.
