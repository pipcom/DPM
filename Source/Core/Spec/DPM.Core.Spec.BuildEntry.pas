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

unit DPM.Core.Spec.BuildEntry;

interface
uses
  JsonDataObjects,
  Spring.Collections,
  DPM.Core.Logging,
  DPM.Core.Spec.Interfaces,
  DPM.Core.Spec.Node;

type
  TSpecBuildEntry = class(TSpecNode, ISpecBuildEntry)
  private
    FLogger : ILogger;
    FBplOutputDir: string;
    FConfig: string;
    FDcpOutputDir: string;
    FDcuOutputDir: string;
    FId: string;
    FProject: string;
    FPreBuilt : boolean;
  protected
    function GetBplOutputDir: string;
    function GetConfig: string;
    function GetDcpOutputDir: string;
    function GetDcuOutputDir: string;
    function GetId: string;
    function GetProject: string;
    function GetPreBuilt : boolean;
    procedure SetProject(const value : string);
    procedure SetBplOutputDir(const value: string);
    procedure SetDcpOutputDir(const value: string);
    procedure SetDcuOutputDir(const value: string);
    procedure SetId(const value: string);

    function LoadFromJson(const jsonObject: TJsonObject): Boolean;override;
    function Clone : ISpecBuildEntry;

  public
    constructor CreateClone(const logger: ILogger; const id, project, config, bpldir, dcpdir,dcudir: string; const preBuilt : boolean);reintroduce;
  public
    constructor Create(const logger: ILogger); override;

  end;

implementation

{ TSpecBuildEntry }

function TSpecBuildEntry.Clone: ISpecBuildEntry;
begin
  result := TSpecBuildEntry.CreateClone(logger, FId, FProject,FConfig, FBplOutputDir,FDcpOutputDir,FDcuOutputDir, FPreBuilt);
end;

constructor TSpecBuildEntry.Create(const logger: ILogger);
begin
  inherited Create(logger);

end;

constructor TSpecBuildEntry.CreateClone(const logger: ILogger; const id, project, config, bpldir, dcpdir, dcudir: string; const preBuilt : boolean);
begin
  inherited Create(logger);
  FId := id;
  FProject := project;
  FConfig := config;
  FBplOutputDir := bpldir;
  FDcpOutputDir := dcpdir;
  FDcuOutputDir := dcudir;
  FPreBuilt     := preBuilt;
end;

function TSpecBuildEntry.GetBplOutputDir: string;
begin
  result := FBplOutputDir;
end;

function TSpecBuildEntry.GetConfig: string;
begin
  result := FConfig;
end;

function TSpecBuildEntry.GetDcpOutputDir: string;
begin
  result := FDcpOutputDir;
end;

function TSpecBuildEntry.GetDcuOutputDir: string;
begin
  result := FDcuOutputDir;
end;

function TSpecBuildEntry.GetId: string;
begin
  result := FId;
end;

function TSpecBuildEntry.GetPreBuilt: Boolean;
begin
  result := FPreBuilt;
end;

function TSpecBuildEntry.GetProject: string;
begin
  result := FProject;
end;

function TSpecBuildEntry.LoadFromJson(const jsonObject: TJsonObject): Boolean;
begin
  result := true;
  FId := jsonObject.S['id'];
  if FId = '' then
  begin
    FLogger.Error('Build Entry is missing required [id] property.');
    result := false;
  end;

  FProject := jsonObject.S['project'];
  if FProject = '' then
  begin
    FLogger.Error('Build Entry is missing required [project] property.');
    result := false;
  end;

  FConfig := jsonObject.S['config'];
  if FConfig = '' then
    FConfig := 'release';

  FBplOutputDir := jsonObject.S['bplOutputDir'];
  if FBplOutputDir = '' then
    FBplOutputDir := 'bin';

  FDcpOutputDir := jsonObject.S['dcpOutputDir'];
  if FDcpOutputDir = '' then
    FDcpOutputDir := 'lib';

  FDcuOutputDir := jsonObject.S['dcuOutputDir'];
  if FDcuOutputDir = '' then
    FDcuOutputDir := 'lib';

  if jsonObject.Contains('preBuilt') then
    FPreBuilt := jsonObject.B['preBuilt']
  else
    FPreBuilt := true;
end;

procedure TSpecBuildEntry.SetBplOutputDir(const value: string);
begin
  FBplOutputDir := value;
end;

procedure TSpecBuildEntry.SetDcpOutputDir(const value: string);
begin
  FDcpOutputDir := value;
end;

procedure TSpecBuildEntry.SetDcuOutputDir(const value: string);
begin
  FDcuOutputDir := value;
end;

procedure TSpecBuildEntry.SetId(const value: string);
begin
  FId := value;
end;

procedure TSpecBuildEntry.SetProject(const value: string);
begin
  FProject := value;
end;

end.
