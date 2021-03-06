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

unit DPM.Core.Spec.Template;

interface

uses
  Spring.Collections,
  JsonDataObjects,
  DPM.Core.Logging,
  DPM.Core.Spec.Interfaces,
  DPM.Core.Spec.TemplateBase;

type
  TSpecTemplate = class(TSpecTemplateBase, ISpecTemplate)
  private
    FName : string;
  protected
    function GetName: string;
    function LoadFromJson(const jsonObject: TJsonObject): Boolean;override;
    function AllowDependencyGroups: Boolean; override;
    function AllowSearchPathGroups: Boolean; override;
    function IsTemplate: Boolean; override;

  public
    constructor Create(const logger : ILogger);override;

  end;

implementation

uses
  DPM.Core.Spec.Dependency,
  DPM.Core.Spec.DependencyGroup;

{ TSpecTemplate }

function TSpecTemplate.AllowDependencyGroups: Boolean;
begin
  result := true;
end;

function TSpecTemplate.AllowSearchPathGroups: Boolean;
begin
  result := true;
end;

constructor TSpecTemplate.Create(const logger: ILogger);
begin
  inherited Create(logger);
end;


function TSpecTemplate.GetName: string;
begin
  result := FName;
end;


function TSpecTemplate.IsTemplate: Boolean;
begin
  result := true;
end;

function TSpecTemplate.LoadFromJson(const jsonObject: TJsonObject): Boolean;
begin
  result := true;
  FName := jsonObject.S['name'];
  Logger.Debug('[template] name : ' + FName);

  result := inherited LoadFromJson(jsonObject) and result;
end;

end.
