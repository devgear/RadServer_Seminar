unit CMUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Json, System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.Layouts, FMX.ListBox, FMX.EditBox,
  FMX.NumberBox;

type
  TCForm = class(TForm)
    NetHTTPClient1: TNetHTTPClient;
    NetHTTPRequest1: TNetHTTPRequest;
    Button1: TButton;
    Memo1: TMemo;
    Edit2: TEdit;
    Layout1: TLayout;
    FListBox: TListBox;
    ListBoxItem2: TListBoxItem;
    NumberBox1: TNumberBox;
    procedure NetHTTPClient1RequestCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
    procedure Button1Click(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CForm: TCForm;

implementation

{$R *.fmx}
procedure TCForm.Edit2Change(Sender: TObject);
begin
  NumberBox1.Text := '0';
end;



procedure TCForm.Button1Click(Sender: TObject);
var
  sURL : string;
  sParamList : TStringList;
  i: Integer;
begin
  sURL := 'http://192.168.1.2:8080/RTest?';

  NetHTTPClient1.ContentType   := 'application/json';
  NetHTTPClient1.AcceptCharSet := 'UTF-8';

  sParamList := TStringList.Create;
  sParamList.Add( 'iData=' + NumberBox1.Text + '&' );
  sParamList.Add( 'sStr='  + Edit2.Text );

  for i := 0 to sParamList.Count - 1 do         // Rad Server Post 기본옵션은 URL에 파라미터 같이 전달해야 인식. (GET 과 같은 방식)
    sURL := sURL + sParamList[ i ];

  NetHTTPRequest1.Post( sURL, sParamList );
end;


procedure TCForm.NetHTTPClient1RequestCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
var
  sJsonData : string;
  i : Integer;
  oJson : TJSONObject;
  jArr : TJsonArray;
  subI : TListBoxItem;
begin
  if AResponse.StatusCode <> 200 then
  begin
    ShowMessage(  'HTTP response code: ' + AResponse.StatusCode.ToString );
    Exit;
  end;

  sJsonData := AResponse.ContentAsString();   // 응답받은 전체 Json 데이터

  Memo1.Lines.Clear;
  Memo1.Lines.Add( sJsonData );

  // Json 파싱 ----------------------------------------------------------------------------
  oJson := TJSONObject.ParseJSONValue( sJsonData ) as TJSONObject;

  FListBox.Clear();
  FListBox.BeginUpdate();

  try
    jArr := oJson.Get('MyItems').JsonValue as TJSONArray;

    for i := 0 to jArr.Count - 1 do
    begin
      subI := TListBoxItem.Create( FListBox );
      subI.StyleLookup := 'listboxitemrightdetail';
      subI.ItemData.Text :=   jArr.Items[i].GetValue<integer>('inc').ToString + ' : ' +
                              jArr.Items[i].GetValue<string>('field4') ;
      subI.ItemData.Detail := jArr.Items[i].GetValue<string>('field2') + ' : ' +
                              jArr.Items[i].GetValue<string>('field3') ;

      FListBox.AddObject( subI );
    end;
    FListBox.EndUpdate();

  finally
    oJson.Free;
  end;
end;


end.
