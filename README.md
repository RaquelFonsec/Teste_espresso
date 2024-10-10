

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
rails db

Inicia o servidor Redis
redis-server

Inicia o Sidekiq em segundo plano
bundle exec sidekiq

Inicia o servidor Rails
rails server

Executa os testes com RSpec
bundle exec rspec

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
ENV["APP_KEY"]: Chave da aplicação obtida das variáveis de ambiente, utilizada para autenticação na API do Omie.
ENV["APP_SECRET"]: Segredo da aplicação, também obtido das variáveis de ambiente, para autenticação.
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



O fluxo de criação de contas a pagar tem como objetivo registrar os reembolsos aprovados no sistema Espresso e criar as respectivas contas a pagar no ERP Omie. Esse processo é essencial para garantir que as transações financeiras sejam adequadamente registradas e que o fluxo de caixa da empresa seja mantido em ordem

Execução do Comando

Para iniciar a criação de uma conta a pagar, utilize o seguinte comando:



Rails c


 :CreatePayableAccountJob.perform_later(client_params: {
  client_id: xxxx,
  erp_key: ENV['ERP_KEY'],                        # Chave do ERP (obtida da variável de ambiente)
  erp_secret: ENV['ERP_SECRET'],                  # Segredo do ERP (obtida da variável de ambiente)
  category_code: "2.01.04",
  account_code: xxxxxx,
  due_date: "xxxxx",
  cost: xxxxxx,
  codigo_lancamento_integracao: "xxxxx",
  client_code: "xxxxxxx",
  categoria: "D"
})





client_id:Identificador único do cliente no sistema, utilizado para associar as contas a pagar ao cliente correto obtido nos fluxos anteriores

erp_key:Chave de autenticação da aplicação, que permite que o sistema se conecte ao ERP Omie para criar a conta a pagar.

erp_secret:Segredo da aplicação, utilizado em conjunto com a chave (erp_key) para autenticação no ERP Omie

category_code: "2.01.04" Código da categoria que classifica a conta a pagar.

account_code: Código da conta corrente onde a transação será registrada,obtida nos fluxos anteriores

due_date: Data de vencimento da conta a pagar, que determina quando o pagamento deve ser efetuado.

cost: Valor da conta a pagar, representando a quantia que deve ser paga ao fornecedor ou prestador de serviço.

codigo_lancamento_integracao: Código de integração que pode ser utilizado para rastrear o lançamento específico no sistema, permitindo um melhor controle e auditoria,obtido nos fluxos anteriores

client_code: Código do cliente que pode ser utilizado para identificar rapidamente as informações do cliente no sistema, especialmente útil para integração com outros sistemas.

categoria: "D" Representa a categoria da conta a pagar, que pode ser usada para fins de classificação contábil ou relatório



**Resumo do Fluxo de Criação de Contas a Pagar**


O job CreatePayableAccountJob realiza o seguinte fluxo para criar contas a pagar:

  

Recebimento dos Parâmetros: Recebe dados como ID do cliente, chaves de autenticação, categoria, código da conta, data de vencimento e valor.

Validação da Data de Vencimento: Converte a data de vencimento em um objeto de data e verifica se é válida.

Verificação de Disponibilidade do Servidor: Confirma se a API do Omie está acessível; se não, tenta novamente até 3 vezes.

Validação dos Parâmetros: Utiliza um validador para garantir que todos os dados estão corretos; se houver erros, notifica a falha.
Criação da Conta a Pagar: Se tudo estiver válido, tenta criar a conta a pagar e a salva no banco de dados.
Notificações: Envia notificações sobre o status da operação (sucesso ou falha) e registra os resultados no log.
Esse fluxo assegura que as contas a pagar sejam criadas de maneira confiável, com validação e tratamento de erros adequados.



##Fluxo de Baixa de Pagamento



Para executar o job, você pode utilizar o seguinte comando no console do Rails:

MarkAsPaidJob.perform_later(ID) # substitua pelo ID da conta a pagar que foi criada anteriormente no fluxo de contas a pagar.


O job MarkAsPaidJob é responsável por processar a baixa de uma conta a pagar, marcando-a como paga e enviando uma notificação sobre essa alteração. O fluxo é composto pelas seguintes etapas:

Recebimento do ID da Conta a Pagar: O job é chamado com um payable_id, que representa a conta a pagar que será processada.

Localização da Conta a Pagar: O job busca a conta a pagar correspondente no banco de dados utilizando o ID fornecido. Se a conta não for encontrada, o processo é interrompido e um log de erro é registrado.

Verificação de Notificação: O job verifica se a conta a pagar já tem um reembolso registrado. Se um reembolso existir, a notificação é pulada, e um log é gerado.
Envio de Notificação: Caso a notificação não seja pulada, o job cria um payload contendo as informações da conta a pagar e tenta enviar uma notificação para o endpoint específico.

Atualização do Status: Se a notificação for enviada com sucesso, a conta a pagar é marcada como "paga". Se a notificação falhar, o job gerencia a falha, registrando tentativas e, se necessário, reprogramando uma nova tentativa de notificação.
Tentativas de Notificação: O job permite até três tentativas de notificação. Se o limite for atingido, o status da conta a pagar é atualizado para "failed".


Considerações Finais

A integração entre o sistema de reembolsos Espresso e o ERP Omie foi projetada para garantir a eficiência e a confiabilidade no processo de registro e monitoramento de contas a pagar. Cada um dos fluxos principais foi cuidadosamente elaborado para lidar com potenciais falhas e oferecer notificações em tempo real, contribuindo para uma melhor gestão financeira.
Com a automação desses processos, a comunicação entre os sistemas é simplificada, o que resulta em maior agilidade no processamento de reembolsos e no controle das transações. A utilização de tecnologias robustas como Ruby on Rails, Sidekiq e Redis, junto com a cobertura de testes com RSpec, garante que a aplicação seja confiável e possa escalar conforme a demanda.
Este projeto serve como uma base sólida para futuras melhorias e ampliações na integração com outros sistemas, garantindo que o fluxo de caixa da empresa seja sempre preciso e eficiente

