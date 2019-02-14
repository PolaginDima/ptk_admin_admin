unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, IBConnection, FBAdmin, FileUtil, Forms,
  Controls, Graphics, lazutf8, Dialogs, DBGrids, StdCtrls, DbCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button2: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    DataSource3: TDataSource;
    DataSource4: TDataSource;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    DBGrid1: TDBGrid;
    DBLookupComboBox1: TDBLookupComboBox;
    DBLookupComboBox2: TDBLookupComboBox;
    FBAdmin1: TFBAdmin;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ListBox1: TListBox;
    OpenDialog1: TOpenDialog;
    SQLConnector1: TSQLConnector;
    SQLQuery1: TSQLQuery;
    SQLQuery2: TSQLQuery;
    SQLQuery3: TSQLQuery;
    SQLQuery3FAM: TStringField;
    SQLQuery3ID: TLongintField;
    SQLQuery3ID_RAION: TLongintField;
    SQLQuery3ID_ROLE: TLongintField;
    SQLQuery3NAM: TStringField;
    SQLQuery3NAME: TStringField;
    SQLQuery3OTCH: TStringField;
    SQLQuery4: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    SQLTransaction2: TSQLTransaction;
    StringField1: TStringField;
    StringField2: TStringField;
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
    const shbln='qwertyuiopasdfghjklzxcvbnm';
    const shbln2='0123456789';
    procedure zapolnenie_user_serv;
  public
    { public declarations }
  end;

  procedure Zapolnenie(generator, IDPole: string; Q: TSQLQuery);
  function CreateGUID(generator: string; DB: TDataBase): integer;var
  Form1: TForm1;

implementation
uses TDBSlovariTemplateForm;

procedure Zapolnenie(generator, IDPole: string; Q: TSQLQuery);

begin
  Q.FieldByName(IDPole).AsInteger:= CreateGUID(generator,q.DataBase);
end;

function CreateGUID(generator: string; DB: TDataBase): integer;
var SQLQUERY:TSQLQuery;
  SQLTransaction:TSQLTransaction;
begin
     //Получим значение ID
  sqlquery:=tsqlquery.Create(nil);
  SQLTransaction:=tSQLTransaction.Create(nil);
  SQLTransaction.DataBase:=db;
  sqlquery.DataBase:=db;
  sqlquery.Transaction:=SQLTransaction;
  sqlquery.SQL.Clear;
  sqlquery.SQL.Add('select * from CreateID('''+generator+''')'); //GEN_ID_ - имя генератора
  sqlquery.Open;
  result:=sqlquery.Fields.Fields[0].AsInteger;
  sqlquery.Close;
  sqltransaction.Commit;
  sqltransaction.Free;
  sqlquery.Free;
end;

//var roles:array[0..1] of string;
{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  if opendialog1.Execute then
  begin
    SQLConnector1.DatabaseName:=opendialog1.FileName;
    if utf8uppercase(ExtractFileName( SQLConnector1.DatabaseName))<>'PTK_ADMIN.FDB' then application.Terminate;
    SQLQUERY1.Open;
    SQLQUERY3.Open;
    zapolnenie_user_serv;
  end else application.Terminate;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin

end;

procedure TForm1.zapolnenie_user_serv;
var i:integer;
list_users_serv:tstringlist;
begin
   //Получим всех юзеров сервера
  list_users_serv:=tstringlist.Create;
  fbadmin1.Connect;
  fbadmin1.GetUsers(list_users_serv);
  fbadmin1.DisConnect;
  listbox1.Clear;
  for i:=1 to  list_users_serv.Count do
  if utf8pos('PTK_ADMIN_',list_users_serv.Strings[i-1])>0 then listbox1.items.add(list_users_serv.Strings[i-1]);
  if self.ListBox1.Count>0 then self.ListBox1.Selected[0];
  list_users_serv.Free;
end;

procedure TForm1.Button10Click(Sender: TObject);
var
   list_users_serv:tstringlist;
   pwd:string;
begin
  if self.SQLQuery3.IsEmpty then exit;
  //Получим всех юзеров сервера
  list_users_serv:=tstringlist.Create;
  fbadmin1.Connect;
  fbadmin1.GetUsers(list_users_serv);
  fbadmin1.DisConnect;
  pwd:=PasswordBox('пароль пользователя','Введите пароль пользователя'+lineending+
  '8 символов');
  if (utf8length(pwd)<=0) or (utf8length(pwd)<>8) then
  begin
       list_users_serv.Free;
       exit;
  end;
  if list_users_serv.IndexOf('ptk_admin_'+self.SQLQuery3.FieldByName('name').AsString)=-1 then
     begin
          //добавим пользователя на сервер
          fbadmin1.Connect;
          //showmessage('ptk_admin_'+self.SQLQuery3.FieldByName('name').AsString);
          fbadmin1.AddUser('ptk_admin_'+trim(self.SQLQuery3.FieldByName('name').AsString),pwd);
          fbadmin1.DisConnect;
          messagedlg('','Успех',mtInformation,[mbok],0);
     end else messagedlg('','Пользователь уже есть',mtInformation,[mbok],0)     ;
     list_users_serv.Free;
  zapolnenie_user_serv;
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
  fbadmin1.Connect;
  try
    if fbadmin1.DeleteUser(self.ListBox1.Items.Strings[self.ListBox1.ItemIndex])=false then
    begin
      MessageDlg('предупреждение','не удалось удалить пользователя'+lineending+
      'на сервере.',mtInformation,[mbok],'');
    end;

  finally
    fbadmin1.DisConnect;
  end;
  zapolnenie_user_serv;
end;

procedure TForm1.Button12Click(Sender: TObject);
var
   pwd:string;
begin
  pwd:=PasswordBox('пароль пользователя','Введите пароль пользователя'+lineending+
  '8 символов');
  if utf8length(pwd)<=0 then exit;
  //удаляем на сервере
  fbadmin1.Connect;
  try
    if fbadmin1.DeleteUser(self.ListBox1.Items.Strings[self.ListBox1.ItemIndex])=false then
    begin
      MessageDlg('предупреждение','не удалось удалить пользователя'+lineending+
      'на сервере.',mtInformation,[mbok],'');
      exit;
    end;

  finally
    fbadmin1.DisConnect;
  end;
  //добавим пользователя на сервер
          fbadmin1.Connect;
          fbadmin1.AddUser(self.ListBox1.Items.Strings[self.ListBox1.ItemIndex],pwd);
          fbadmin1.DisConnect;
          messagedlg('','Успех',mtInformation,[mbok],0);
 zapolnenie_user_serv;
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
  self.SQLQuery3.Edit;
  self.Button13.Visible:=false;
  self.Button9.Caption:='сохранить';
  self.Button8.Caption:='отменить';
  self.Button13.Visible:=true;
  self.DBEdit1.Color:=clinfobk;
  self.DBEdit2.Color:=clinfobk;
  self.DBEdit3.Color:=clinfobk;
  self.DBEdit4.Color:=clinfobk;
  self.DBLookupComboBox1.Color:=clinfobk;
  self.DBLookupComboBox2.Color:=clinfobk;
  self.DBEdit1.ReadOnly:=false;
  self.DBEdit2.ReadOnly:=false;
  self.DBEdit3.ReadOnly:=false;
  self.DBEdit4.ReadOnly:=false;
  self.DBLookupComboBox1.Enabled:=true;
  self.DBLookupComboBox2.Enabled:=true;
  self.Button1.Visible:=false;
  self.Button2.Visible:=false;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  SCRIPT:TSQLScript;
  T:TSQLTransaction;
begin
  self.SQLQuery4.Locate('ID',self.SQLQuery3.FieldByName('ID_ROLE').AsInteger,[]);
  //showmessage(self.SQLQuery4.FieldByName('rrole').AsString);exit;
  SCRIPT:=Tsqlscript.Create(self);
           script:=tsqlscript.Create(self);
           T:=TSQLTransaction.Create(self);
           t.DataBase:=self.SQLQuery3.DataBase;
           script.DataBase:=sqlquery3.DataBase;
           script.Transaction:=t;
           script.CommentsInSQL:=false;
           script.UseSetTerm:=true;
           script.Script.Clear;
           script.Script.Add('grant '+self.SQLQuery4.FieldByName('rrole').AsString+' to ptk_admin_'+self.SQLQuery3.FieldByName('name').AsString+';');
           script.Script.Add('grant AUTH to ptk_admin_'+self.SQLQuery3.FieldByName('name').AsString+';');
           script.Execute;
           t.Commit;
           script.Free;
           t.Free;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  SCRIPT:TSQLScript;
  T:TSQLTransaction;
begin
  self.SQLQuery4.Locate('ID',self.SQLQuery3.FieldByName('ID_ROLE').AsInteger,[]);
  //showmessage(self.SQLQuery4.FieldByName('rrole').AsString);exit;
  SCRIPT:=Tsqlscript.Create(self);
           script:=tsqlscript.Create(self);
           T:=TSQLTransaction.Create(self);
           t.DataBase:=self.SQLQuery3.DataBase;
           script.DataBase:=sqlquery3.DataBase;
           script.Transaction:=t;
           script.CommentsInSQL:=false;
           script.UseSetTerm:=true;
           script.Script.Clear;
           script.Script.Add('revoke '+self.SQLQuery4.FieldByName('rrole').AsString+' from ptk_admin_'+self.SQLQuery3.FieldByName('name').AsString+';');
           script.Script.Add('revoke AUTH from ptk_admin_'+self.SQLQuery3.FieldByName('name').AsString+';');
           script.Execute;
           t.Commit;
           script.Free;
           t.Free;
end;

procedure TForm1.Button7Click(Sender: TObject);
var queryraions:tsqlquery;
  trans:tsqltransaction;
begin
     //connector.Connected:=false;
     trans:=tsqltransaction.Create(self.Owner);
     trans.DataBase:=self.SQLConnector1;
     queryraions:=tsqlquery.Create(self.Owner);
     queryraions.Transaction:=trans;
     queryraions.DataBase:=self.SQLConnector1;
     queryraions.SQL.Clear;
     queryraions.SQL.Add('select ID, prefiks, name from RAIONS');
     queryraions.Active:=true;

     //----
     queryraions.FieldByName('ID').Visible:=false;
     queryraions.FieldByName('ID').ProviderFlags:=queryraions.Fields.Fields[0].ProviderFlags+[pfInKey];
     queryraions.Fields.FieldByName('prefiks').DisplayLabel:='номер';
     queryraions.Fields.FieldByName('prefiks').DisplayWidth:=20;
     queryraions.Fields.FieldByName('name').DisplayLabel:='краткое наименование';
     queryraions.Fields.FieldByName('name').DisplayWidth:=20;
     //Вызываем форму локации
     //false значит выбираем не для выбора
       TDBSlovariTemplateForm.ShowGridSlovari('район', trans, queryraions, nil,
       @Zapolnenie, 'GEN_RAIONS', 'ID', nil,nil, false);
       queryraions.Active:=false;
       queryraions.Free;
       trans.Free;
       self.SQLQuery2.Refresh;
end;

procedure TForm1.Button8Click(Sender: TObject);
var
  i,id:integer;
  SCRIPT:TSQLScript;
  Q:TSQLQuery;
  T:TSQLTransaction;
begin
  if self.Button8.Caption='отменить' then
  begin
    self.SQLQuery3.Cancel;
    self.Button9.Caption:='добавить';
    self.Button8.Caption:='удалить';
    //self.SQLQuery3.CancelUpdates;
    self.Button13.Visible:=false;
    self.Button13.Visible:=true;
     self.DBEdit1.Color:=cldefault;
  self.DBEdit2.Color:=cldefault;
  self.DBEdit3.Color:=cldefault;
  self.DBEdit4.Color:=cldefault;
  self.DBLookupComboBox1.Color:=cldefault;
  self.DBLookupComboBox2.Color:=cldefault;
  self.DBEdit1.ReadOnly:=true;
  self.DBEdit2.ReadOnly:=true;
  self.DBEdit3.ReadOnly:=true;
  self.DBEdit4.ReadOnly:=true;
  self.DBLookupComboBox1.Enabled:=false;
  self.DBLookupComboBox2.Enabled:=false;
  self.Button1.Visible:=true;
  self.Button2.Visible:=true;
  end else
  begin
     if QuestionDlg('удаление','Удалить учетную запись?'
         , mtConfirmation,[mrYes,'Удалить',mrNo,'Не удалять','isdefault'],'')=mrYes then
         begin
         /////////
         self.SQLQuery4.Locate('ID',self.SQLQuery3.FieldByName('ID_ROLE').AsInteger,[]);
         //showmessage(self.SQLQuery4.FieldByName('rrole').AsString);exit;
         SCRIPT:=Tsqlscript.Create(self);
           script:=tsqlscript.Create(self);
           T:=TSQLTransaction.Create(self);
           t.DataBase:=self.SQLQuery3.DataBase;
           script.DataBase:=sqlquery3.DataBase;
           script.Transaction:=t;
           script.CommentsInSQL:=false;
           script.UseSetTerm:=true;
           script.Script.Clear;
           script.Script.Add('revoke '+self.SQLQuery4.FieldByName('rrole').AsString+' from ptk_admin_'+self.SQLQuery3.FieldByName('name').AsString+';');
           script.Script.Add('revoke AUTH from ptk_admin_'+self.SQLQuery3.FieldByName('name').AsString+';');
           script.Execute;
           t.Commit;
           script.Free;
         /////////

           id:=self.SQLQuery3.FieldByName('ID').AsInteger;
           self.SQLQuery3.Delete;
           self.SQLQuery3.ApplyUpdates;
           self.SQLTransaction1.CommitRetaining;
           Q:=TSQLQuery.Create(self);
           T:=TSQLTransaction.Create(self);
           t.DataBase:=self.SQLQuery3.DataBase;
           Q.DataBase:=self.SQLQuery3.DataBase;
           Q.SQL.Clear;
           Q.SQL.Add('select id,name from spis_akt');
           Q.Transaction:=t;
           q.Open;
           if q.IsEmpty then
           begin
             q.Close;
             q.Free;
             t.Free;
             exit;
           end;
           q.First;q.Last;q.First;
           SCRIPT:=Tsqlscript.Create(self);
           script:=tsqlscript.Create(self);
           script.DataBase:=sqlquery3.DataBase;
           script.Transaction:=t;
           script.CommentsInSQL:=false;
           script.UseSetTerm:=true;
           for i:=1 to q.RecordCount do
           begin
                script.Script.Clear;
                script.Script.Add('drop generator GEN_NUMBER_AKT_'+utf8uppercase(q.FieldByName('name').AsString)+'_USER_'+inttostr(id)+';');
                try
                  script.Execute;
                except
                  on E: Exception do
                  begin
                  end;
                end;
           end;
            t.Commit;
           script.Free;
           t.Free;
           q.Free;
         end;
  end;
end;

procedure TForm1.Button9Click(Sender: TObject);
var
  SCRIPT:TSQLScript;
  T:TSQLTransaction;
begin
  if self.Button9.Caption<>'сохранить' then
  begin;
        self.SQLQuery3.Insert;
        self.Button8.Caption:='отменить';
        self.Button9.Caption:='сохранить';
        self.Button13.Visible:=false;
        self.Button13.Visible:=true;
        self.DBEdit1.Color:=clinfobk;
  self.DBEdit2.Color:=clinfobk;
  self.DBEdit3.Color:=clinfobk;
  self.DBEdit4.Color:=clinfobk;
  self.DBLookupComboBox1.Color:=clinfobk;
  self.DBLookupComboBox2.Color:=clinfobk;
  self.DBEdit1.ReadOnly:=false;
  self.DBEdit2.ReadOnly:=false;
  self.DBEdit3.ReadOnly:=false;
  self.DBEdit4.ReadOnly:=false;
  self.DBLookupComboBox1.Enabled:=true;
  self.DBLookupComboBox2.Enabled:=true;
  self.Button1.Visible:=false;
  self.Button2.Visible:=false;
  end else
  begin
     //сохраним в базе пользователя
     self.SQLQuery3.FieldByName('ID').AsInteger:=CreateGUID('GEN_USERS_ID',self.SQLQuery3.DataBase);
     self.SQLQuery3.Post;
     self.SQLQuery3.ApplyUpdates;
     self.SQLTransaction1.CommitRetaining;
     //предоставим пользоваелю роль
     SCRIPT:=Tsqlscript.Create(self);
           script:=tsqlscript.Create(self);
           T:=TSQLTransaction.Create(self);
           t.DataBase:=self.SQLQuery3.DataBase;
           script.DataBase:=sqlquery3.DataBase;
           script.Transaction:=t;
           script.CommentsInSQL:=false;
           script.UseSetTerm:=true;
           script.Script.Clear;
           self.SQLQuery4.Locate('ID',self.SQLQuery3.FieldByName('ID').AsInteger,[]);
           script.Script.Add('grant '+self.SQLQuery4.FieldByName('rrole').AsString+' to ptk_admin_'+self.SQLQuery3.FieldByName('name').AsString+';');
           script.Script.Add('grant AUTH to ptk_admin_'+self.SQLQuery3.FieldByName('name').AsString+';');
           script.Execute;
           t.Commit;
           script.Free;
           t.Free;
     /////////////////////////
     //i:=self.SQLQuery3.FieldByName('ID').AsInteger;

     self.Button8.Caption:='удалить';
     self.Button9.Caption:='добавить';
     self.Button13.Visible:=true;
     self.DBEdit1.Color:=cldefault;
  self.DBEdit2.Color:=cldefault;
  self.DBEdit3.Color:=cldefault;
  self.DBEdit4.Color:=cldefault;
  self.DBLookupComboBox1.Color:=cldefault;
  self.DBLookupComboBox2.Color:=cldefault;
  self.DBEdit1.ReadOnly:=true;
  self.DBEdit2.ReadOnly:=true;
  self.DBEdit3.ReadOnly:=true;
  self.DBEdit4.ReadOnly:=true;
  self.DBLookupComboBox1.Enabled:=false;
  self.DBLookupComboBox2.Enabled:=false;
  self.Button1.Visible:=true;
  self.Button2.Visible:=true;
  end;
end;

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: char);
begin
  if key<>#8 then
  if (pos(key,shbln)<=0)and(pos(key,shbln2)<=0) then key:=#0;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SQLQuery1.close;
  SQLQuery2.Close;
  SQLQuery3.Close;
  fbadmin1.DisConnect;
  //closeaction:=caFree;
end;


end.

