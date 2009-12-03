module Exceptional
	def self.handle_sinatra(exception, uri, request, params)
		e = Exceptional.parse(exception)
 
		e.framework = "sinatra"
		e.controller_name = uri
		e.occurred_at = Time.now.strftime("%Y%m%d %H:%M:%S %Z")
		e.environment = request.env.to_hash
		e.url = uri
		e.parameters = params.to_hash
 
		Exceptional.post e
	end
end
