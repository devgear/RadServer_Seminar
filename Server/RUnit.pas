unit RUnit;

// EMS Resource Module

interface

uses
  System.SysUtils, System.Classes, System.JSON,  EMS.Services, EMS.ResourceAPI, EMS.ResourceTypes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.ConsoleUI.Wait;


type
  [ResourceName('RTest')]                   // [] : annotation : Ŭ����Ư�� ����
  TRTestResource1 = class(TDataModule)
    FDQueryI: TFDQuery;
    FDConnection1: TFDConnection;

  private
    procedure Con_Message( mType, mStr: string);

  published
    procedure Get(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);

    [ResourceSuffix('{itemQ}')]            // {} : ���� URL �Է°� �Ķ����
    procedure GetItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);

    procedure Post(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);


  public
    function A_Query( sItem : string ): string;
    function D_Query(iNo: integer): String;
  end;


implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}




// �ֿܼ� �޽��� ��� ��� ----------------------------------------
procedure TRTestResource1.Con_Message( mType ,mStr : string );
begin
  TEMSEndPointEnvironment.Instance.LogMessage(  FormatDateTime( 'YYYY-M-DD hh:mm:ss', now ) + '::' +  mType + '::' + mStr );
end;

//*****************************************************************************************************************************************
procedure TRTestResource1.Get(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
begin
  // Sample code
  AResponse.Body.SetValue( TJSONString.Create('RTest aaaaa'), True);
end;

//*****************************************************************************************************************************************
procedure TRTestResource1.GetItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  uStr : string;

begin
  uStr := ARequest.Params.Values['itemQ'];   // ���� URL �Է°�

  Con_Message( 'Get', uStr );

  if uStr = 'selectB'  then     // ��ҹ��� ���� ��.
    AResponse.Body.SetValue( TJSONString.Create( 'RTest ' + uStr ), True )   // Json Value ������ ���

  else                                                                       // String �״�� ���
    AResponse.Body.SetString( A_Query( uStr ) );
end;

//*****************************************************************************************************************************************
procedure TRTestResource1.Post(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  iParam : integer;
  sParam : string;
begin
  iParam := ARequest.Params.Values['iData'].ToInteger;
  sParam := ARequest.Params.Values['sStr'];

  Con_Message( 'Post', iParam.ToString  + ' : ' + sParam );

  if iParam = 0  then
     AResponse.Body.SetString( A_Query( sParam ) )
  else
     AResponse.Body.SetString( D_Query( iParam ) ) ;
end;


//--------------------------------------------------------------
function TRTestResource1.A_Query( sItem : string ) : String;
var
  JTopObj, JsubObj : TJSONObject;
  JArr  : TJSONArray;
  JPair : TJSONPair;

begin
  JTopObj := TJSONObject.Create;  // ���� �� ����

  try
    FDConnection1.Open;

    try
      FDQueryI.Close;
      FDQueryI.SQL.Clear;
      FDQueryI.SQL.Add( 'Select * from table1 ' );
      if sItem <> 'all'  then
      begin
        FDQueryI.SQL.Add( 'where field1 = :p_sItem '  );
        FDQueryI.ParamByName('p_sItem').AsString := sItem;
      end;

      FDQueryI.Open;
      FDQueryI.First;

      JArr :=  TJSONArray.Create;    // Json �迭 ����
      while Not FDQueryI.EOF do
      begin
        JsubObj := TJSONObject.Create;   // �� �׸� ��

        JsubObj.AddPair( 'inc', FDQueryI.FieldByName('inc').AsInteger );
        JsubObj.AddPair( 'field1', FDQueryI.FieldByName('field1').AsString );
        JsubObj.AddPair( 'field2', FDQueryI.FieldByName('field2').AsString );
        JsubObj.AddPair( 'field3', FDQueryI.FieldByName('field3').AsString );
        JsubObj.AddPair( 'field4', FDQueryI.FieldByName('field4').AsString );

        JArr.AddElement( JsubObj );  // �迭�� ���� ����
        FDQueryI.Next;
      end;

      JPair := TJSONPair.Create( 'MyItems', JArr );                            // Items �׸� �Ʒ��� �迭��Ʈ�� �ִ´�.
      JTopObj.AddPair( 'Count', TJSONNumber.Create( FDQueryI.RecordCount ) );  // ��ܿ� ���ڵ� ī��Ʈ ǥ��
      JTopObj.AddPair( JPair );                                                // ���κ��� Items �迭��Ʈ ����.

    except
      on e: Exception do begin
            Con_Message( 'A_Query Error', e.Message );
            result := 'Error';
            Exit;
      end;
    end;


  finally
      FDConnection1.Close;

      result := JTopObj.ToString;   // ����� ����.
      JTopObj.Free;
  end;
end;

//--------------------------------------------------------------
function TRTestResource1.D_Query( iNo : integer ) : String;
var
  JTopObj, JsubObj : TJSONObject;
  JArr  : TJSONArray;
  JPair : TJSONPair;

begin
  JTopObj := TJSONObject.Create;  // ���� �� ����

  try
    FDConnection1.Open;

    try
      FDQueryI.Close;
      FDQueryI.SQL.Clear;
      FDQueryI.SQL.Add( 'Select * from table1 ' );
      FDQueryI.SQL.Add( 'where inc = :p_I '  );
      FDQueryI.ParamByName('p_I').AsInteger := iNo;

      FDQueryI.Open;
      FDQueryI.First;

      JArr :=  TJSONArray.Create;    // Json �迭 ����
      while Not FDQueryI.EOF do
      begin
        JsubObj := TJSONObject.Create;   // �� �׸� ��

        JsubObj.AddPair( 'inc', FDQueryI.FieldByName('inc').AsInteger );
        JsubObj.AddPair( 'field1', FDQueryI.FieldByName('field1').AsString );
        JsubObj.AddPair( 'field2', FDQueryI.FieldByName('field2').AsString );
        JsubObj.AddPair( 'field3', FDQueryI.FieldByName('field3').AsString );
        JsubObj.AddPair( 'field4', FDQueryI.FieldByName('field4').AsString );

        JArr.AddElement( JsubObj );  // �迭�� ���� ����
        FDQueryI.Next;
      end;

      JPair := TJSONPair.Create( 'MyItems', JArr );                            // Items �׸� �Ʒ��� �迭��Ʈ�� �ִ´�.
      JTopObj.AddPair( 'Count', TJSONNumber.Create( FDQueryI.RecordCount ) );  // ��ܿ� ���ڵ� ī��Ʈ ǥ��
      JTopObj.AddPair( JPair );                                                // ���κ��� Items �迭��Ʈ ����.

    except
      on e: Exception do begin
            Con_Message( 'D_Query Error', e.Message );
            result := 'Error';
            Exit;
      end;
    end;


  finally
      FDConnection1.Close;

      result := JTopObj.ToString;   // ����� ����.
      JTopObj.Free;
  end;
end;


//-------------------------------------------------------------
procedure Register;
begin
  RegisterResource(TypeInfo(TRTestResource1));
end;


initialization
  Register;
end.


