unit createDOC;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DIALOGS, VARIANTS, comobj, workinooandms, LCLProc,sqldb, fileutil, dateutils;
type

  //Главный предок всех классов для вывода актов
//В нем соберем все основные свойства, методы общие для всех классов

 { TmyDOCS }

 TmyDOCS=class(TmyWordWriteExcelCalc)
  type Ttip_doc=(ttaAKT_DELMNI, ttaZaiv_SERT, ttaAkt_MNI, ttaAkt_KRIPT, ttaSved_KRIPT, ttaDel_KRIPT,
  ttaOtchet_Del_KRIPT, ttaKart_Slovar, ttaZaiv_Sviaz, ttaKART_TEHN, ttaZaiv_Otziv, ttaZaiv_Pause);
   private
     FQuery: Tsqlquery;
     DopInfo:string;
     const          stringmonth:array[1..12] of string=('январь','февраль','март','апрель','май','июнь',
         'июль','август','сентябрь','октябрь','ноябрь','декабрь');
     procedure SetQuery(AValue: Tsqlquery);
     procedure selectAction(const tip_doc: Ttip_doc;const filepath: string);
     function MonthIntToStr(nMonth:integer):string;
     procedure CreateDocs(const tip_doc: Ttip_doc;nameShablon, sdir:string);
   protected
   public
     constructor Create(const tip_doc:Ttip_doc;const exefilepath:string;Qr:Tsqlquery;dop:string='');
     //constructor OpenDOC(tip_doc:Ttip_doc);override;
     destructor Destroy;override;
     property Query:Tsqlquery read FQuery write SetQuery;
 end;

implementation
//uses workbd;
{ TmyDOCS }

procedure TmyDOCS.SetQuery(AValue: Tsqlquery);
begin
  if FQuery=AValue then Exit;
  FQuery:=AValue;
end;

procedure TmyDOCS.selectAction(const tip_doc: Ttip_doc; const filepath: string);
var  oTable:variant;
  oInsertPoint:variant;
  rows,row, cols,col:variant;
  cell:variant;
  cellcursor:variant;
  //oTblColSeps:variant;  //Массив разделителей столбцов таблицы
  i,j:integer;
  w:widestring;//ansistring;
  oDescriptor:variant;
  stmp, stmp1, stmp2:string;
begin
  stmp:='';stmp1:='';stmp2:='';
  case  tip_doc of
  ttaKart_Slovar:begin
                     //Вставим таблицу
                     //REM Позволим документу создать текстовую таблицу
                     oTable:=self.Document.createinstance('com.sun.star.text.TextTable');
                     oTable.initialize(1,3);
  //REM Если есть закладка по имени "InsertTableHere", то вставим таблицу
// в том месте. Если эта закладка не существует, то просто выберем
// самый конец документа.



                        { if self.Document.getbookmarks.hasbyname('TABLE') then
                         oInsertPoint:=self.Document.getbookmarks.getbyname('TABLE').getanchor
                         else }
                           oInsertPoint:= self.Document.Text.getEnd;

                         // Теперь вставим текстовую таблицу .
// Отметьте, что используется текстовый объект oInsertPoint текстовый
// диапазон, а не текстовый объект документ.
oInsertPoint.getText.insertTextContent(oInsertPoint , oTable, False);
// Метод объекта setData() работает ТОЛЬКО с числовыми данными.
// Метод объекта setDataArray(), однако, также допускает строки.
//oTable.setDataArray(Array(Array(0, "One", 2), Array(3, "Four", 5)))
oTable.setName('KARTOCHKA');
{
//Получим строки
rows:=oTable.getrows;
//Переберем строки и отформатируем
rows.getbyindex(0).backcolor:='&HDDDDDD';
for i:=1 to rows.getcount-1 do
begin
                   row:=rows.getbyindex(i);
                   row.backcolor:='&HFFFFFF';
end;  }
//Заполним таблицу
//Получим строки
rows:=oTable.getrows;
//Получим столбцы
cols:=oTable.getcolumns;
//Переберем ячейки таблицы
//Заполним шапку
//первый столбец первая строка
cell:=oTable.getCellByPosition(0,0);
w:=utf8toansi('№ п/п');
cell.setstring(w);
//второй столбец первая строка
cell:=oTable.getCellByPosition(1,0);
w:=utf8toansi('наименование'+#13+'поля');
cell.setstring(w);
//и т.д.
cell:=oTable.getCellByPosition(2,0);
w:=utf8toansi('значение'+#13+'поля');
cell.setstring(w);
//  Наименование словаря
    self.ReplaceAll('nameSl', self.DopInfo);
//Проверим есть ли что писать в таблицу
if self.FQuery.IsEmpty then
begin
  //Если нечего писать, то удалим последнюю строку
//  и выйдем из процедуры
  //rows.removebyindex(0,1);
  exit;
end;
//добавим нужное количество строк
//if self.FQuery.FieldCount>1 then rows.insertbyindex(2,self.FQuery.FieldCount-1);
j:=0;
for i:=0 to self.FQuery.FieldCount-1 do
begin
    if not self.FQuery.Fields.Fields[i].Visible then continue;
    j:=j+1;
    rows.insertbyindex(j,1);
//Заполняем ячейки строки
                   //первая ячейка
                   cell:=oTable.getCellByPosition(0,j);
                   w:=utf8toansi(inttostr(j));
                   cell.setstring(w);
                   //Вторая ячейка
                   cell:=oTable.getCellByPosition(1,j);
                   w:=utf8toansi(self.FQuery.Fields.Fields[i].DisplayLabel);
                   cell.setstring(w);
                   //и т.д.
                   cell:=oTable.getCellByPosition(2,j);
                   w:=utf8toansi(self.FQuery.Fields.Fields[i].AsString);
                   cell.setstring(w);
end;

end;


  end;
end;

function TmyDOCS.MonthIntToStr(nMonth: integer): string;
const
     strMonth:array [1..12] of string=('января','февраля','марта','апреля','мая'
     ,'июня','июля','августа','сентября','октября','ноября','декабря');
begin
  result:='';
  if (nMonth>0)and(nMonth<13) then
  result:=strMonth[nMonth];
end;

procedure TmyDOCS.CreateDocs(const tip_doc: Ttip_doc; nameShablon, sdir: string
  );
var
  spath:string;
begin
  spath:=sdir + inttostr(SecondOfTheWeek(now))+'.doc';
  copyfile(nameShablon, spath);
  self.OpenDOCwriter(spath);
  //Заполним документ
  selectAction(tip_doc, sdir);
  self.Query.Next;
end;

constructor TmyDOCS.Create(const tip_doc: Ttip_doc;
  const exefilepath: string; Qr: Tsqlquery;dop:string='');
var sdir, spath:string;
  sl:tstringlist;
  i:integer;
  nr:integer;
begin
  //создадим нужный нам документ
   //получим путь до нашего шаблона
    sdir:=exefilepath + 'data' + DirectorySeparator+'out'+DirectorySeparator;
    //почистим директорию от старых файлов
    if DirectoryExists(sdir) then
  begin
    sl:=FindAllFiles(sdir,'');
    for i:=0 to sl.Count-1 do     DeleteFile(sl.ValueFromIndex[i]);
  end else CreateDir(sdir);
  if dop<>'' then self.DopInfo:=dop;

  //Получим Query
   self.Query:=Qr;
   nr:=self.Query.RecNo;
   self.Query.Last;
   self.Query.First;
              for i:=1 to self.Query.RecordCount do
              begin
                   //spath:=sdir + inttostr(SecondOfTheWeek(now))+'.doc';
                   case tip_doc of
                    ttaKart_Slovar:
                         begin
                              self.Query.RecNo:=nr;
                              CreateDocs(tip_doc,exefilepath + 'data' + DirectorySeparator+'shablon'+DirectorySeparator+'kart_slovar.doc',sdir);
                              //copyfile(exefilepath + 'data' + DirectorySeparator+'shablon'+DirectorySeparator+'kart_slovar.doc', spath);
                              break;
                         end;
                   end;
                   {self.OpenDOCwriter(spath);
                   //Заполним документ
                   selectAction(tip_doc, sdir);
                   self.Query.Next;}
              end;
              try
                if not self.Query.IsEmpty then self.Query.RecNo:=nr;
              finally
              end;
end;

destructor TmyDOCS.Destroy;
begin
  inherited Destroy;
end;

end.

