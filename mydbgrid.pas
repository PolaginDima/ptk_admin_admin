unit myDBGrid;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,DBGrids,Grids,Graphics, StdCtrls,ExtCtrls,lcltype,lazutf8,db,
  Dialogs, Controls, sqldb;
type

     { TMydbgrid }
               TMyrecCol=record
                    name:string;
                    left:integer;
                    right:integer;
               end;
     TMydbgrid=class(TDBGRID)
    private
    FDataLink: TComponentDataLink;
           FDS:TDataSource;
      FColArray:array of TMyreccol;
      FEnabledMarkFiltr: Boolean;
      FFiltrMarkColor: TColor;
      FFiltrMarkFontColor: TColor;
      FSoftFind: boolean;
      FmyFiltered:TNotifyEvent;
      FSQLQUERYdop: TSQLQuery;
      //FcountFilterRow:integer;
    Timer: TTimer;
    colmark:array of boolean;
    //colmarkcolor:array of tcolor;
    editFiltr:tedit;
    Filter:array of string;
    procedure  ontimer(Sender: TObject);
    //procedure SetcountFilterRow(AValue: integer);
    procedure SetEnabledMarkFiltr(AValue: Boolean);
    procedure SetFiltrMarkColor(AValue: TColor);
    procedure SetFiltrMarkFontColor(AValue: TColor);
    procedure SetSoftFind(AValue: boolean);
    procedure showfiltr;
    function addMarkTitle(const Acol:integer):boolean;
    function dellMarkTitle(const Acol:integer):boolean;
    procedure initialArray;
    procedure FilterRecord (DataSet: TDataSet;  var Accept: Boolean);
    procedure MyDBGrid1UTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure MyDBGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);override;
    protected
             procedure DrawColumnText(aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState); override;
             procedure ColRowMoved(IsColumn: Boolean; FromIndex,ToIndex: Integer); override;
    published
    property FiltrMarkColor: TColor read FFiltrMarkColor write SetFiltrMarkColor default clBlue;
    property FiltrMarkFontColor: TColor read FFiltrMarkFontColor write SetFiltrMarkFontColor default clDefault;
    property EnabledMarkFiltr: Boolean read FEnabledMarkFiltr write SetEnabledMarkFiltr default False;
    property SoftFind:boolean read FSoftFind write SetSoftFind default true;
    //function CountFilterRow_:integer;
    protected
    { Protected declarations }
    procedure DrawCell(aCol,aRow: Integer; aRect: TRect; aState:TGridDrawState); override;
    public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property OnmyFiltered:TNotifyEvent read  FmyFiltered write FmyFiltered;
    //property countFilterRow:integer read FcountFilterRow ;
    property SQLQUERYdop:TSQLQuery read FSQLQUERYdop write FSQLQUERYdop;
    end;
implementation

{ TMydbgrid }

procedure TMydbgrid.ontimer(Sender: TObject);
var i:integer;
begin
 // DataSource.DataSet.DisableControls;
  DataSource.DataSet.Filtered:=false;//DataSource.DataSet.Filtered:=true;
  for i:=0 to high(Filter)  do
    begin
    DataSource.DataSet.Filtered:=DataSource.DataSet.Filtered or ((Filter[i])<>'');
    end;
editfiltr.Visible:=false;
timer.Interval:=1000;
 timer.Enabled:=false;
 //DataSource.DataSet.Filtered:=false;
// DataSource.DataSet.EnableControls;
 if Assigned(OnmyFiltered) then {if  DataSource.DataSet.Filtered then} FmyFiltered(self);
end;

procedure TMydbgrid.DrawCell(aCol, aRow: Integer; aRect: TRect;
  aState: TGridDrawState);
  var
    F: TField;
    MyLine: array[0..2] of TPoint;
begin

  inherited DrawCell(aCol, aRow, aRect, aState);


    if (self.DataSource<>nil)and(self.DataSource<>FDS)and(self.SQLQUERYdop<>nil) then
    begin
           FDS:=self.DataSource;
           setlength(FColArray,self.SQLQUERYdop.Fields.Count+1);
    end;

    F := GetFieldFromGridColumn(aCol);

      if (f<>nil)and(FColArray<>nil) then
      begin

        if f.FieldKind=fkLookup then
        self.FColArray[aCol].name:=f.KeyFields
        else
          self.FColArray[aCol].name:=f.FieldName;
        self.FColArray[aCol].left:=aRect.Left+1;
        self.FColArray[aCol].right:=aRect.Right-1;

        if (utf8pos(FColArray[aCol].name,self.SQLQUERYdop.IndexFieldNames)>0) then
        begin
             Canvas.Pen.JoinStyle := pjsBevel;
             canvas.Pen.Color:=clred;
             MyLine[0]:=Point(aRect.Left+1, 0+1);
             MyLine[1]:=Point(aRect.Left+7, 0+1);
             MyLine[2]:=Point(aRect.Left+4, 0+7);
             canvas.Polygon(MyLine);
        end;

      end;


  if (filter<>nil)and(filter[selectedindex]<>'')and(aCol=SelectedIndex)then
  begin
    if (editfiltr.Width<>(aRect.Right-aRect.Left)) then editfiltr.Width:=aRect.Right-aRect.Left;
    if(editfiltr.Left<>aRect.Left) then editfiltr.Left:=aRect.Left;
    end;

  if (colmark<>nil)and(colmark[acol-1]=true)and(aCol>FixedCols-1)and(aRow<=FixedRows-1)and(gdFixed in aState)and(dgTitles in Options)then
  begin
  canvas.Brush.Color:=FFiltrMarkColor;//colmarkcolor[acol-1];
  canvas.FillRect(arect);
  canvas.Font:=font;
  canvas.Font.Color:=clWhite;
  canvas.textrect(arect,arect.Left,arect.Top,columns[acol-1].Title.Caption);
   //canvas.textrect(arect,arect.Left,arect.Top,GetEditText(aCol,aRow));
   //canvas.textout(arect.Left,arect.Top,GetEditText(aCol,aRow));
  end;
end;

constructor TMydbgrid.Create(AOwner: TComponent);
begin
  inherited create(AOwner);
  /////////////////////
  OnUTF8KeyPress:=@MyDBGrid1UTF8KeyPress;
  self.OnKeyDown:=@MyDBGrid1KeyDown;
  //OnDrawColumnCell:=@MyDBGrid1DrawColumnCell;
  //FSoftFind:=true;
  ////////////////////
  Timer:=ttimer.Create(self);
  timer.Enabled:=false;
  timer.Interval:=1000;
  timer.OnTimer:=@ontimer;
  /////////////////////
  editFiltr:=tedit.Create(self);
  editfiltr.Parent:=self;
  editfiltr.Visible:=false;
  editfiltr.Color:=clRed;
  editfiltr.Left:=0;editfiltr.Top:=0;
  //////////////////////
  //FcountFilterRow:=0;
end;

destructor TMydbgrid.Destroy;
begin
  //datasource.DataSet.OnFilterRecord:=nil;
  timer.Free;
  editFiltr.Free;
  inherited Destroy;
end;

procedure TMydbgrid.MyDBGrid1UTF8KeyPress(Sender: TObject;
  var UTF8Key: TUTF8Char);
const simv='qwertyuiopasdfghjklzxcvbnmйцукенгшщзхъфывапролджэячсмитьбюё1234567890/-';
var
 UTF8KeyL:TUTF8Char;
begin
  //инициализируем массивы
  if not FEnabledMarkFiltr then exit;
  if datasource.DataSet.IsEmpty then exit;
  //if datasource.DataSet.RecordCount<=0 then exit;
  if (filter=nil)or(high(filter)<>(columns.Count-1)) then initialArray;
 //приводим нажатую клавишу к нижнему регистру
  //для регистронезависимого поиска
 UTF8KeyL:=UTF8Key;//UTF8LowerCase(UTF8Key);
 //Если Backspace, то стираем последний символ из строки фильтра
{ if UTF8KeyL=#8 then
 begin
 filter[SelectedIndex]:=utf8copy(Filter[SelectedIndex],1,utf8length(Filter[SelectedIndex])-1);
   showFiltr;
 end; }
 //Если нажата алфавитно-цифровая клавиша, то добавляем к фильтру
 if utf8pos(UTF8LowerCase(UTF8KeyL),simv)<>0  then
 begin
 //FcountFilterRow:=0;
 filter[SelectedIndex]:=filter[SelectedIndex]+UTF8KeyL;
   showFiltr;
 end;
end;

procedure TMydbgrid.MyDBGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if not FEnabledMarkFiltr then exit;
 if datasource.DataSet.RecordCount<=0 then exit;
 if (filter=nil)or(high(filter)<>(columns.Count-1)) then initialArray;
 //Если Backspace, то стираем последний символ из строки фильтра
 if Key=8 then
 begin
   //FcountFilterRow:=0;
 filter[SelectedIndex]:=utf8copy(Filter[SelectedIndex],1,utf8length(Filter[SelectedIndex])-1);
   showFiltr;

 end;
end;

procedure TMydbgrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var i:integer;
begin
 inherited MouseDown(Button, Shift, X,  Y);
 if (y<self.DefaultRowHeight) then
 if SQLQUERYdop<>nil then
 begin
  IF Button=mbRight then
  begin
    self.SQLQUERYdop.IndexFieldNames:='';
  end else
  for i:=0 to high(self.Fcolarray) do
       if (self.Fcolarray[i].left+1<x) and(self.Fcolarray[i].right-1>x) then
           begin
             if ssShift in Shift then
             begin
               if length(self.SQLQUERYdop.IndexFieldNames)<=0 then
                  self.SQLQUERYdop.IndexFieldNames:=Fcolarray[i].name else
                  self.SQLQUERYdop.IndexFieldNames:=self.SQLQUERYdop.IndexFieldNames+';'+Fcolarray[i].name;
             end else
                 self.SQLQUERYdop.IndexFieldNames:=Fcolarray[i].name;
             break;
           end;
 end;
end;

procedure TMydbgrid.DrawColumnText(aCol, aRow: Integer; aRect: TRect;
  aState: TGridDrawState);
var
  F: TField;
begin
  if GetIsCellTitle(aCol, aRow) then
     begin
          aRect.Left:=aRect.Left+3; //Сдвинул вправо заголовки, чтобы треугольнички помещались
          inherited DrawColumnText(aCol, aRow, aRect, aState);
     end
  else begin
  F := GetFieldFromGridColumn(aCol);
  if F<>nil then
  DrawCellText(aCol, aRow, aRect, aState, F.DisplayText)
  end;
end;

procedure TMydbgrid.ColRowMoved(IsColumn: Boolean; FromIndex, ToIndex: Integer);
var
  s,tmpstring:string;
  tmpBoolean:boolean;
  i, j:integer;
begin
  inherited ColRowMoved(IsColumn, FromIndex, ToIndex);
  if IsColumn then
  begin
    if Filter<>nil then
    begin
      if ToIndex<FromIndex then
      begin
           tmpstring:=Filter[FromIndex-1];
           tmpBoolean:=colmark[FromIndex-1];
           for i:=FromIndex downto ToIndex+1 do
           begin
                s:=Filter[i-2];
                Filter[i-1]:=Filter[i-2];                colmark[i-1]:=colmark[i-2];
           end;
           Filter[ToIndex-1]:=tmpstring;
           colmark[ToIndex-1]:=tmpBoolean;
      end;
      if ToIndex>FromIndex then
      begin
           tmpstring:=Filter[FromIndex-1];
           tmpBoolean:=colmark[FromIndex-1];
           for i:=FromIndex to ToIndex+1 do
           begin
                s:=Filter[i-2];
                Filter[i-1]:=Filter[i];
                colmark[i-1]:=colmark[i];
           end;
           Filter[ToIndex-1]:=tmpstring;
           colmark[ToIndex-1]:=tmpBoolean;
      end;
    end;
  end;
end;

{
function TMydbgrid.CountFilterRow_: integer;
var j:integer;
 stmp:string;
begin
 if (self.DataSource=nil) or (self.DataSource.DataSet.IsEmpty) then exit;
 stmp:=self.DataSource.DataSet.Fields.Fields[0].AsString;
 self.DataSource.DataSet.First;
 showmessage(inttostr(self.DataSource.DataSet.RecordCount));
 FcountFilterRow:=1;
 while self.DataSource.DataSet.EOF do
begin
self.DataSource.DataSet.Next;
showmessage(self.DataSource.DataSet.Fields.Fields[0].AsString);
FcountFilterRow:=FcountFilterRow+1;
end;
 self.datasource.DataSet.Locate(self.DataSource.DataSet.Fields.Fields[0].FieldName,stmp,[]);
end;
 }


procedure TMydbgrid.SetEnabledMarkFiltr(AValue: Boolean);
begin
  if FEnabledMarkFiltr=AValue then Exit;
  FEnabledMarkFiltr:=AValue;
end;

procedure TMydbgrid.SetFiltrMarkColor(AValue: TColor);
begin
  if FFiltrMarkColor=AValue then Exit;
  FFiltrMarkColor:=AValue;
end;

procedure TMydbgrid.SetFiltrMarkFontColor(AValue: TColor);
begin
  if FFiltrMarkFontColor=AValue then Exit;
  FFiltrMarkFontColor:=AValue;
end;

procedure TMydbgrid.SetSoftFind(AValue: boolean);
begin
  if FSoftFind=AValue then Exit;
  FSoftFind:=AValue;
end;

procedure TMydbgrid.showfiltr;
var i:integer;
begin
  editfiltr.Text:=filter[selectedindex];
  if Filter[selectedindex]='' then
  begin
    dellMarkTitle(SelectedIndex+1);
    editfiltr.Visible:=false;
    timer.Interval:=100;
   end else
   begin
   addMarkTitle(SelectedIndex+1);
   if (editfiltr.Width<>(SelectedFieldRect.Right-SelectedFieldRect.Left))
   then editfiltr.Width:=SelectedFieldRect.Right-SelectedFieldRect.Left;
   if(editfiltr.Left<>SelectedFieldRect.Left)
   then  editfiltr.Left:=SelectedFieldRect.Left;
   editfiltr.Color:=FFiltrMarkColor;
   editfiltr.Font.Color:=FFiltrMarkFontColor;
   editfiltr.visible:=true;
    //ds.Filtered:=true;
   end;
   timer.Enabled:=false;
   timer.Enabled:=true;
end;

function TMydbgrid.addMarkTitle(const Acol: integer): boolean;
begin
  result:=true;
  if (Columns.Count=0)or(Acol>columns.Count)or(Acol<0) then exit(false);
  colmark[acol-1]:=true;//colmarkcolor[acol-1]:=markcolor;
end;

function TMydbgrid.dellMarkTitle(const Acol: integer): boolean;
begin
  result:=true;
  if (Columns.Count=0)or(Acol>columns.Count)or(Acol<0) then exit(false);
  colmark[acol-1]:=false;//colmarkcolor[acol]:=FixedColor;
end;

procedure TMydbgrid.initialArray;
var i:integer;
begin
   if (colmark=nil) or (filter=nil) then
  begin
    if datasource<>nil then    datasource.DataSet.OnFilterRecord:=@FilterRecord;
    setlength(colmark,columns.Count);
    setlength(filter,columns.Count);
    for i:=0 to high(colmark) do
    begin
    colmark[i]:=false;
    end;
  end;
end;

procedure TMydbgrid.FilterRecord(DataSet: TDataSet; var Accept: Boolean);
var stmp:string;
  i:integer;
  btmp:boolean;
  function FindFilterPole(FieldName:string):integer;
  var i:integer;
  begin
    result:=-1;
    for i:=0 to Columns.Count-1 do
    begin
         if columns.Items[i].FieldName=FieldName then
         begin
           result:=i;
           break;
         end;
    end;
  end;

begin
  if FEnabledMarkFiltr then
  begin
    if filter=nil then
    begin
     // FcountFilterRow:=0;
      exit;
    end;
  btmp:=true;
  for i:=0 to Columns.Count-1 do
  if utf8length(filter[FindFilterPole(dataset.Fields[i].FieldName)])<>0 then
  begin
       //stmp:=utf8lowercase(columns.Items[i].Field.AsString);
    stmp:=utf8lowercase(dataset.Fields[i].AsString);
    if softfind then btmp:=btmp and(pos(utf8lowercase(trim(filter[FindFilterPole(dataset.Fields[i].FieldName)])),stmp)>0)
    else btmp:=btmp and(pos(utf8lowercase(trim(filter[i])),stmp)=1);
  end;
  Accept:=btmp;
  end {else FcountFilterRow:=0};
end;


end.

