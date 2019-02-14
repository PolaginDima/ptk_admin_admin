unit workinooandms;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, variants, comobj, LCLType, lazutf8,dialogs;
type

  { TmyExcelCalc }

  { TmyWordWriteExcelCalc }

  TmyWordWriteExcelCalc=class(Tobject)
   type TTipdoc=(ttdError,ttdNone,ttdExcel,ttdCalc, ttdWord, ttdWrite);
  type TServer_TIP=(ttsNone,ttsMSWord,ttsOO);
    private
           FTIP_DOC:TTipdoc;
           function GetisconnectOO: boolean;
           function GetTipDoc(spath:string):boolean;
           function connectOO:boolean;
           function connectMSWord:boolean;
           function OpeningDOCoWriter(const spath:string):boolean;
           function OpeningDOCoWord(const spath:string):boolean;
           function ooCreateValue(ooName: string; ooData: variant): variant;
           function MakePropertyValue(PropertyName,PropertyValue:string):variant;
           function FileNameToURL(FileName: string): variant;
           const ServerName ='com.sun.star.ServiceManager';
    protected
      Server:Variant;
      Desktop:Variant;
      Document:Variant;
      Server_TIP:TServer_TIP;
      procedure ReplaceAll(const SourceWord:widestring; ReplaceWord:string);
    public
          //constructor CreateTable(TIP_DOC);virtual;
          constructor CreateDOCoo(const TIP_DOC:string);virtual;
          constructor OpenDOCwriter(const spath:string);virtual;
          constructor OpenDOCWord(const spath:string);virtual;
          destructor Destroy;override;
          property isconnectOO:boolean read GetisconnectOO;
  end;

implementation

{ TmyWordWriteExcelCalc }

function TmyWordWriteExcelCalc.GetTipDoc(spath: string): boolean;
begin
  //Определяем тип документа по расширению
  case lowercase(ExtractFileExt(spath)) of
  '.doc':begin
             self.FTIP_DOC:=ttdWord;
             result:=true;
        end;
  else result:=false;
  end;
end;

function TmyWordWriteExcelCalc.GetisconnectOO: boolean;
begin
  //Проверяем наличие подключения
  result:= not (VarIsEmpty(Server) or VarIsNull(Server));
end;

function TmyWordWriteExcelCalc.connectOO: boolean;
begin
  if Assigned(InitProc) then
    TProcedure(InitProc);
  try
    //Подключаемся к серверу
    Server := CreateoleObject(ServerName);
    result:=isconnectOO;
  except
    result:=false;
  end;
end;

function TmyWordWriteExcelCalc.connectMSWord: boolean;
begin

end;

function TmyWordWriteExcelCalc.OpeningDOCoWriter(const spath: string): boolean;
var ooParams:variant;
     oDescriptor:variant;
    instext:variant;
    oFoundAll, oFound:variant;
    i:integer;
begin
  //проверим подключение к серверу автоматизации
  if not isconnectOO then Raise Exception.Create('Нет подключения к ОО');
  DeskTop:= Unassigned;//освободим переменную
  DeskTop:=Server.CreateInstance('com.sun.star.frame.Desktop');//Получим рабочий стол
  ooParams:=VarArrayCreate([0, -1], varVariant);//массив параметров
  {VarArrayCreate([0, 0], varVariant);
  ooParams:=    VarArrayCreate([0, 0], varVariant);
   ooParams[0]:= ooCreateValue('Hidden', not Visible);
  }
  {
  ooParams:=    VarArrayCreate([0, 0], varVariant);
  ooParams[0] := MakePropertyValue('FilterName','MS Word 97');//Фильтр на открытие  MS Word 97
  }
  //Открываем документ
  Document := Desktop.LoadComponentFromURL('file:///'+FilenametoURL(spath),
                                           '_blank', 0, ooParams);
end;

function TmyWordWriteExcelCalc.OpeningDOCoWord(const spath: string): boolean;
begin

end;

function TmyWordWriteExcelCalc.ooCreateValue(ooName: string; ooData: variant
  ): variant;
{var
  ooReflection: variant;  }
begin{
  if IsOpenOffice then begin
    ooReflection:= Programa.createInstance('com.sun.star.reflection.CoreReflection');
    ooReflection.forName('com.sun.star.beans.PropertyValue').createObject(result);
    result.Name := ooName;
    result.Value:= ooData;
  end else begin
    raise exception.create('ooValue imposible to create, load OpenOffice first!');
  end;}
end;

function TmyWordWriteExcelCalc.MakePropertyValue(PropertyName,
  PropertyValue: string): variant;
{var
 Structure: variant;  }
begin    {
 Structure :=
       OO.Bridge_GetStruct('com.sun.star.beans.PropertyValue');
 Structure.Name := PropertyName;
 Structure.Value := PropertyValue;
 Result := Structure;}
end;

//Представляем полное имя файла в формате URL
function TmyWordWriteExcelCalc.FileNameToURL(FileName: string): variant;
var
    i: Integer;
//    ch:char;//не работает с кирилицей
//    ch: string;//должно тоже работать с кирилицей.
    ch:tUTF8char;
begin
     Result:='';
      For i:=1 to utf8Length(FileName) do
      Begin
        ch:=utf8copy(FileName, i, 1);//получаем один символ который может занимать
                               //два байта поэтому используем utf8copy
        case ch of
        //Если русский символ, то заменяем шестнадцатиричным значением первого байта и второго,
        //это нужно для перевода пути в URL нотацию
        'а'..'я','А'..'Я':Result:=Result+'%'+IntToHex(Ord(ch[1]), 2)+'%'+IntToHex(Ord(ch[2]), 2);
        '\':result:=result+'/';//для URL нотации
        ':':result:=result+'|';//для URL нотации
        else
               Result:=Result+ch;
        end ;
      End;
      Result:=varastype(Result,varolestr);
end;
 //Заменяем все вхождения SourceWord на ReplaceWord
procedure TmyWordWriteExcelCalc.ReplaceAll(const SourceWord: widestring;
  ReplaceWord: string);
var
    oDescriptor:variant;
    instext:variant;
    oFoundAll, oFound:variant;
    i:integer;
begin
  if Server_TIP=ttsOO then
    begin
      oDescriptor:=Document.createSearchDescriptor;
      oDescriptor.searchString:=SourceWord;
      instext:=Utf8ToAnsi(ReplaceWord);
      oFoundAll:=Document.findAll(oDescriptor);
      //showmessage(inttostr(oFoundAll.getcount()));
      for i:=0 to oFoundAll.getcount()-1 do
      begin
        oFound:=oFoundAll.getByIndex(i);
        oFound.setString(instext);
      end;
    end;
end;

constructor TmyWordWriteExcelCalc.CreateDOCoo(const TIP_DOC: string);
begin
  //Создание пустого документа
  //Не реализовано
end;

constructor TmyWordWriteExcelCalc.OpenDOCwriter(const spath: string);
begin
  if not fileexists(spath) then
    begin
      Raise Exception.Create('файл не найден'+lineending+
      spath);
      exit;
    end;
    //определим тип документа
    if not GetTipDoc(spath) then Raise Exception.Create('неизвестный тип документа');
    //соединяемся с OpenOffic
    //Подключение к серверу автоматизации
    if not connectOO then Raise Exception.Create('Не удалось соединиться с ОО');
    //Укажем что используем ОО
    Server_TIP:=ttsOO;
    //Открытие документа
    OpeningDOCoWriter(spath);
end;

constructor TmyWordWriteExcelCalc.OpenDOCWord(const spath: string);
begin
  if not fileexists(spath) then
    begin
      Raise Exception.Create('файл не найден'+lineending+
      spath);
      exit;
    end;
    //определим тип документа
    if not GetTipDoc(spath) then Raise Exception.Create('неизвестный тип документа');
    //соединяемся с OpenOffic
    //Подключение к серверу автоматизации
    if not connectMSWord then Raise Exception.Create('Не удалось соединиться с MS');
    //Укажем что используем MSWord
    Server_TIP:=ttsMSWord;
    //Открытие документа
    OpeningDOCoWord(spath);
end;

destructor TmyWordWriteExcelCalc.Destroy;
begin
  inherited Destroy;
end;
end.

