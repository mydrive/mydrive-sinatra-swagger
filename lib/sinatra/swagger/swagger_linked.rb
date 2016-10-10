require "swagger/rack"

module Sinatra
  module Swagger
    module SwaggerLinked
      def swagger(filepath)
        set :swagger, ::Swagger::Base.from_file(filepath)
      end

      def self.registered(app)
        app.helpers Helpers
      end

      module Helpers
        def request_path
          env['REQUEST_PATH'] || env['PATH_INFO']
        end

        def request_verb
          env['REQUEST_METHOD'].downcase
        end

        def swagger_spec
          raise "No swagger file loaded" unless settings.swagger
          settings.swagger.request_spec(env: env)
        end

        def schema_from_spec_at(path)
          schema = swagger_spec[:spec]
          path.split("/").each do |key|
            schema = schema[YAML.load(key)]
            raise "No schema response matching path: #{path} for #{request_verb} #{request_path}" if schema.nil?
          end
          schema['definitions'] = settings.swagger['definitions'] if settings.swagger['definitions']
          schema
        end
      end
    end
  end
end
