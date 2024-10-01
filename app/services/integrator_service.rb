require 'net/http'
require 'json'
require 'httparty'

class IntegratorService
  def initialize(company_id)
    @company_id = company_id
    @url = 'https://api.omie.com.br/api/v1/financas/contapagar/'
    @key = 'YOUR_OMIE_API_KEY'  # Substitua pela sua chave de API
    @secret = 'YOUR_OMIE_API_SECRET'  # Substitua pelo seu segredo de API
  end

  def create_payable(client_code, category_code, account_code, due_date, cost, description = "Reembolso aprovado")
    uri = URI(@url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    request.body = {
      "call": "incluirContaAPagar",
      "app_key": @key,
      "app_secret": @secret,
      "param": [{
        "codigo_empresa": @company_id,
        "codigo_cliente": client_code,
        "codigo_categoria": category_code,
        "codigo_conta": account_code,
        "data_vencimento": due_date,
        "valor": cost,
        "descricao": description
      }]
    }.to_json

    response = http.request(request)
    parsed_response = JSON.parse(response.body)

    if parsed_response['success']
      puts "Conta a pagar criada com sucesso: #{parsed_response}"
    else
      puts "Erro ao criar conta a pagar: #{parsed_response['message']}"
    end

    parsed_response
  end

  def create_webhook(erp_key, erp_secret)
    # URL do endpoint para criação de webhooks (substitua se necessário)
    webhook_url = 'https://api.omie.com.br/api/v1/webhook/'
    uri = URI(webhook_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    request.body = {
      "webhook": {
        "success": true,
        "client_id": "12345",  # ou use o client_id real
        "company_id": @company_id,
        "erp_key": erp_key,
        "erp_secret": erp_secret,
        "url": "0a12-2a02-a474-b1c4-1-c97d-bd11-cecd-4945.ngrok-free.app/webhooks/subscribe"
      }
    }.to_json

    response = http.request(request)
    parsed_response = JSON.parse(response.body)

    if parsed_response['success']
      puts "Webhook criado com sucesso: #{parsed_response}"
    else
      puts "Erro ao criar webhook: #{parsed_response['message']}"
    end

    parsed_response
  end
end

class ClientService
  def self.validate_client(client)
    url = 'https://integrador.com/api/v1/geral/clientes'

    response = HTTParty.post(url, body: {
      app_key: client.app_key,
      app_secret: client.app_secret
    }.to_json, headers: { 'Content-Type' => 'application/json' })

    parsed_response = JSON.parse(response.body)

    if response.success?
      puts "Validação de cliente bem-sucedida: #{parsed_response}"
    else
      puts "Falha na validação do cliente: #{parsed_response['message']}"
    end

    parsed_response
  end
end
