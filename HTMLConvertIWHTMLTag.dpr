program HTMLConvertIWHTMLTag;

{$APPTYPE CONSOLE}

uses
  Classes,
  SysUtils;

type
  THTMLToIWHTMLTag = class(TObject)
  private
    class function SplitTag(HTMLFile: TStringList): TStringList;
    class function GenerateStartTag(HTML: String; FirstTag: Boolean)
      : TStringList;
    class function GenerateStringParems(HTML: String): TStringList;
    class function GenerateEndTag(HTML: String): TStringList;
    class function CheckStartTag(HTML: String): Boolean;
    class function CheckEndTag(HTML: String): Boolean;
    class function GenerateText(HTML: String): TStringList;
  end;

  { THTMLToIWHTMLTag }

class function THTMLToIWHTMLTag.CheckEndTag(HTML: String): Boolean;
var
  CheckStringInHTML: Integer;
begin
  CheckStringInHTML := AnsiPos('</', HTML);
  if CheckStringInHTML > 0 then
  begin
    Result := True;
  end
  else
    Result := False;
end;

class function THTMLToIWHTMLTag.CheckStartTag(HTML: String): Boolean;
var
  CheckStringInHTML: Integer;
begin
  CheckStringInHTML := AnsiPos('<', HTML);
  CheckStringInHTML := (CheckStringInHTML + AnsiPos('>', HTML));
  if CheckStringInHTML >= 2 then
  begin
    Result := True;
  end
  else
    Result := False;
end;

class function THTMLToIWHTMLTag.GenerateEndTag(HTML: String): TStringList;
var
  HTMLTemp: TStringList;
  EndStringList: TStringList;
  i: Integer;
begin
  HTMLTemp := TStringList.Create;
  EndStringList := TStringList.Create;
  HTMLTemp.Delimiter := '/';
  HTMLTemp.StrictDelimiter := True;
  HTMLTemp.DelimitedText := HTML;
  for i := 0 to HTMLTemp.Count - 1 do
  begin
    if (i mod 2) <> 0 then
      EndStringList.Add('End');
  end;
  Result := EndStringList;
end;

class function THTMLToIWHTMLTag.GenerateStartTag(HTML: String;
  FirstTag: Boolean): TStringList;
var
  HTMLTemp_1: TStringList;
  HTMLTemp_2: TStringList;
  HTMLTemp_3: TStringList;
  HTMLCheckEnd: TStringList;
  StartStringList: TStringList;
  i, j: Integer;
  isFirstTag: Boolean;
begin
  isFirstTag := FirstTag;
  HTMLTemp_1 := TStringList.Create;
  StartStringList := TStringList.Create;
  HTMLTemp_1.Delimiter := '<';
  HTMLTemp_1.StrictDelimiter := True;
  HTMLTemp_1.DelimitedText := HTML;
  for i := 0 to HTMLTemp_1.Count - 1 do
  begin
    if ((i mod 2) <> 0) and (HTMLTemp_1[i] <> '') then
    begin
      HTMLCheckEnd := TStringList.Create;
      HTMLCheckEnd.Delimiter := '/';
      HTMLCheckEnd.StrictDelimiter := True;
      HTMLCheckEnd.DelimitedText := HTMLTemp_1[i];
      if HTMLCheckEnd.Count = 1 then
      begin
        HTMLTemp_2 := TStringList.Create;
        HTMLTemp_2.Delimiter := '>';
        HTMLTemp_2.StrictDelimiter := True;
        HTMLTemp_2.DelimitedText := HTMLTemp_1[i];
        for j := 0 to HTMLTemp_2.Count - 1 do
        begin
          if (j mod 2) = 0 then
          begin
            HTMLTemp_3 := TStringList.Create;
            HTMLTemp_3.Delimiter := ' ';
            HTMLTemp_3.StrictDelimiter := True;
            HTMLTemp_3.DelimitedText := HTMLTemp_2[j];
            if (HTMLTemp_3[0] <> '!--') then
            begin
              if isFirstTag then
              begin
                StartStringList.Add('tag := TIWHTMLTag.CreateTag(''' +
                  HTMLTemp_3[0] + ''');');
                StartStringList.Add('With tag do');
                isFirstTag := False;
              end
              else
              begin
                StartStringList.Add('Contents.AddTag(''' + HTMLTemp_3[0] +
                  ''') do');
                StartStringList.Add('Begin');
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  Result := StartStringList;
end;

class function THTMLToIWHTMLTag.GenerateStringParems(HTML: String): TStringList;
var
  HTMLTemp_1: TStringList;
  HTMLTemp_2: TStringList;
  HTMLTemp_3: TStringList;
  HTMLTemp_4: TStringList;
  HTMLCheckEnd: TStringList;
  MergeString: String;
  StringParamsStringList: TStringList;
  i, j, k, l: Integer;
  TempAddToStringList: String;
begin
  HTMLTemp_1 := TStringList.Create;
  StringParamsStringList := TStringList.Create;
  MergeString := '';
  HTMLTemp_1.Delimiter := '<';
  HTMLTemp_1.StrictDelimiter := True;
  HTMLTemp_1.DelimitedText := HTML;
  for i := 0 to HTMLTemp_1.Count - 1 do
  begin
    if ((i mod 2) <> 0) and (HTMLTemp_1[i] <> '') then
    begin
      HTMLCheckEnd := TStringList.Create;
      HTMLCheckEnd.Delimiter := '/';
      HTMLCheckEnd.StrictDelimiter := True;
      HTMLCheckEnd.DelimitedText := HTMLTemp_1[i];
      if HTMLCheckEnd.Count = 1 then
      begin
        HTMLTemp_2 := TStringList.Create;
        HTMLTemp_2.Delimiter := '>';
        HTMLTemp_2.StrictDelimiter := True;
        HTMLTemp_2.DelimitedText := HTMLTemp_1[i];
        for j := 0 to HTMLTemp_2.Count - 1 do
        begin
          HTMLTemp_3 := TStringList.Create;
          HTMLTemp_3.Delimiter := ' ';
          HTMLTemp_3.StrictDelimiter := True;
          HTMLTemp_3.DelimitedText := HTMLTemp_2[j];
          for k := 0 to HTMLTemp_3.Count - 1 do
          begin
            if k <> 0 then
            begin
              if MergeString = '' then
              begin
                MergeString := HTMLTemp_3[k];
              end
              else
                MergeString := MergeString + ' ' + HTMLTemp_3[k];
            end;
          end;
        end;
        HTMLTemp_4 := TStringList.Create;
        HTMLTemp_4.Delimiter := '=';
        HTMLTemp_4.StrictDelimiter := True;
        HTMLTemp_4.DelimitedText := MergeString;
        for l := 0 to HTMLTemp_4.Count - 1 do
        begin
          if (l mod 2) = 0 then
          begin
            TempAddToStringList := '';
            HTMLTemp_4[l] := StringReplace(HTMLTemp_4[l], #32, '',
              [rfReplaceAll]);
            TempAddToStringList := 'AddStringParam(''' + HTMLTemp_4[l] + ''',';
          end
          else if (l mod 2) <> 0 then
          begin
            TempAddToStringList := TempAddToStringList + '''' + HTMLTemp_4
              [l] + ''');';
            TempAddToStringList := StringReplace(TempAddToStringList, #10, '',
              [rfReplaceAll]);
            StringParamsStringList.Add(TempAddToStringList);
          end;
        end;
      end;
    end;
  end;
  Result := StringParamsStringList;
end;

class function THTMLToIWHTMLTag.GenerateText(HTML: String): TStringList;
var
  HTMLTemp_1: TStringList;
  HTMLTemp_2: TStringList;
  TextStringList: TStringList;
  i: Integer;
begin
  HTMLTemp_1 := TStringList.Create;
  HTMLTemp_2 := TStringList.Create;
  TextStringList := TStringList.Create;
  HTMLTemp_1.Delimiter := '>';
  HTMLTemp_1.StrictDelimiter := True;
  HTMLTemp_1.DelimitedText := HTML;
  if HTMLTemp_1.Count <> 1 then
  begin
    for i := 0 to HTMLTemp_1.Count - 1 do
    begin
      HTMLTemp_2.Delimiter := '/';
      HTMLTemp_2.StrictDelimiter := True;
      HTMLTemp_2.DelimitedText := HTMLTemp_1[i];
      if HTMLTemp_2.Count = 2 then
      begin
        HTMLTemp_2[0] := StringReplace(HTMLTemp_2[0], '<', '', [rfReplaceAll]);
        if HTMLTemp_2[0] <> '' then
          TextStringList.Add('Contents.addtext(''' + HTMLTemp_2[0] + ''');');
      end;
    end;
  end;
  Result := TextStringList;
end;

class function THTMLToIWHTMLTag.SplitTag(HTMLFile: TStringList): TStringList;
var
  i, j, k, l, m: Integer;
  ListTemp: TStringList;
  isFirstUse: Boolean;
begin
  ListTemp := TStringList.Create;
  isFirstUse := True;
  for i := 0 to HTMLFile.Count - 1 do
  begin
    HTMLFile[i] := StringReplace(HTMLFile[i], #9, '', [rfReplaceAll]);
    if CheckStartTag(HTMLFile[i]) then
    begin
      for j := 0 to GenerateStartTag(HTMLFile[i], isFirstUse).Count - 1 do
      begin
        ListTemp.Add(GenerateStartTag(HTMLFile[i], isFirstUse)[j]);
      end;
      isFirstUse := False;
    end;
    for l := 0 to GenerateStringParems(HTMLFile[i]).Count - 1 do
    begin
      ListTemp.Add(GenerateStringParems(HTMLFile[i])[l]);
    end;
    for m := 0 to GenerateText(HTMLFile[i]).Count - 1 do
    begin
      ListTemp.Add(GenerateText(HTMLFile[i])[m]);
    end;
    if CheckEndTag(HTMLFile[i]) then
    begin
      for k := 0 to GenerateEndTag(HTMLFile[i]).Count - 1 do
      begin
        ListTemp.Add(GenerateEndTag(HTMLFile[i])[k]);
      end;
    end;
  end;
  Result := ListTemp;
end;

var
  Files: TStringList;

begin
  try
    begin
      if ParamCount = 1 then
      begin
        Writeln('Create StringList to memory...');
        Files := TStringList.Create;
        Writeln('Load File ' + ParamStr(1) + ' to StringList...');
        Files.LoadFromFile(ParamStr(0));
        Writeln('Convert HTML to TIWHTMLTAG...');
        THTMLToIWHTMLTag.SplitTag(Files).SaveToFile('IWTagExport.txt');
        Writeln('Done!');
        Readln;
      end
      else
        Writeln('Invalid Parameter!');
      Readln;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
