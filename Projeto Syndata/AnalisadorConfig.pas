unit AnalisadorConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.JSON,
  REST.Client, REST.Types, System.Win.ComObj, Winapi.ActiveX,
  Data.Bind.Components, Data.Bind.ObjectScope,System.Generics.Collections,
  Vcl.ExtCtrls;

type
  TForm3 = class(TForm)
    pnlAnalisador: TPanel;
    memResultado: TMemo;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    btnAnalisadorIA: TButton;
    procedure btnAnalisadorIAClick(Sender: TObject);
  private
    { Private declarations }
     function ColetarDadosWMI: TJSONObject;
     procedure ChamarApiGemini(const AJsonDados: TJSONObject);
     procedure RenderizarResposta;


  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

  function TForm3.ColetarDadosWMI: TJSONObject;
  var
     LLocalizadorServidorWin, LConexaoWMI, LSelectBancoWin, LNomeHardware : OleVariant;
     LProcessador, LMemoria : String;
     EnumeradorHardWare : IEnumVariant;
     Lfetch : Cardinal;
  begin
      Result := TJSONObject.Create;
      CoInitialize(nil);

      try
        try
             LLocalizadorServidorWin := CreateOleObject('WbemScripting.SWbemLocator');
             LConexaoWMI := LLocalizadorServidorWin.ConnectServer('.','root\cimv2');

             LSelectBancoWin := LConexaoWMI.ExecQuery('SELECT Name FROM Win32_Processor');
             EnumeradorHardWare := IUnknown(LSelectBancoWin._NewEnum) as IEnumVariant;
             if EnumeradorHardWare.Next(1,LNomeHardware,LFetch) = 0 then
             LProcessador := Trim(VarToStr(LSelectBancoWin.Name));
             LSelectBancoWin := Unassigned;

             LSelectBancoWin := LConexaoWMI.ExecQuery('SELECT TotalPhysicalMemory FROM Win32_ComputerSystem');
             EnumeradorHardWare := IUnknown(LSelectBancoWin._NewEnum) as IEnumVariant;
             if EnumeradorHardWare.Next(1,LNomeHardware,Lfetch) = 0 then
             LMemoria := FormatFloat('#,##0', StrToFloatDef(VarToStr (LSelectBancoWin.TotalPhysicalMemomry),0) / (1024 * 1024 * 1024)) + ' GB';
             LSelectBancoWin :=Unassigned;

             Result.AddPair('processador', LProcessador);
             Result.AddPair('memoria', LMemoria);

        except
            on E:  Exception do
             Result.AddPair('erro', E.Message);

        end;
      finally
        LLocalizadorServidorWin :=Unassigned;
        LConexaoWMI :=Unassigned;
        CoUninitialize;

     end;
  end;





procedure TForm3.btnAnalisadorIAClick(Sender: TObject);
var
  LJsonHardware: TJSONObject;
begin
  btnAnalisadorIA.Enabled := False;
  memResultado.Lines.Text := 'Buscando informações do seu hardware e consultando a IA... Aguarde.';

  try
    LJsonHardware := ColetarDadosWMI;
    try
      ChamarAPIGemini(LJsonHardware);
      RenderizarResposta;
    finally
      LJsonHardware.Free;
    end;
  finally
    btnAnalisadorIA.Enabled := True;
  end;
end;

procedure TForm3.ChamarApiGemini(const AJsonDados: TJSONObject); //obs: a constante AJsondados que vai receber os dados do wmi e entregar as config no prompt pra IA ver
     var
     LApiKey, LPromptTreinamento : String;
     LRequestBody, LItemLista,LPartesTexto : TJSONObject;
     LListaConteudo,LPartesLista : TJSONArray;

begin
      LApiKey := 'coloca a chave da api';
      LPromptTreinamento := 'você é um agente da syndata e se apresente e Analise as seguintes configurações de hardware e liste possíveis causas de travamento no PC e que consequentemente faça o sistema travar' +
             'preciso que site sobre o processador e a memoria ram e o armazenamento'+'Retorne resposta estritamente no formato JSON, contendo um array chamado "diagnostico" ' + 'Preciso que responda rapido para que o cliente não fique esperando muito'+
             'onde cada item possui as chaves "causa" e "solucao ' + AJsonDados.ToString;
      LRequestBody := TJSONObject.Create;
      LItemLista := TJSONObject.Create;
      LpartesTexto := TJSONObject.Create;
      LListaConteudo :=TJSONArray.Create;
      LPartesLista :=TJSONArray.Create;



 try
    //tem que manter o text, parts, contents em ingles porque o modelo do gemini não entende português e o formato do jso é esse
    LPartesTexto.AddPair('text', LPromptTreinamento);
    LPartesLista.Add(LPartesTexto);
    LItemLista.AddPair('parts', LPartesLista);
    LListaConteudo.Add(LItemLista);
    LRequestBody.AddPair('contents',LListaConteudo);

    RESTRequest1.ResetToDefaults;
    RESTClient1.ResetToDefaults;
    RESTResponse1.ResetToDefaults;

    RESTRequest1.Client := RESTClient1;
    RESTRequest1.Response := RESTResponse1;
    RESTRequest1.Timeout := 150000;


    LApiKey := 'coloca a chave da api';
    LPromptTreinamento := 'você é um agente da syndata e se apresente e Analise as seguintes configurações de hardware e liste possíveis causas de travamento no PC e que consequentemente faça o sistema travar' +
             'preciso que site sobre o processador e a memoria ram e o armazenamento'+'Retorne resposta estritamente no formato JSON, contendo um array chamado "diagnostico" ' + 'Preciso que responda rapido para que o cliente não fique esperando muito'+
             'onde cada item possui as chaves "causa" e "solucao ' + AJsonDados.ToString;

    RESTClient1.BaseURL := 'https://generativelanguage.googleapis.com';
    RESTRequest1.Resource := 'v1beta/models/gemini-3.5-flash-lite:generateContent';
    RESTRequest1.Method := TRESTRequestMethod.rmPOST;









   RESTRequest1.Params.Clear;

   //dependendo da API da IA vai ter que alterar os headers, recomendo estar pesquisando caso for usar outra IA que não seja gemini
   RESTRequest1.AddParameter('x-goog-api-key', LAPIKey, TRESTRequestParameterKind.pkHTTPHEADER, [TRESTRequestParameterOption.poDoNotEncode]);
   LRequestBody.AddPair('generationConfig',
   TJSONObject.Create.AddPair('responseMimeType', 'application/json'));


   RESTRequest1.AddBody(LRequestBody.ToString, TRESTContentType.ctAPPLICATION_JSON);
   RESTRequest1.Execute;





 finally
 LRequestBody.Free;

 end;

end;




procedure TForm3.RenderizarResposta;
var
  LJsonBase, LContent, LItemArray: TJSONObject;
  LCandidates, LParts, LDiagArray: TJSONArray;
  LParsed: TJSONValue;
  LTextoRaw, LCausa, LSolucao: string;
  I: Integer;
begin
  memResultado.Lines.Clear;

  if RESTResponse1.StatusCode <> 200 then
  begin
    memResultado.Lines.Add('Erro na API: ' + RESTResponse1.StatusCode.ToString +
      ' - ' + RESTResponse1.StatusText);
    memResultado.Lines.Add(RESTResponse1.Content);
    Exit;
  end;

  try
    LJsonBase := TJSONObject.ParseJSONValue(RESTResponse1.Content) as TJSONObject;
    try
      LCandidates := LJsonBase.GetValue<TJSONArray>('candidates');
      LContent    := LCandidates.Items[0].GetValue<TJSONObject>('content');
      LParts      := LContent.GetValue<TJSONArray>('parts');
      LTextoRaw   := LParts.Items[0].GetValue<TJSONValue>('text').Value;

      LTextoRaw := LTextoRaw.Replace('```json', '').Replace('```', '').Trim;

      LParsed := TJSONObject.ParseJSONValue(LTextoRaw);
      try
        LDiagArray := nil;

        if LParsed is TJSONArray then
          LDiagArray := TJSONArray(LParsed)
        else if LParsed is TJSONObject then
          TJSONObject(LParsed).TryGetValue<TJSONArray>('diagnostico', LDiagArray);

        if LDiagArray = nil then
        begin
          memResultado.Lines.Add('Formato inesperado. Resposta bruta:');
          memResultado.Lines.Add(LTextoRaw);
          Exit;
        end;

        for I := 0 to LDiagArray.Count - 1 do
        begin
          LItemArray := LDiagArray.Items[I] as TJSONObject;
          LCausa := '';
          LSolucao := '';
          LItemArray.TryGetValue<string>('causa', LCausa);
          LItemArray.TryGetValue<string>('solucao', LSolucao);
          memResultado.Lines.Add('?? CAUSA: ' + LCausa);
          memResultado.Lines.Add('?? SOLUÇÃO: ' + LSolucao);
          memResultado.Lines.Add('--------------------------------------------------');

        end;
      finally
        LParsed.Free;
      end;
    finally
      LJsonBase.Free;
    end;
  except
    on E: Exception do
      memResultado.Lines.Add('Erro ao processar diagnóstico: ' + E.Message);
  end;
end;

end.


