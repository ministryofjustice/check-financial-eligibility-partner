class CreationController < ApplicationController
  def create_object(schema_name, parameters, creator)
    json_validator = JsonSwaggerValidator.new(schema_name, parameters)
    if json_validator.valid?
      result = creator.call
      if result.success?
        render_success
      else
        render_unprocessable(result.errors)
      end
    else
      render_unprocessable(json_validator.errors)
    end
  end
end
