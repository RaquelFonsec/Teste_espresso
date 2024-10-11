

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





Como se Cadastrar na Omie e Obter Credenciais
1. Criando uma Conta de Teste na Omie
Para criar uma conta de teste na Omie, siga estes passos:

Acesse o Site da Omie:

Vá para Omie.
Inscreva-se:

Clique em "Experimente Grátis" ou "Comece Agora" na página inicial.
Preencha o formulário de cadastro com suas informações pessoais e de empresa.
Você pode usar um e-mail válido e uma senha para criar sua conta.
Confirme seu E-mail:

Após o cadastro, verifique seu e-mail e siga o link de confirmação enviado pela Omie.
2. Obtendo Credenciais de API
Após criar sua conta, você precisará obter as credenciais de API (chaves) para autenticar suas requisições:

abaixo siga as orientaçoes para cadastrar um cliente,buscar categorias e listar conta corrente e incluir contas a pagar



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



Execução da Validação do Cliente Integrador



Para executar a tarefa de validação do cliente integrador, essa tarefa é fundamental para assegurar que as informações do cliente estejam corretamente cadastradas e sincronizadas com a API do Omie.

Comando de Execução

ValidateClientJob.perform_later(1, "omie", ENV["APP_KEY"], ENV["APP_SECRET"], "138") (exemplo via rails c)


1: ID do cliente que você deseja validar.
"omie": Nome da aplicação que está realizando a validação.
ENV["APP_KEY"]: Esta variável de ambiente contém a chave de autenticação da aplicação, permitindo que o sistema se conecte ao ERP Omie para criar a conta a pagar
ENV["APP_SECRET"]: Esta variável de ambiente armazena o segredo da aplicação, que é utilizado em conjunto com a erp_key para autenticação no ERP Omie
"138": Código do cliente integração que está sendo validado. (Exemplo)
Uso do Webhook


Durante esse processo, a aplicação será notificada através do seguinte webhook: https://eo2180vhu0thrzi.m.pipedream.net/. É importante garantir que o webhook esteja configurado para receber notificações sobre o status da validação.


Após executar o comando, é recomendável monitorar a interface do Sidekiq para verificar se o trabalho foi executado com sucesso ou se houve falhas. Você pode acessar a interface do Sidekiq em: http://localhost:3000/sidekiq.


Resumo da Classe ValidateClientJob (FLUXO DO CLIENTE INTEGRADOR)


A classe ValidateClientJob é responsável por validar as credenciais de integração de um cliente com um sistema ERP através da API da Omie. Aqui estão os principais pontos da classe:

Configuração da Fila: O job é enfileirado na fila padrão (default).
Número Máximo de Tentativas: Limite de 3 tentativas para a validação das credenciais antes de considerar a operação como falha.
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



Fluxo de Criação de Contas a Pagar

Implementação do Controlador de Webhooks

Descrição

O controlador WebhooksController foi adicionado ao sistema para permitir a recepção e o processamento de eventos de webhook, especificamente para a criação de contas a pagar. Este fluxo é crucial para registrar automaticamente os reembolsos aprovados no sistema Espresso e garantir que as respectivas contas a pagar sejam criadas no ERP Omie.

Funcionalidades
Recepção de Eventos: O controlador recebe eventos de webhook do tipo create_payable, permitindo que os dados necessários para a criação de contas a pagar sejam enviados diretamente para o sistema.

Processamento de Eventos: O controlador processa os eventos, valida os dados e aciona o job CreatePayableAccountJob para gerenciar a criação das contas a pagar no sistema.


Para criaçao de um endpoint de webook utilize os seguintes parametros 

curl -X POST http://localhost:3000/webhooks/webhook_endpoints \
-H "Content-Type: application/json" \
-d '{
  "webhook_endpoint": {
    "url": "https://eorwcvkk5u25m7w.m.pipedream.net/",
    "event_type": "conta_a_pagar",
    "client_id": 12345,
    "company_id": 1,
    "subscriptions": ["*"],
    "enabled": true,
    "erp": "omie"
  }
}'

{"message":"Webhook inscrito com sucesso"}





Testando a Implementação
Para testar a implementação do webhook, você pode usar o seguinte comando curl para simular a recepção de um evento de criação de conta a pagar:

curl -X POST http://localhost:3000/webhooks/receive_webhook \
-H "Content-Type: application/json" \
-d '{
  "webhook_event": {
    "event_type": "create_payable",
    "data": {
      "client_id": xxxx,
      "company_id": 1,  // Inclua um ID válido
      "erp_key": null,
      "erp_secret": null,
      "category_code": "2.01.04",
      "account_code": "xxxxx",
      "cost": 100.0,
      "due_date": "2024-12-31",
      "codigo_lancamento_integracao": "xxx",
      "client_code": "xxx",
      "categoria": "D"
    }
  }
}'

{"message":"Conta a pagar em processo de criação"}


Notificações: Após a execução, as notificações sobre o status da operação (sucesso ou falha) são enviadas para o serviço de notificação, 
(https://eorwcvkk5u25m7w.m.pipedream.net/ ) Pipedream e, em seguida, notificadas à Omie.

Criação de Conta a Pagar : Quando o evento é "create_payable", o webhook extrai os dados fornecidos e envia esses dados para Job CreatePayableAccountJob  que cria a conta a pagar


Job CreatePayableAccountJob
O job CreatePayableAccountJob é responsável pela lógica de criação das contas a pagar no sistema. Ele segue um fluxo bem definido para garantir que todas as operações sejam realizadas de maneira eficiente e segura:

Recebimento dos Parâmetros: O job recebe dados como ID do cliente, chaves de autenticação, categoria, código da conta, data de vencimento e valor.

Validação da Data de Vencimento: Converte a data de vencimento em um objeto de data e verifica se é válida.

Verificação de Disponibilidade do Servidor: Confirma se a API do Omie está acessível; se não, tenta novamente até 3 vezes.

Validação dos Parâmetros: Utiliza um validador para garantir que todos os dados estão corretos; se houver erros, notifica a falha.

Criação da Conta a Pagar: Se todos os dados forem válidos, o job tenta criar a conta a pagar e a salva no banco de dados.

Notificações: Envia notificações sobre o status da operação (sucesso ou falha) e registra os resultados no log.

Esse fluxo assegura que as contas a pagar sejam criadas de maneira confiável, com validação e tratamento de erros adequados.



pelo rails c

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



Fluxo de Baixa de Pagamento

O fluxo de baixa de pagamento é responsável por marcar uma conta a pagar como paga, registrando essa transação no sistema e enviando uma notificação apropriada. Isso garante que os pagamentos sejam atualizados corretamente, facilitando a gestão financeira da empresa.



Testando o Webhook
Você pode simular a recepção de um evento de webhook para marcar uma conta a pagar como paga utilizando o seguinte comando curl:

curl -X POST http://localhost:3000/webhooks/receive_webhook \
-H "Content-Type: application/json" \
-d '{
  "webhook_event": {
    "event_type": "mark_as_paid",
    "data": {
      "payable_id": 207  // ID do pagamento para reembolso
    }                 
  }                      
}'

{"message":"Notificação para marcar como pago em processo"}


Notificações: Após a execução, as notificações sobre o status da operação são enviadas para o serviço de notificação, 
(https://eorwcvkk5u25m7w.m.pipedream.net/ ) Pipedream.e, em seguida, notificadas à Omie.

Marcar como Paga : Se o evento for "mark_as_paid", o webhook envia o ID da conta a pagar para o Job MarkAsPaidJob. Esse trabalho busca a conta associada ao ID e tenta notificá-la. Dependendo da resposta da notificação, o trabalho pode marcar a conta como pagamento ou agendar novos testes em caso de falha. Se o processo for bem-sucedido, a conta será atualizada para "pagamento", mas, caso ocorram falhas repetidas, ela pode ser marcada como "failed"

Descrição do Job MarkAsPaidJob
O job MarkAsPaidJob é responsável por marcar uma conta a pagar como paga no sistema e enviar uma notificação sobre essa alteração para um endpoint externo. Esse processo é crucial para garantir que as transações financeiras sejam registradas corretamente, permitindo uma gestão eficaz do fluxo de caixa.

Funcionamento do Job

Execução do Job:

O job é chamado com um payable_id, que é o identificador da conta a pagar que deve ser marcada como paga.
Busca da Conta a Pagar:


O método perform começa buscando a conta a pagar no banco de dados usando o payable_id fornecido através do método find_payable. Se a conta não for encontrada, o job é encerrado imediatamente.
Verificação de Notificação:


Antes de prosseguir, o job verifica se a notificação deve ser enviada usando o método skip_notification?. Se a conta já tiver um reembolso registrado e pago, a notificação é pulada e um log é gerado informando que não é necessário enviar uma nova notificação.
Envio da Notificação:


Se a notificação não for pulada, o job chama o método handle_notification, que é responsável por enviar a notificação para o endpoint configurado. O payload da notificação é construído com informações relevantes sobre a conta a pagar.
Atualização do Status da Conta a Pagar:


Após enviar a notificação, o job atualiza o status da conta a pagar com base na resposta recebida do endpoint. Se a notificação for bem-sucedida (status 200), a conta é marcada como "paga". Caso contrário, o job lida com a falha de notificação.
Gerenciamento de Falhas:


Se ocorrer uma falha ao enviar a notificação, o job incrementa o contador de tentativas de notificação. Se o número de tentativas ultrapassar 3, a conta a pagar é marcada como "failed". Caso contrário, o job reprograma a notificação para tentar novamente após 10 minutos.
Construção do Payload:


O payload da notificação é construído a partir de dados essenciais da conta a pagar, como código da conta, código da categoria, código do cliente, custo e data de vencimento. O status da conta também é incluído no payload.
Envio da Requisição:


O job utiliza a biblioteca HTTParty para enviar uma requisição HTTP POST para o endpoint especificado, contendo o payload em formato JSON. O tratamento de erros é implementado para lidar com possíveis exceções durante o envio.
Logs e Registro
O job gera logs informativos e de erro em diversas etapas, permitindo que os desenvolvedores e administradores do sistema acompanhem o fluxo de execução e identifiquem problemas rapidamente.


Conclusão

O job MarkAsPaidJob assegura que o processo de marcação de contas a pagar como pagas seja realizado de forma robusta, com validações adequadas e manejo de erros. Essa funcionalidade é essencial para a manutenção da integridade dos registros financeiros da empresa e para a comunicação eficaz com sistemas externos.

Para executar o job, você pode utilizar o seguinte comando no console do Rails:

MarkAsPaidJob.perform_later(ID) # substitua pelo ID da conta a pagar que foi criada anteriormente no fluxo de contas a pagar.


Considerações Finais

A integração entre o sistema de reembolsos Espresso e o ERP Omie foi projetada para garantir a eficiência e a confiabilidade no processo de registro e monitoramento de contas a pagar. Cada um dos fluxos principais foi cuidadosamente elaborado para lidar com potenciais falhas e oferecer notificações em tempo real, contribuindo para uma melhor gestão financeira.
Com a automação desses processos, a comunicação entre os sistemas é simplificada, o que resulta em maior agilidade no processamento de reembolsos e no controle das transações. A utilização de tecnologias robustas como Ruby on Rails, Sidekiq e Redis, junto com a cobertura de testes com RSpec, garante que a aplicação seja confiável e possa escalar conforme a demanda.
Este projeto serve como uma base sólida para futuras melhorias e ampliações na integração com outros sistemas, garantindo que o fluxo de caixa da empresa seja sempre preciso e eficiente

