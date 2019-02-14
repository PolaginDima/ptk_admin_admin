unit TDBSlovariTemplateForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ActnList,
  ComCtrls,  db,lazutf8, LCLType, StdCtrls, ExtCtrls, myDBGrid,sqldb, DbCtrls,
  DBDateTimePicker;


type
  ProcGen=procedure(generator, IDPole:string; Q:TSQLQuery);
  ProcBeforeShow=procedure(var F:TForm);
  ProcOnEditButtonClick=procedure(var F:TForm;var O:TObject);
 // procO2=procedure(var F:TForm;var O:TObject);

  { TDBTemplateForm }

  TDBTemplateForm = class(TForm)
    Aadding: TAction;
    AUpLoad: TAction;
    AUpdating: TAction;
    ActionList1: TActionList;
    ADeleting: TAction;
    AEditing: TAction;
    Aselect: TAction;
    Edit1: TEdit;
    ImageList1: TImageList;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton21: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    DBGR:TMydbgrid;
    procedure AaddingExecute(Sender: TObject);
    procedure ADeletingExecute(Sender: TObject);
    procedure AEditingExecute(Sender: TObject);
    procedure AselectExecute(Sender: TObject);
    procedure AUpdatingExecute(Sender: TObject);
    procedure AUpLoadExecute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    //FDS: Tdatasource;
    FDSV: Tdatasource;
    FG: string;
    FIDPole: string;
    FP: ProcGen;
    //FPF: procF;
    FPoB: ProcOnEditButtonClick;
    Fresult_vibor: integer;
    qrV: tsqlquery;
   // FPoB2: procO2;
    { private declarations }
    tr:TSQLTransaction;
    QR:tsqlquery;
    procedure SetG(AValue: string);
    procedure SetIDPole(AValue: string);
    procedure SetP(AValue: ProcGen);
    //procedure SetPF(AValue: ProcBeforeShow);
    procedure myOnEditButtonClick(Sender: TObject);
    procedure SetPoB(AValue: ProcOnEditButtonClick);
   // procedure SetPoB2(AValue: procO2);
    procedure Setqr(AValue: tsqlquery);
    procedure SetqrV(AValue: tsqlquery);
    procedure Setresult_vibor(AValue: integer);
    procedure Settr(AValue: tsqltransaction);
  public
    { public declarations }
    property trr:tsqltransaction read tr write Settr;
    property qrr:tsqlquery read qr write Setqr;
    property qrrV:tsqlquery read qrV write SetqrV;
    property ProcGenerator:ProcGen read FP write SetP;
    property ProcOnEditButtonClick:ProcOnEditButtonClick read FPoB write SetPoB;
    //property PoB2:procO2 read FPoB2 write SetPoB2;
    property Generator:string read FG write SetG;
    property IDPole:string read FIDPole write SetIDPole;
   // property PF:procF read FPF write SetPF;
   property DSV:Tdatasource read FDSV write FDSV;
   property result_vibor:integer read Fresult_vibor write Setresult_vibor default -1;
  end;


var
  DBTemplateForm: TDBTemplateForm;
  //function ShowGridSlovari(sCaption:string;ds:tdatasource;TRANSACTION:TSQLTransaction;QUERY:tsqlquery;select:boolean=false):integer;
  function ShowGridSlovari(sCaption:string;TRANSACTION:TSQLTransaction;QUERY:tsqlquery;QUERYVIEW:tsqlquery;ProcGenerator:ProcGen;Generator, IDP:string;
    ProcBeforeShow:ProcBeforeShow;ProcOnEditButtonClick:ProcOnEditButtonClick;{PrO2:procO2;} const select:boolean=false;const QreadOnly:boolean=false):integer;

implementation
uses tdbeditslovari, createDOC;
var
  result_vibor:integer;
function ShowGridSlovari(sCaption: string; TRANSACTION: TSQLTransaction;
  QUERY: tsqlquery; QUERYVIEW: tsqlquery; ProcGenerator: ProcGen; Generator,
  IDP: string; ProcBeforeShow: ProcBeforeShow;
  ProcOnEditButtonClick: ProcOnEditButtonClick; const select: boolean;
  const QreadOnly: boolean): integer;

begin
  if QUERY=nil then exit;


  DBTemplateForm:=TDBTemplateForm.Create(application);
  DBTemplateForm.dsv:=tdatasource.Create(nil);
  DBTemplateForm.trr:=transaction;
  //tr:=transaction;
  DBTemplateForm.qrr:=query;
  if QUERYVIEW=nil then
     begin
          DBTemplateForm.qrrV:=query;
     end else
     begin
          DBTemplateForm.qrrV:=QUERYVIEW;
     end;
    { DBTemplateForm.qrrV.Close;
     DBTemplateForm.qrrV.ReadOnly:=true;}
      //DBTemplateForm.qrrV.Open;
  DBTemplateForm.dsv.DataSet:=DBTemplateForm.qrrv;
   result:=-1;
   result_vibor:=-1;
//  with  DBTemplateForm do
 // begin
  try
  //Создадим таймер
  //Загрузим наборы данных
  //если форма загружена для выбора, то отобразим кнопку выбора
  DBTemplateForm.Aselect.visible:=select;
  DBTemplateForm.Aadding.Enabled:=true;
  DBTemplateForm.AEditing.Enabled:=not DBTemplateForm.qrr.IsEmpty;
  DBTemplateForm.ADeleting.Enabled:=not DBTemplateForm.qrr.IsEmpty;
  if QreadOnly then
        begin
             DBTemplateForm.Aadding.Visible:=false;
             DBTemplateForm.AEditing.Visible:=false;
             DBTemplateForm.ADeleting.Visible:=false;
        end;
  DBTemplateForm.Caption:=sCaption;
  DBTemplateForm.ProcGenerator:=ProcGenerator;
  DBTemplateForm.ProcOnEditButtonClick:=ProcOnEditButtonClick;
  //DBTemplateForm.PoB2:=PrO2;
  DBTemplateForm.Generator:=Generator;
  DBTemplateForm.IDPole:=IDP;
  //DBTemplateForm.Name:='form'+inttostr(nomerF);
  /////////////
   //Создадим свой компонент потомок от DBGRID
   //с возможностью разукрашивать заголовки
   DBTemplateForm.DBGR:=TMydbgrid.Create(DBTemplateForm.Owner);
  DBTemplateForm.dbgr.Parent:=DBTemplateForm;
  DBTemplateForm.dbgr.ReadOnly:=true;
  DBTemplateForm.dbgr.Align:=alTop;
  DBTemplateForm.dbgr.DataSource:=DBTemplateForm.dsv;//ds;
  DBTemplateForm.dbgr.SQLQUERYdop:=DBTemplateForm.qrrV;
  DBTemplateForm.dbgr.OnEditButtonClick:=@DBTemplateForm.myOnEditButtonClick;
  //DBTemplateForm.dbgr.DataSource:=QUERY.DataSource;//ds;
  ////////////

  //qr.ReadOnly:=true;
  //qr:=query;
   //Обнулим фильтр
  DBTemplateForm.qrr.Filtered:=false;
  DBTemplateForm.qrr.Filter:='';
  DBTemplateForm.dbgr.Height:=200;
  DBTemplateForm.dbgr.Top:=30;
  //dbgr.ReadOnly:=true;
  DBTemplateForm.dbgr.Visible:=true;
  DBTemplateForm.dbgr.FiltrMarkColor:=clBlue;//Цвет разукрашенного заголовка
  DBTemplateForm.dbgr.FiltrMarkFontColor:=clwhite;//Цвет букв разукрашенного заголовка
  DBTemplateForm.dbgr.EnabledMarkFiltr:=true;//Включаем фльтрацию и подсветку
  //dbgr.OnEditButtonClick:=@myOnEditButtonClick;
  if ProcBeforeShow<>nil then ProcBeforeShow(DBTemplateForm); //дополнительная процедура которая может что-то настроить/сделать
  //на форме и с её компонентами перед её отображением
  DBTemplateForm.result_vibor:=-1;//Значит ни чего не выбрано
  DBTemplateForm.showmodal;
  result:=DBTemplateForm.result_vibor; //result_vibor;
  finally
  DBTemplateForm.free;
  //QUERY.Free;
  //DS.Free;
end;
  //end;
end;

{$R *.lfm}

procedure TDBTemplateForm.FormShow(Sender: TObject);
begin
  dbgr.Align:=alTop;
  edit1.Top:=0;
end;

procedure TDBTemplateForm.SetP(AValue: ProcGen);
begin
  if FP=AValue then Exit;
  FP:=AValue;
end;

{procedure TDBTemplateForm.SetPF(AValue: ProcBeforeShow);
begin
  //if FPF=AValue then Exit;
  //FPF:=AValue;
end;  }

procedure TDBTemplateForm.myOnEditButtonClick(Sender: TObject);
begin
  if ProcOnEditButtonClick<>nil then
  begin
       ProcOnEditButtonClick(self, Sender);
  end;
end;

procedure TDBTemplateForm.SetPoB(AValue: ProcOnEditButtonClick);
begin
  if FPoB=AValue then Exit;
  FPoB:=AValue;
end;

 {
procedure TDBTemplateForm.SetPoB2(AValue: procO2);
begin
  if FPoB2=AValue then Exit;
  FPoB2:=AValue;
end;
   }
procedure TDBTemplateForm.Setqr(AValue: tsqlquery);
begin
  if qr=AValue then Exit;
  qr:=AValue;
end;

procedure TDBTemplateForm.SetqrV(AValue: tsqlquery);
begin
  if qrV=AValue then Exit;
  qrV:=AValue;
end;

procedure TDBTemplateForm.Setresult_vibor(AValue: integer);
begin
  if Fresult_vibor=AValue then Exit;
  Fresult_vibor:=AValue;
end;

procedure TDBTemplateForm.Settr(AValue: tsqltransaction);
begin
  if tr=AValue then Exit;
  tr:=AValue;
end;


procedure TDBTemplateForm.SetG(AValue: string);
begin
  if FG=AValue then Exit;
  FG:=AValue;
end;

procedure TDBTemplateForm.SetIDPole(AValue: string);
begin
  if FIDPole=AValue then Exit;
  FIDPole:=AValue;
end;

procedure TDBTemplateForm.AselectExecute(Sender: TObject);
begin
  self.result_vibor:=self.qrrV.FieldByName('ID').AsInteger;
  self.Close;
end;

procedure TDBTemplateForm.AUpdatingExecute(Sender: TObject);
type
  setqr_=record
  //setgr=record
    width:integer;
    DisplayLabel:string;
    Visible:boolean;
  end;
  var
    stqr,stqrv:array of setqr_;
    recn, i, j:integer ;
begin
  setlength(stqr,self.qrr.FieldCount);
  setlength(stqrv,self.qrrV.FieldCount);
           for j:=0 to self.qrrV.FieldCount-1 do
           begin
                stqrv[j].width:=self.qrrV.Fields.Fields[j].DisplayWidth;
                stqrv[j].DisplayLabel:=self.qrrV.Fields.Fields[j].DisplayLabel;
                stqrv[j].Visible:=self.qrrV.Fields.Fields[j].Visible;
           end;
           for j:=0 to self.qrr.FieldCount-1 do
           begin
                stqr[j].width:=self.qrr.Fields.Fields[j].DisplayWidth;
                stqr[j].DisplayLabel:=self.qrr.Fields.Fields[j].DisplayLabel;
                stqr[j].Visible:=self.qrr.Fields.Fields[j].Visible;
           end;
           self.qrrV.DisableControls;
           i:=self.qrrV.FieldByName('ID').AsInteger;
           recn:=self.qrrv.RecNo;
           self.trr.Commit;
           self.qrr.Open;
           self.qrrV.Open;
           if not self.qrrV.Locate('ID',i,[]) then
           begin
                if (not self.qrrV.IsEmpty) then
                begin
                     if (recn<=self.qrrV.RecordCount) then
                self.qrrV.RecNo:=recn else
                  self.qrrV.RecNo:=recn-1;
                end;
           end;
            for j:=0 to self.qrrV.FieldCount-1 do
            begin
                 self.qrrV.Fields.Fields[j].DisplayWidth:=stqrv[j].width;
                 self.qrrV.Fields.Fields[j].DisplayLabel:=stqrv[j].DisplayLabel;
                 self.qrrV.Fields.Fields[j].Visible:=stqrv[j].Visible;
            end;
            for j:=0 to self.qrr.FieldCount-1 do
            begin
                 self.qrr.Fields.Fields[j].DisplayWidth:=stqr[j].width;
                 self.qrr.Fields.Fields[j].DisplayLabel:=stqr[j].DisplayLabel;
                 self.qrr.Fields.Fields[j].Visible:=stqr[j].Visible;
            end;
           self.qrrV.EnableControls;
           stqr:=nil;
           stqrv:=nil;
           finalize(stqr);
           finalize(stqrv);
end;

procedure TDBTemplateForm.AUpLoadExecute(Sender: TObject);
  var myDOCS:TmyDOCS;
begin
  try
              myDOCS:=TmyDOCS.Create(ttaKart_Slovar,ExtractFilePath(Application.ExeName),self.qrV, self.Caption);
              //Тут всякие действия
              myDOCS.Free;
            except
               on E: Exception do
               begin
                       if (utf8pos('файл не найден',UTF8lowercase( e.message))>0) then
                      begin
                       MessageDlg('Ошибка',e.Message,mtError,[mbOK],0)
                      end else  MessageDlg('неизвестная ошибка',e.Message,mtError,[mbOK],0) ;
               end;
            end;
end;

procedure TDBTemplateForm.Button1Click(Sender: TObject);
begin
  //dbgr.addMarkTitle(100);
end;

procedure TDBTemplateForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin

  //if qr.Modified then
 // if ds.DataSet.Modified then
 // begin
   // QR.ApplyUpdates;
   // TR.Commit;
 // end;
 //tr.Free;
 // qr.Free;
 //DBGR.Free;
  CloseAction:=cafree;
end;

procedure TDBTemplateForm.AaddingExecute(Sender: TObject);
var I, J:integer;
  l:tlabel;
  edit:tdbedit;
  lookup:tdblookupcombobox;
  dstmp:tdatasource;
  dbdt:tdbdatetimepicker;
  ds:tdatasource;
begin
  if dbgr.DataSource=nil then exit;
  //DBTemplateForm.qrr.Locate('ID',DBTemplateForm.qrrV.FieldByName('ID').AsString,[]);
  //qr.ReadOnly:=false;
  dstmp:=nil;
  J:=0;
  DBEditSlovar:=TDBEditSlovar.Create(application);
  ds:=tdatasource.Create(DBEditSlovar.Owner);
  ds.DataSet:=self.qrr;
  DBEditSlovar.Caption:='добавление';
  //if  qr.CanModify  then  DBEditSlovar.Caption:=DBEditSlovar.Caption+' изменяемый';
  with  DBEditSlovar do
  begin

    //Все колонки справочника
    //for i:=0 to  ds.DataSet.Fields.Count-1 do
    for i:=0 to qrr.Fields.Count-1 do
    begin
    if (not  qrr.Fields.Fields[i].Visible) or (qr.Fields.Fields[i].FieldKind=fkCalculated)then continue;
    //Подпись для поля
    l:=tlabel.Create(DBEditSlovar.Owner);
    //Задаем параметры
    l.Parent:=DBEditSlovar;
    l.Transparent:=true;
    l.Left:=8;l.Top:=(j+1)*8+j*21+2;
    l.AutoSize:=true;
    l.Caption:=qrr.Fields.Fields[i].DisplayName;
    //dblookup
    if qrr.Fields[i].FieldKind=fkLookup then
    begin
         if qrr.Fields.Fields[i].Required then
         begin
              //Звездочка для обязательного поля
              l:=tlabel.Create(DBEditSlovar.Owner);
              //Задаем параметры
              l.Parent:=DBEditSlovar;
              l.Transparent:=true;
              l.Left:=240;l.Top:=(j+1)*8+j*21;
              l.AutoSize:=true;
              l.Caption:='*';
              l.Font.Color:=clred;
         end;

      lookup:=tdblookupcombobox.Create(DBEditSlovar.Owner);
      lookup.Parent:=DBEditSlovar;
      lookup.Left:=250;lookup.Width:=250;
      lookup.Top:=(j+1)*8+j*21;
      lookup.Style:=csDropDownList;
      lookup.Sorted:=true;
      lookup.AutoComplete:=true;
      lookup.AutoDropDown:=true;
      //lookup.ScrollListDataset:=true;
      //lookup.Style:=csDropDownList;
      lookup.TabOrder:=j;
      //lookup.Name:='dincomp'+inttostr(j);
      lookup.DataSource:=ds;
      dstmp:=tdatasource.Create(DBEditSlovar.Owner);
      //dstmp.Name:='myDataSet'+inttostr(j);
      dstmp.DataSet:=qrr.Fields.Fields[i].LookupDataSet;
      lookup.ListSource:=dstmp;
      lookup.DataField:=qrr.Fields.Fields[i].KeyFields;
      lookup.KeyField:=qrr.Fields[i].LookupKeyFields;
      lookup.ListField:=qrr.Fields[i].LookupResultField;
      dstmp.DataSet:=nil;
      dstmp:=nil;
      J:=J+1;
      continue;
    end;
    if qrr.Fields.Fields[i].DataType=ftDate then
    begin
      if qrr.Fields.Fields[i].Required then
         begin
              //Звездочка для обязательного поля
              l:=tlabel.Create(DBEditSlovar.Owner);
              //Задаем параметры
              l.Parent:=DBEditSlovar;
              l.Transparent:=true;
              l.Left:=240;l.Top:=(j+1)*8+j*21;
              l.AutoSize:=true;
              l.Caption:='*';
              l.Font.Color:=clred;
         end;
      dbdt:=tdbdatetimepicker.Create(DBEditSlovar.Owner);
      dbdt.Parent:=DBEditSlovar;
      dbdt.Left:=250;dbdt.Top:=(j+1)*8+j*21; dbdt.Width:=250;
      dbdt.DataSource:=ds;
      dbdt.DataField:=qrr.Fields[i].FieldName;
      dbdt.Visible:=true;
      J:=J+1;
    continue;
    end;
  {  if ds.DataSet.Fields.Fields[i].FieldKind<>fkCalculated then
    begin  }
    if qrr.Fields.Fields[i].Required then
         begin
              //Звездочка для обязательного поля
              l:=tlabel.Create(DBEditSlovar.Owner);
              //Задаем параметры
              l.Parent:=DBEditSlovar;
              l.Transparent:=true;
              l.Left:=240;l.Top:=(j+1)*8+j*21;
              l.AutoSize:=true;
              l.Caption:='*';
              l.Font.Color:=clred;
         end;
    //Для остальных создаем dbbedit
    edit:=tdbedit.Create(DBEditSlovar.Owner);
    edit.Parent:=DBEditSlovar;
    edit.Left:=250;edit.Width:=250;
    edit.Top:=(j+1)*8+j*21;
    edit.TabOrder:=j;
    edit.CharCase:=ecNormal;
    edit.DataSource:=ds;
    edit.DataField:=qrr.Fields.Fields[i].FieldName;
    J:=J+1;
    continue;
   { end;  }
    end;
    DBEditSlovar.Height:=(j+1)*8+j*21+21+34+8;
    DBEditSlovar.Button2.Top:=(j+1)*8+j*21+21;DBEditSlovar.Button1.Top:=DBEditSlovar.Button2.Top;
    qr.Insert;
    DBEditSlovar.ProcGenerator:=self.ProcGenerator;
    DBEditSlovar.DDS:=ds;
    DBEditSlovar.QQR:=qr;
    DBEditSlovar.Generator:=self.Generator;
    DBEditSlovar.IDPole:=self.IDPole;

    showmodal;

    if  DBEditSlovar.ModalResult=mrok then
    begin
         self.AUpdatingExecute(self);
    end else
    begin
    ds.DataSet.Cancel;
    end;

    if dstmp<>nil then
    begin

    try
      dstmp.Free;
      finally
      end;
    end;
    if ds<>nil then
    begin

      try
      ds.Free;
      finally
      end;
    end;
    if DBEditSlovar<>nil then
    begin
    try
      Free;
      finally
      end;
     end;
    //dstmp:=nil ;//dstmp.Free;

  end;
  {
  //qr.ReadOnly:=false;
  qr.Insert;
  P(G,self.IDPole ,qr);
  //tdbeditslovari.ShowEditSlovari('добавление',dbgr.DataSource,qr);
  //qr.ReadOnly:=true;  }

end;

procedure TDBTemplateForm.ADeletingExecute(Sender: TObject);
begin
  //Пометка на удаление и удаление при выходе
  if self.qrr.IsEmpty then exit;
  if messagedlg('','удалить запись?',mtInformation ,[mbOK, mbCancel],0)=mrok then
  begin
  try
    self.qrr.Locate('ID',self.qrrv.FieldByName('ID').AsString,[]);
    self.qrr.delete;
    self.qrr.ApplyUpdates;
    self.AUpdatingExecute(self);
  except
     on E: Exception do
           begin
           self.qrr.CancelUpdates;
                if (pos('fk_start_work_peopl',UTF8lowercase( e.message))>0) then
                begin
                     MessageDlg('Ошибка','Этот человек принят на работу!',mtInformation,[mbOK],0)
                end else  MessageDlg('Неизвестная ошибка',e.Message,mtError,[mbOK],0) ;
           end;
  end;
  end;
end;

procedure TDBTemplateForm.AEditingExecute(Sender: TObject);
var I, J:integer;
  l:tlabel;
  edit:tdbedit;
  lookup:tdblookupcombobox;
  dstmp:tdatasource;
  dbdt:tdbdatetimepicker;
  ds:tdatasource;
begin
   if dbgr.DataSource=nil then exit;
   if self.qrr.IsEmpty then exit;
   self.qrr.Locate('ID',self.qrrV.FieldByName('ID').AsString,[]);
  //qr.ReadOnly:=false;
  dstmp:=nil;
  J:=0;
  DBEditSlovar:=TDBEditSlovar.Create(application);
  ds:=tdatasource.Create(DBEditSlovar.Owner);
  ds.DataSet:=self.qrr;
  DBEditSlovar.Caption:='редактирование';
  with  DBEditSlovar do
  begin

    //Все колонки справочника
    //for i:=0 to  ds.DataSet.Fields.Count-1 do
    for i:=0 to qr.Fields.Count-1 do
    begin
    if (not  qr.Fields.Fields[i].Visible) or (qr.Fields.Fields[i].FieldKind=fkCalculated)then continue;
    //Подпись для поля
    l:=tlabel.Create(DBEditSlovar.Owner);
    //Задаем параметры
    l.Parent:=DBEditSlovar;
    l.Transparent:=true;
    l.Left:=8;l.Top:=(j+1)*8+j*21+2;
    l.AutoSize:=true;
    l.Caption:=qr.Fields[i].DisplayName;
    //dblookup
    if qr.Fields[i].FieldKind=fkLookup then
    begin
      lookup:=tdblookupcombobox.Create(DBEditSlovar.Owner);
      lookup.Parent:=DBEditSlovar;
      lookup.Left:=250;lookup.Width:=250;
      lookup.Top:=(j+1)*8+j*21;
      lookup.Style:=csDropDownList;
      lookup.Sorted:=true;
      lookup.AutoComplete:=true;
      lookup.AutoDropDown:=true;
      //lookup.ScrollListDataset:=true;
      //lookup.Style:=csDropDownList;
      lookup.TabOrder:=j;
      //lookup.Name:='dincomp'+inttostr(j);
      lookup.DataSource:=ds;
      dstmp:=tdatasource.Create(DBEditSlovar.Owner);
      //dstmp.Name:='myDataSet'+inttostr(j);
      dstmp.DataSet:=qr.Fields.Fields[i].LookupDataSet;
      lookup.ListSource:=dstmp;
      lookup.DataField:=qr.Fields.Fields[i].KeyFields;
      //showmessage(ds.DataSet.Fields[i].LookupKeyFields);
      lookup.KeyField:=qr.Fields[i].LookupKeyFields;
      lookup.ListField:=qr.Fields[i].LookupResultField;
      dstmp.DataSet:=nil;
      dstmp:=nil;
      J:=J+1;
      continue;
    end;
    if qr.Fields.Fields[i].DataType=ftDate then
    begin
      dbdt:=tdbdatetimepicker.Create(DBEditSlovar.Owner);
      dbdt.Parent:=DBEditSlovar;
      dbdt.Left:=250;dbdt.Top:=(j+1)*8+j*21; dbdt.Width:=250;
      dbdt.DataSource:=ds;
      dbdt.DataField:=qr.Fields[i].FieldName;
      dbdt.Visible:=true;
      J:=J+1;
    continue;
    end;
  {  if ds.DataSet.Fields.Fields[i].FieldKind<>fkCalculated then
    begin  }
    //Для остальных создаем dbbedit
    edit:=tdbedit.Create(DBEditSlovar.Owner);
    edit.Parent:=DBEditSlovar;
    edit.Left:=250;edit.Width:=250;
    edit.Top:=(j+1)*8+j*21;
    edit.TabOrder:=j;
    edit.CharCase:=ecNormal;
    edit.DataSource:=ds;
    edit.DataField:=qr.Fields[i].FieldName;
    J:=J+1;
    continue;
   { end;  }
    end;
     DBEditSlovar.Height:=(j+1)*8+j*21+21+34+8;
    DBEditSlovar.Button2.Top:=(j+1)*8+j*21+21;DBEditSlovar.Button1.Top:=DBEditSlovar.Button2.Top;
    DBEditSlovar.ProcGenerator:=self.ProcGenerator;
    DBEditSlovar.DDS:=ds;
    DBEditSlovar.QQR:=qr;
    DBEditSlovar.Generator:=self.Generator;
    DBEditSlovar.IDPole:=self.IDPole;
    showmodal;
    if  DBEditSlovar.ModalResult=mrok then
    begin
    self.AUpdatingExecute(self);
    end else
    begin
    ds.DataSet.Cancel;
    end;

   // for i:=0 to DBEditSlovar.Panel1.ComponentCount-1 do    DBEditSlovar.Panel1.Components[i].Free;
    if dstmp<>nil then
    begin
     { dstmp.dataset:=nil;
      dstmp:=nil;}
     try
      dstmp.Free;
      finally
      end;
    end;
    if ds<>nil then
    begin
     { dstmp.dataset:=nil;
      dstmp:=nil;}
      try
      ds.Free;
      finally
      end;
    end;
     if DBEditSlovar<>nil then
    begin
    try
      Free;
      finally
      end;
     end;
    //dstmp:=nil ;//dstmp.Free;

  end;
  {
  //qr.ReadOnly:=false;
  qr.Insert;
  P(G,I,qr);
  tdbeditslovari.ShowEditSlovari('добавление',dbgr.DataSource,qr);
  //qr.ReadOnly:=true;
  }

  ///////////////////////////
 // tdbeditslovari.ShowEditSlovari('редактирование',dbgr.DataSource,qr);//dbgr.DataSource);
end;

end.

