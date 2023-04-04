module Creators
  class VehicleCreator < BaseCreator
    attr_accessor :vehicles

    def initialize(vehicles_params:, capital_summary:)
      super()
      @vehicles_params = vehicles_params
      @capital_summary = capital_summary
    end

    def call
      create_records
      self
    end

  private

    def create_records
      create_vehicles
    rescue CreationError => e
      self.errors = e.errors
    end

    def create_vehicles
      self.vehicles = @capital_summary.vehicles.create!(vehicles_attributes)
    rescue ActiveRecord::RecordInvalid => e
      raise CreationError, e.record.errors.full_messages
    end

    def vehicles_attributes
      @vehicles_attributes ||= @vehicles_params[:vehicles]
    end
  end
end
