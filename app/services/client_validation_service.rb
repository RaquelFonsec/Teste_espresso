
class ClientValidationService
  
    def self.validate_keys(app_key, app_secret)
      response = HTTParty.post("https://api.example.com/v1/geral/clientes", 
                                body: { app_key: app_key, app_secret: app_secret }.to_json,
                                headers: { 'Content-Type' => 'application/json' })
  
      if response.success?
        { success: true, message: 'Credenciais válidas.' }
      else
        { success: false, message: response.parsed_response['error'] }
      end
    end
  end
  