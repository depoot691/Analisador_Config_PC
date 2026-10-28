**Analisador de Computador com travamento com IA **

Aplicação em Delphi 13 que coleta as configurações de hardware do PC (processador e memória RAM) via WMI, envia os dados em JSON para a API do Gemini (Google) e mostra na tela um diagnóstico com possíveis causas de travamento e as soluções.

**Como funciona**

O usuário clica em Analisar com IA.
O programa lê o processador e a memória RAM do Windows (WMI) e monta um JSON.
O JSON entra dentro de um prompt e é enviado por REST para o Gemini.
O Gemini responde em JSON (diagnostico, com causa e solucao) e o programa exibe o resultado no campo de texto.

**Requisitos**

Windows (o WMI só existe nele)
Delphi com suporte a VCL e componentes REST (a edição Community serve)
Conexão com a internet
Uma chave de API do Gemini (gratuita)

**Como rodar**

Baixe o repositório (Download ZIP) e extraia em uma pasta.
Abra o arquivo Project3.dproj no Delphi.
Crie a sua chave de API em https://aistudio.google.com (opção Get API key).
Abra o AnalisadorConfig.pas, procure a linha LApiKey := e troque o texto pela sua chave gerada pelo gemini.


Aperte F9 para compilar e executar.
Clique em Analisar com IA.

