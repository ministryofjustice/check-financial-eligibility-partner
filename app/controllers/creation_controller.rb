class CreationController < ApplicationController
private

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

  def validate_schema(schema_name, parameters)
    json_validator = JsonSwaggerValidator.new(schema_name, parameters)
    unless json_validator.valid?
      render_unprocessable(json_validator.errors)
    end
  end
end
