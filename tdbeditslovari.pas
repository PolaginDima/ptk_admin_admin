unit tdbeditslovari;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, {DBDateTimePicker,} Forms, Controls, Graphics,
  StdCtrls, ExtCtrls, db, DbCtrls, sqldb, dialogs, LCLType, lclproc;

type
  ProcGen=procedure(generator, IDPole:string; Q:TSQLQuery);

  { TDBEditSlovar }

  TDBEditSlovar = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DBEditUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
  private
    eExit:boolean;
    //FCCN: TSQLConnection;
    FDDS: TDatasource;
    FG: string;
    FIDPole: string;
    FP: ProcGen;
    FQQR: TSQLQuery;
    //procedure SetCCN(AValue: TSQLConnection);
    procedure SetDDS(AValue: TDatasource);
    procedure SetG(AValue: string);
    procedure SetIDPole(AValue: string);
    procedure SetP(AValue: ProcGen);
    procedure SetQQR(AValue: TSQLQuery);
    { private declarations }
  public
    { public declarations }
    property DDS:TDatasource read FDDS write SetDDS;
    property QQR:TSQLQuery read FQQR write SetQQR;
    //property CCN:TSQLConnection read FCCN write SetCCN;
    property ProcGenerator:ProcGen read FP write SetP;
    property Generator:string read FG write SetG;
    property IDPole:string read FIDPole write SetIDPole;
  end;
  procedure ShowEditSlovari(sCaption: string; ds:tdatasource;qr:tsqlquery);
var
  DBEditSlovar: TDBEditSlovar;

implementation

procedure ShowEditSlovari(sCaption: string; ds: tdatasource;qr:tsqlquery);
begin
end;


{$R *.lfm}

{ TDBEditSlovar }

procedure TDBEditSlovar.Button1Click(Sender: TObject);
var ds_state:TDataSetState;
begin
  if fdds.DataSet.Modified then
    begin
         try
           ds_state:= fqqr.State;
           if fqqr.State=db.dsInsert then ProcGenerator(Generator,IDPole,fqqr);
           fdds.DataSet.Post;
           fqQR.ApplyUpdates;
         except
           on E: Exception do
           begin
                eexit:=false;
                if (pos('unique',lowercase( e.message))>0) then
                begin
                     fqQR.CancelUpdates;
                     MessageDlg('Ошибка','Такая запись уже есть!',mtInformation,[mbOK],0);
                     if  ds_state=db.dsInsert then
                          begin
                               fqqr.Insert;
                          end else
                          begin
                               fqqr.Edit;
                          end;
                end else if (pos('is required',lowercase( e.message))>0) then
                begin
                     MessageDlg('Ошибка','не заполненно обязательное поле!',mtInformation,[mbOK],0);
                     if  ds_state=db.dsInsert then  fqqr.Insert else  fqqr.Edit;
                end else
                    begin
                         MessageDlg('Неизвестная ошибка',e.Message,mtError,[mbOK],0) ;
                         if  ds_state=db.dsInsert then  fqqr.Insert else  fqqr.Edit;
                    end;
                //exit;
           end;
         end;
    end else
    begin
    //ds.DataSet.Cancel;
         eexit:=false;
    end;
end;

procedure TDBEditSlovar.Button2Click(Sender: TObject);
begin

end;

procedure TDBEditSlovar.DBEditUTF8KeyPress(Sender: TObject;
  var UTF8Key: TUTF8Char);
begin

end;

procedure TDBEditSlovar.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  CloseAction:=cafree;
end;

procedure TDBEditSlovar.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:= eexit;
  eexit:=true;
end;

procedure TDBEditSlovar.FormCreate(Sender: TObject);
begin
eExit:=true;
end;

procedure TDBEditSlovar.SetDDS(AValue: TDatasource);
begin
  if FDDS=AValue then Exit;
  FDDS:=AValue;
end;

{procedure TDBEditSlovar.SetCCN(AValue: TSQLConnection);
begin
  if FCCN=AValue then Exit;
  FCCN:=AValue;
end; }

procedure TDBEditSlovar.SetG(AValue: string);
begin
  if FG=AValue then Exit;
  FG:=AValue;
end;

procedure TDBEditSlovar.SetIDPole(AValue: string);
begin
  if FIDPole=AValue then Exit;
  FIDPole:=AValue;
end;

procedure TDBEditSlovar.SetP(AValue: ProcGen);
begin
  if FP=AValue then Exit;
  FP:=AValue;
end;

procedure TDBEditSlovar.SetQQR(AValue: TSQLQuery);
begin
  if FQQR=AValue then Exit;
  FQQR:=AValue;
end;

end.

