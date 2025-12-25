require "simplecov"
require "simplecov_json_formatter"

SimpleCov.start do
  add_group "Controllers", "app/controllers"
  add_group "Models", "app/models"
  add_group "Services", "app/services"
end
