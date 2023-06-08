unit DB_VModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, VCL.dialogs, system.JSON;

//---------------------------------------------------------
// ���̺��� ��ȸ�� �����͸� ���������� �Ѱ��� ������ ����
type SAnsType = Record
   qCount : integer;
   sFd1, sFd2, sFd3, sFd4 : TStringList;
End;
//---------------------------------------------------------


type
  TDataModule1 = class(TDataModule)
    FDQuery1: TFDQuery;
    FDConnection1: TFDConnection;
    procedure FDConnection1BeforeConnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     function Select_All: SAnsType;
     function A_Query: string;
  end;

var
  DataModule1: TDataModule1;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDataModule1.FDConnection1BeforeConnect(Sender: TObject);
begin
  FDConnection1.Params.Values[ 'Database' ] := ExtractFilePath(ParamStr(0)) + '..\..\stest.db';

end;


function TDataModule1.Select_All() : SAnsType;
begin
  result.sFd1 := TStringList.Create;
  result.sFd2 := TStringList.Create;
  result.sFd3 := TStringList.Create;
  result.sFd4 := TStringList.Create;

  FDConnection1.Open;
  try
    FDQuery1.Close;
    FDQuery1.SQL.Clear;
    FDQuery1.SQL.Add( 'Select * from table1' );
    FDQuery1.Open;
    FDQuery1.First;

    // ��ȸ�� �����͸� ���ڵ忡 ����.
    while Not FDQuery1.EOF do
    begin
      result.sFd1.Add( FDQuery1.FieldByName('field1').AsString );
      result.sFd2.Add( FDQuery1.FieldByName('field2').AsString );
      result.sFd3.Add( FDQuery1.FieldByName('field3').AsString );
      result.sFd4.Add( FDQuery1.FieldByName('field4').AsString );

      FDQuery1.Next;
      Inc( result.qCount );
    end;
    result.qCount := result.sFd1.Count;

  except
    on e: Exception do begin
      ShowMessage( e.Message );
    end;
  end;

  FDConnection1.Close;
end;



function TDataModule1.A_Query: string;
var
  JTopObj, JsubObj : TJSONObject;
  JArr  : TJSONArray;
  JPair : TJSONPair;
begin
  JTopObj := TJSONObject.Create;  // ���� �� ����

  try
    FDConnection1.Open;
    try
      FDQuery1.Close;
      FDQuery1.SQL.Clear;
      FDQuery1.SQL.Add( 'Select * from table1' );
      FDQuery1.Open;
      FDQuery1.First;

      JArr :=  TJSONArray.Create;    // Json �迭 ����
      while Not FDQuery1.EOF do
      begin
        JsubObj := TJSONObject.Create;   // �� �׸� ��

        JsubObj.AddPair( 'field1', FDQuery1.FieldByName('field1').AsString );
        JsubObj.AddPair( 'field2', FDQuery1.FieldByName('field2').AsString );
        JsubObj.AddPair( 'field3', FDQuery1.FieldByName('field3').AsString );
        JsubObj.AddPair( 'field4', FDQuery1.FieldByName('field4').AsString );

        JArr.AddElement( JsubObj );
        FDQuery1.Next;
      end;

      JPair := TJSONPair.Create( 'Items', JArr );                              // Items �׸� �Ʒ��� �迭��Ʈ�� �ִ´�.
      JTopObj.AddPair( 'Count', TJSONNumber.Create( FDQuery1.RecordCount ) );  // ��ܿ� ���ڵ� ī��Ʈ ǥ��
      JTopObj.AddPair( JPair );                                                // ���κ��� Items �迭��Ʈ ����.

    except
      on e: Exception do begin
         result := e.Message;
      end;
    end;


  finally
    FDConnection1.Close;

    result := JTopObj.ToString;   // ����� ����
    JTopObj.Free;
  end;
end;



end.
