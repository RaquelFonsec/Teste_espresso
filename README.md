

# Integração de Reembolsos - Espresso e ERP Omie
 

## Visão Geral

  

Este projeto é uma aplicação desenvolvida para integrar o sistema de reembolsos Espresso com o ERP Omie. O objetivo principal é permitir que os pedidos de reembolsos aprovados do Espresso sejam registrados no ERP Omie como contas a pagar. Além disso, a aplicação monitora o status de pagamento dessas contas e notifica o Espresso em tempo real.

  

## Objetivo

  

A integração visa proporcionar um fluxo de trabalho eficiente e resiliente para gerenciar reembolsos, cobrindo todos os pontos de falha que podem ocorrer durante a intermediação entre o Espresso e o ERP Omie.

  

## Funcionalidades Principais

  

A aplicação implementa três fluxos principais:

  

1. **Fluxo de Configuração do Cliente Integrador**

  

- Recebe e valida as credenciais do cliente Espresso (`company_id`, `erp`, `erp_key`, `erp_secret`).

- Realiza a validação das credenciais via uma requisição à API do ERP Omie, com processamento agendado em segundo plano para garantir um tempo de resposta rápido.

- Registra os resultados da validação (sucesso ou falha) e notifica o Espresso via webhook.

  

2. **Fluxo de Criação de Contas a Pagar**

- Recebe os atributos necessários para criar contas a pagar no ERP Omie, incluindo `client_id`, `client_code`, `category_code`, `account_code`, `due_date` e `cost`.

- A criação das contas a pagar é realizada em segundo plano para garantir um rápido tempo de resposta.

- Notifica o Espresso sobre o status da criação da conta a pagar via webhook.

  

3. **Fluxo de Notificação de Pagamento do Reembolso**

- Monitora as baixas de contas a pagar no ERP Omie.

- Notifica o Espresso sobre o pagamento dos reembolsos via webhook.

- Registra as notificações, garantindo que o pagamento seja corretamente associado ao reembolso correspondente.

  

## Tecnologias Utilizadas

  

- **Ruby on Rails**: Framework web para construção da aplicação.

- **PostgreSQL**: Sistema de gerenciamento de banco de dados relacional.

- **Redis**: Para gerenciamento de filas e jobs em background.

- **RSpec**: Para testes automatizados.
- **Sidekiq**: Utilizado para processar jobs em background de forma eficiente, integrando-se ao Redis.
  

## Configuração do Ambiente


### Pré-requisitos


- Ruby (versão **3.1.2**)

- Rails (versão **7.1.4**)

- PostgreSQL (versão **14.13**)

- Redis (versão **7.4.0**)

- RSpec (versão **3.13**)

- Sidekiq (versão **7.3.2**)

 
### Instalação

 
1. *Clone o repositório**:

```bash

git clone https://github.com/RaquelFonsec/Teste_espresso.git

cd Teste_espresso

Instala todas as dependências do projeto
bundle install

Cria o banco de dados
rails db

Executa as migrações para criar as tabelas no banco de dados
rails db:migrate


Inicia o servidor Redis
redis-server

Inicia o Sidekiq em segundo plano
bundle exec sidekiq

Inicia o servidor Rails
rails server

Executa os testes com RSpec
bundle exec rspec



Resumo dos Testes Realizados
No projeto, foram implementados mais de 70 testes utilizando RSpec e WebMock para garantir a robustez e a qualidade do sistema. O WebMock foi utilizado para simular chamadas HTTP externas, permitindo testar interações com APIs sem depender de sua disponibilidade. Abaixo está uma descrição das  áreas testadas:

1. Jobs e Background Processing
CreatePayableAccountJob:

Testes para a criação de contas a pagar com sucesso.
Verificação de comportamento quando o servidor está indisponível.
Validação de notificações enviadas em caso de sucesso ou falha.

ValidateClientJob:

Testes para validar credenciais com respostas bem-sucedidas e falhas.
Verificação do comportamento ao lidar com exceções durante a validação.

MarkAsPaidJob:

Testes para garantir que a notificação de pagamento é registrada corretamente.
Verificação da lógica de tentativas de notificação e o que acontece quando o limite de tentativas é atingido.


2. Modelos
Payable:

Testes de validação para garantir que todos os campos obrigatórios estão presentes.
Verificação das associações e métodos personalizados, como reimbursement_existe?, paid? e failed?.
Reimbursement:

Testes de validação e associações.
Verificação do comportamento de métodos como register_payment! e payment_registered?.

3. Serviços
NotificationService:
Testes para o envio de notificações, registrando mensagens de erro e sucesso.
Verificação do tratamento de falhas na comunicação com APIs externas, utilizando o WebMock para simular respostas.


4. Validações Personalizadas
PayableAccountValidator:
Testes para validar a presença de campos obrigatórios e a lógica da data de vencimento.





Visão Geral da Aplicação


Esta aplicação foi desenvolvida para automatizar a gestão de contas a pagar, integrando dados de reembolsos aprovados no sistema Espresso com o ERP Omie. O sistema facilita a criação, validação e marcação de pagamentos de forma eficiente, utilizando uma arquitetura baseada em jobs para realizar as tarefas críticas de forma assíncrona e otimizada. Além disso, a aplicação processa eventos de webhook, desencadeando ações automáticas com base nesses eventos.


-**Funcionalidades Principais**


Criação de Contas a Pagar
Ao receber um evento de create_payable via webhook, a aplicação dispara o job CreatePayableAccountJob, que é responsável por processar os dados do evento e registrar automaticamente as contas no ERP Omie. Esse job assegura que os dados sejam corretamente transmitidos e armazenados no sistema Omie.

Marcar Contas como Pagas

Quando o evento de mark_as_paid é recebido, a aplicação aciona o job MarkAsPaidJob. Esse job atualiza o status da conta no Omie, marcando-a como paga. O job garante que a sincronização entre o sistema interno e o ERP Omie ocorra de forma rápida e precisa.

Validação de Contas a Pagar

Antes de criar ou atualizar uma conta, o serviço PayableAccountValidator valida dados críticos como client_id, account_code, cost, entre outros. Esse processo de validação ocorre antes da execução do CreatePayableAccountJob ou MarkAsPaidJob, garantindo que apenas dados corretos e completos sejam processados.

Envio de Notificações

O NotificationService é responsável por centralizar o envio de notificações para APIs externas, como o Omie, e para outros endpoints configurados. Este serviço trabalha em conjunto com os jobs de criação e marcação de pagamento para garantir que todas as alterações de estado sejam comunicadas de forma adequada e em tempo real.

Recepção de Webhooks

A aplicação conta com endpoints dedicados para receber eventos de webhook. Quando um evento relevante é recebido, os jobs correspondentes são acionados para processar a informação, automatizando fluxos de trabalho de forma integrada.

Broadcast de Webhooks

O BroadcastWebhookService distribui os eventos recebidos para todos os endpoints inscritos, de acordo com o tipo de evento. Essa funcionalidade garante que diversos sistemas possam ser atualizados simultaneamente, mantendo a consistência e integridade dos dados.


**Para o funcionamento correto do sistema siga as orientaçoes abaixo**:


Como se Cadastrar na Omie e Obter Credenciais
1. Criando uma Conta de Teste na Omie
Para criar uma conta de teste na Omie, siga estes passos:

Acesse o Site da Omie:https://developer.omie.com.br/

Vá para Omie.
Inscreva-se:

Clique em "Experimente Grátis" ou "Comece Agora" na página inicial.
Preencha o formulário de cadastro com suas informações pessoais e de empresa.
Você pode usar um e-mail válido e uma senha para criar sua conta.
Confirme seu E-mail:

Após o cadastro, verifique seu e-mail e siga o link de confirmação enviado pela Omie.
2. Obtendo Credenciais de API
Após criar sua conta, você precisará obter as credenciais de API (chaves) para autenticar suas requisições:


**Abaixo siga as orientaçoes para cadastrar um cliente,buscar categorias e listar conta corrente e incluir contas a pagar**



Uso da API

Endpoint: Configuração do Cliente Integrador

URL: https://app.omie.com.br/api/v1/geral/clientes/

Método: POST

Requisição:

{ "codigo_cliente_integracao": "CodigoInterno0001", "email": "primeiro@ccliente.com.br", "razao_social": "Primeiro Cliente Ltda Me", "nome_fantasia": "Primeiro Cliente" }


Parâmetros:


codigo_cliente_integracao: Identificador único do cliente.
email: Endereço de e-mail do cliente.
razao_social: Nome completo da empresa.
nome_fantasia: Nome pelo qual a empresa é conhecida.

Resposta (Exemplo):

{ "codigo_cliente_omie": 0000001, "codigo_cliente_integracao": "222", "codigo_status": "0", "descricao_status": "Cliente cadastrado com sucesso!" }



Endpoint: Busca de Categorias

URL: https://app.omie.com.br/api/v1/geral/categorias/

Método: POST

Requisição:

{ "pagina": 1, "registros_por_pagina": 50, "filtrar_por_tipo": "D" }

Identificação da Categoria Correta

Embora a busca retorne várias categorias do tipo "D", a categoria usada para associar a despesas de serviços neste projeto é a seguinte:

Código: 2.01.04



Endpoint: Listar Conta Corrente

URL: https://app.omie.com.br/api/v1/geral/contacorrente/

Método: POST

Requisição:

{ "pagina": 1, "registros_por_pagina": 50 }

Faça uma requisição ao endpoint api/v1/geral/contacorrente/ para listar todas as contas correntes disponíveis.

Na resposta, busque pelo campo nCodCC que representa o código da conta corrente.

Utilize o valor obtido no campo nCodCC como referência ao registrar transações ou ao associar a conta corrente com outras operações.




Fluxo de Criação de Contas a Pagar

URL: https://app.omie.com.br/api/v1/financas/contapagar/

Método: POST

Requisição:

{ "codigo_lancamento_integracao": "", "codigo_cliente_fornecedor": "CODIGO", "data_vencimento": "YYYY-MM-DD", "valor_documento": "XXX", "codigo_categoria": "CODIGO_CATEGORIA", "data_previsao": "YYYY-MM-DD", "id_conta_corrente": "ID_CONTA_CORRENTE" }



Instruções para Preencher os Campos

Ao utilizar o endpoint de inclusão de contas a pagar, é fundamental preencher os campos com os valores obtidos nas etapas anteriores.

**Após essas etapas siga para as demais**:



Execução da Validação do Cliente Integrador
Para executar a tarefa de validação do cliente integrador, que é fundamental para assegurar que as informações do cliente estejam corretamente cadastradas e sincronizadas com a API do Omie, siga as instruções abaixo.

Comando de Execução
Para iniciar o processo de validação, utilize o seguinte comando:

ValidateClientJob.perform_later(1, "omie", ENV["APP_KEY"], ENV["APP_SECRET"], "Código do cliente de integração que está sendo validado")


Parâmetros do Comando:

1: ID do cliente que você deseja validar.
"omie": Nome da aplicação que está realizando a validação.
ENV["APP_KEY"]: Esta variável de ambiente contém a chave de autenticação da aplicação, permitindo que o sistema se conecte ao ERP Omie.
ENV["APP_SECRET"]: Esta variável de ambiente armazena o segredo da aplicação, que é utilizado em conjunto com a erp_key para autenticação no ERP Omie.
"xxx": Código do cliente de integração que está sendo validado.

Após executar o comando, é recomendável monitorar a interface do Sidekiq para verificar se o trabalho foi executado com sucesso ou se houve falhas. Você pode acessar a interface do Sidekiq em: http://localhost:3000/sidekiq.



Resumo da Classe ValidateClientJob (Fluxo do Cliente Integrador)
A classe ValidateClientJob é responsável por validar as credenciais de integração de um cliente com um sistema ERP através da API da Omie. Aqui estão os principais pontos da classe:

Configuração da Fila: O job é enfileirado na fila padrão (default).
Número Máximo de Tentativas: Limite de 3 tentativas para a validação das credenciais antes de considerar a operação como falha.
Métodos Principais
Método perform:

Executa a validação, registra no log e chama o método validate_credentials.
Método validate_credentials:

Realiza uma chamada GET à API da Omie para validar as credenciais.
Retorna a resposta se a validação for bem-sucedida ou registra um erro se falhar.
Método handle_validation_failure:

Trata falhas de validação, com tentativas agendadas em intervalos crescentes.
Notifica sobre falha se o limite máximo de tentativas for atingido.
Método notify_espresso:

Envia uma notificação ao endpoint designado (Espresso) com o status da validação.
Registra no log o resultado da tentativa de notificação.


Como o Webhook é Usado na Validação do Cliente Integrador
Na classe ValidateClientJob, um webhook é utilizado para notificar o sistema Espresso sobre o resultado da validação das credenciais de integração do cliente. Aqui está como ele funciona:

Notificação de Sucesso ou Falha:

Após validar as credenciais do cliente com a API do Omie, a classe decide se deve notificar o Espresso sobre o sucesso ou a falha da validação.
Sucesso: Se as credenciais forem válidas, a classe envia uma notificação de sucesso.
Falha: Se ocorrer uma falha, seja por erro nas credenciais ou por problemas de conexão, uma notificação de falha é enviada.
Endpoint de Notificação:

A notificação é enviada para um endpoint específico do sistema Espresso. 
Payload da Notificação:

A notificação inclui um payload (carga útil) que contém informações importantes, como:
Código do Cliente de Integração: Identificador do cliente que está sendo validado.
Status: Indica se a validação foi bem-sucedida ou se houve uma falha.
Erro: Se houver uma falha, a mensagem de erro correspondente é incluída.
ID da Empresa: O ID da empresa associada à validação.
Registro em Log:

O sistema registra no log tanto o envio da notificação quanto a resposta recebida do Espresso. Isso ajuda na auditoria e no rastreamento de problemas.






***Fluxo de Criação de Contas a Pagar***

1. Visão Geral dos Webhooks
Os webhooks são pontos de integração que permitem a comunicação em tempo real entre sistemas. Eles atuam como "ouvintes" que capturam eventos e transmitem dados a um controlador responsável pelo processamento.

2. Criação de Webhooks Múltiplos
O sistema suporta a criação de múltiplos webhooks, permitindo uma integração flexível com diversas funcionalidades. Isso significa que diferentes endpoints podem ser registrados para receber notificações de diferentes eventos, como:

Atualizações de status de contas a pagar.
Notificações de novos usuários.
Eventos de integração com outros sistemas.


3. Implementação do Controlador de Webhooks
O controlador WebhooksController é responsável pela recepção e processamento de eventos de webhook. Este fluxo é essencial para registrar automaticamente os reembolsos aprovados no sistema Espresso e garantir que as contas a pagar sejam criadas no ERP Omie.

4. Funcionalidades do Webhook

4.1. Recepção de Eventos
O webhook escuta e recebe eventos do tipo create_payable, capturando os dados necessários para a criação de contas a pagar.
4.2. Processamento de Eventos
Após a recepção, os dados são enviados para o controlador WebhooksController, que valida as informações recebidas.
4.3. Delegação para Validação
O controlador realiza uma validação inicial dos dados e, em seguida, chama o serviço de validação especializado, o PayableAccountValidator, para garantir que todos os dados necessários estejam corretos.
4.4. Geração de Jobs
Se a validação for bem-sucedida, o controlador invoca o job CreatePayableAccountJob, que é responsável por efetivamente criar a conta a pagar no sistema.
4.5. Notificações de Status
Após a criação da conta a pagar, o sistema envia notificações sobre o status da operação (sucesso ou falha) para um serviço de notificação(class NotificationService)
, assegurando que o sistema de origem do evento esteja ciente do resultado da operação.
5. Criação de um Endpoint de Webhook
Para registrar um novo webhook, utilize o seguinte comando:


curl -X POST http://localhost:3000/webhooks/webhook_endpoints \
-H "Content-Type: application/json" \
-d '{
  "webhook_endpoint": {
    "url": "https://eorwcvkk5u25m7w.m.pipedream.net/",
    "event_type": "conta_a_pagar",
    "client_id": xxx,
    "company_id": xxx,
    "subscriptions": ["*"],
    "enabled": true,
    "erp": "omie"
  }
}'

{
  "message": "Webhook inscrito com sucesso"
}

Observação: Substitua os valores xxx pelos IDs reais do cliente e da empresa. O URL do webhook deve ser acessível para receber os dados enviados pelo sistema.


6. Testando a Implementação
Para verificar a funcionalidade do webhook, utilize o seguinte comando de teste


curl -X POST http://localhost:3000/webhooks/receive_webhook \
-H "Content-Type: application/json" \
-d '{
  "webhook_event": {
    "event_type": "create_payable",
    "data": {
      "client_id": xxxx,
      "company_id": 1,
      "erp_key": null,
      "erp_secret": null,
      "category_code": "2.01.04",
      "account_code": "xxxxx",
      "cost": 100.0,
      "due_date": "2024-12-31",
      "codigo_lancamento_integracao": "xxx",
      "client_code": "xxx",
      "categoria": "D",
      "validation_webhook_url": "https://eo2180vhu0thrzi.m.pipedream.net/"  # URL do webhook do Pipedream
    }
  }
}'


{"message":"Conta a pagar em processo de criação"}



7. Fluxo do Job CreatePayableAccountJob

8. Executando o Job no Rails Console
Para acionar o job diretamente no console do Rails, utilize o seguinte comando:



CreatePayableAccountJob.perform_later(client_params: {
  client_id: xxxx,
  erp_key: ENV['ERP_KEY'],
  erp_secret: ENV['ERP_SECRET'],
  category_code: "2.01.04",
  account_code: xxxxxx,
  due_date: "xxxxx",
  cost: xxxxxx,
  codigo_lancamento_integracao: "xxxxx",
  client_code: "xxxxxxx",
  categoria: "D"
})

9. Integração do Job com o Serviço de Validação
O job CreatePayableAccountJob utiliza o serviço PayableAccountValidator para validar os parâmetros recebidos. O funcionamento inclui:

Recepção dos Parâmetros: O job recebe um conjunto de parâmetros essenciais.

Validação: Antes da criação da conta, o job chama o método validate do PayableAccountValidator, que verifica se todos os campos obrigatórios estão presentes e se a data de vencimento é válida.

Tratamento de Erros: Se a validação falhar, o job registra os erros e notifica a falha, evitando a criação de contas a pagar inválidas.

Criação da Conta: Apenas após a validação bem-sucedida, o job prossegue para criar a conta a pagar.

10. Benefícios da Estrutura
A separação de responsabilidades entre o job e o serviço de validação resulta em:

Melhor organização do código.
Facilidade na manutenção e extensibilidade da aplicação.
11. Resumo Visual do Fluxo
Imagine o fluxo da seguinte maneira:

Evento Externo 
      ↓
Webhook Recebe Dados 
      ↓
Controlador Processa 
      ↓
Validação de Parâmetros 
      ↓
Job Cria Conta a Pagar 
      ↓
Notificações de Status

Resumo do CreatePayableAccountJob
O CreatePayableAccountJob é O job  responsável por criar contas a pagar com base em parâmetros fornecidos pelo cliente. O fluxo do job é o seguinte:

Recepção de Parâmetros: O job recebe um conjunto de parâmetros do cliente, incluindo a data de vencimento.

Análise da Data de Vencimento: O job tenta analisar a data de vencimento. Se não for válida, uma notificação de falha é enviada e o processamento é encerrado.

Verificação da Disponibilidade do Servidor: Antes de prosseguir, o job verifica se a API do Omie (responsável pela criação das contas) está disponível.

Tentativas e Retentativas:

Se o servidor estiver indisponível, o job notifica a falha e verifica quantas tentativas já foram feitas.
Ele pode tentar criar a conta a pagar até um máximo de 3 tentativas (MAX_ATTEMPTS).
Entre cada tentativa, há um intervalo de 10 segundos (RETRY_DELAY). Se ainda houver tentativas restantes, o job é reprogramado para ser executado novamente com o número de tentativas incrementado.
Validação dos Parâmetros: O job valida os parâmetros recebidos. Se houver erros de validação, notifica a falha e encerra.

Criação da Conta a Pagar: Se todos os dados forem válidos, o job tenta criar a conta a pagar e salva as informações no banco de dados.

Notificações: O job envia notificações sobre o sucesso ou falha da operação, registrando todos os eventos relevantes no log.











Descrição do Job MarkAsPaidJob
Finalidade
O MarkAsPaidJob é um job que é responsável por marcar uma conta a pagar como paga e enviar uma notificação correspondente para um endpoint externo. Este processo é fundamental para garantir que as transações financeiras sejam corretamente registradas no sistema, mantendo a integridade e a precisão das informações financeiras.


Funcionamento Geral
Quando o job é acionado, ele realiza uma série de etapas para verificar, atualizar e notificar sobre o status de uma conta a pagar. Aqui estão os principais componentes e etapas do seu funcionamento:


1. Execução do Job
O job é iniciado com um ID (payable_id), que identifica a conta a pagar que deve ser marcada como paga.


2. Busca da Conta a Pagar
O método perform começa buscando a conta a pagar no banco de dados usando o ID fornecido. Se a conta não for encontrada, o job encerra imediatamente e registra um erro.


3. Verificação de Notificação
O job verifica se a notificação precisa ser enviada, utilizando o método skip_notification?. Se a conta a pagar já tiver um reembolso registrado e pago, o job evita enviar a notificação, economizando recursos e evitando duplicações.


4. Envio da Notificação
Se a notificação não for pulada, o job chama o método handle_notification, que é responsável por enviar a notificação ao endpoint configurado. O payload da notificação é criado a partir de informações relevantes da conta a pagar.


5. Atualização do Status da Conta a Pagar
Após o envio da notificação, o job atualiza o status da conta a pagar com base na resposta recebida. Se a notificação for bem-sucedida (resposta 200), a conta é marcada como "paga". Caso contrário, o job gerencia a falha no envio da notificação.


6. Gerenciamento de Falhas
Se houver uma falha no envio da notificação, o job incrementa o contador de tentativas de notificação. Se o número de tentativas atingir 3, a conta a pagar é marcada como "failed". Caso contrário, o job reprograma a notificação para tentar novamente após 10 minutos.


7. Construção do Payload
O payload da notificação é construído com dados essenciais, como código da conta, código da categoria, código do cliente, custo, data de vencimento e o status da conta. Isso assegura que todas as informações relevantes sejam enviadas ao endpoint.


8. Envio da Requisição
O job utiliza a biblioteca HTTParty para enviar uma requisição HTTP POST ao endpoint especificado, contendo o payload em formato JSON. Ele também implementa tratamento de erros para gerenciar possíveis exceções durante o envio.


Webhook
Finalidade do Webhook
O webhook é um mecanismo que permite que o sistema receba atualizações em tempo real sobre eventos externos. No contexto do MarkAsPaidJob, o webhook é responsável por iniciar o processo de marcação de uma conta a pagar como paga quando um evento específico é recebido.



Funcionamento do Webhook

Recepção do Evento: O webhook é acionado quando um evento de pagamento é enviado para o endpoint do controlador Webhooks::WebhookEndpointsController. Por exemplo, ao receber um evento do tipo mark_as_paid, o webhook extrai o payable_id da carga útil da requisição.


Criação de Conta a Pagar: O webhook também pode ser utilizado para criar registros de contas a pagar, conforme indicado no método receive_webhook. Caso a criação da conta a pagar seja bem-sucedida, uma notificação é enviada ao sistema Omie.
Notificação para o Job: Ao receber o evento de mark_as_paid, o webhook inicia o MarkAsPaidJob, passando o payable_id correspondente. Isso ativa todo o fluxo de trabalho descrito anteriormente, garantindo que a conta a pagar seja devidamente processada e atualizada.


Logs e Registro
O MarkAsPaidJob e o webhook geram logs informativos e de erro durante suas execuções. Isso permite que desenvolvedores e administradores acompanhem o fluxo do job e do webhook e identifiquem rapidamente qualquer problema que ocorra durante o processo de marcação e notificação.

Fluxo de Reembolso

Evento Externo 
      ↓
Webhook Recebe Dados 
      ↓
Controlador Processa 
      ↓
Validação de Parâmetros 
      ↓
Job Marca Conta a Pagar como Paga 
      ↓
Notificações de Status 




Considerações Finais
O MarkAsPaidJob e o webhook formam um sistema robusto para garantir que a marcação de contas a pagar como pagas seja realizada de maneira confiável e eficiente. Com suas validações e gerenciamento de falhas, eles asseguram a integridade dos registros financeiros e uma comunicação eficaz com sistemas externos.

Como Executar
Para executar o job, você pode utilizar o seguinte comando no console do Rails

MarkAsPaidJob.perform_later(ID) # substitua pelo ID da conta a pagar que foi criada anteriormente no fluxo de contas a pagar.

E para simular a recepção de um evento de webhook, você pode usar o seguinte comando curl:

curl -X POST http://localhost:3000/webhooks/receive_webhook \
-H "Content-Type: application/json" \
-d '{
  "webhook_event": {
    "event_type": "mark_as_paid",
    "data": {
      "payable_id": xxx  // ID do pagamento para reembolso
    }                 
  }                      
}'

{"message":"Notificação para marcar como pago em processo"}


Recebendo o Status da Validação

Considerações Finais

A integração entre o sistema de reembolsos Espresso e o ERP Omie foi projetada para garantir a eficiência e a confiabilidade no processo de registro e monitoramento de contas a pagar. Cada um dos fluxos principais foi cuidadosamente elaborado para lidar com potenciais falhas e oferecer notificações em tempo real, contribuindo para uma melhor gestão financeira.
Com a automação desses processos, a comunicação entre os sistemas é simplificada, o que resulta em maior agilidade no processamento de reembolsos e no controle das transações. A utilização de tecnologias robustas como Ruby on Rails, Sidekiq e Redis, junto com a cobertura de testes com RSpec, garante que a aplicação seja confiável e possa escalar conforme a demanda.
Este projeto serve como uma base sólida para futuras melhorias e ampliações na integração com outros sistemas, garantindo que o fluxo de caixa da empresa seja sempre preciso e eficiente

