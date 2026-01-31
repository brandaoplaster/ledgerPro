class StrategyRule < ApplicationRecord
  belongs_to :strategy

  attr_accessor :rule_type
  attr_accessor :min_percentage  # Temporário até criar a migration

  validates :asset_kind, presence: true
  validates :strategy_id, presence: true
  validate :validate_percentage_rule, if: -> { rule_type == "percentage" }
  validate :validate_prohibition_rule, if: -> { rule_type == "prohibition" }

  # Métodos auxiliares
  def prohibition?
    max_percentage.nil? && (min_percentage.nil? || min_percentage.blank?)
  end

  def percentage_rule?
    max_percentage.present? || min_percentage.present?
  end

  private

  def validate_percentage_rule
    if min_percentage.present? && max_percentage.present?
      if min_percentage.to_f > max_percentage.to_f
        errors.add(:min_percentage, "deve ser menor ou igual à porcentagem máxima")
      end
      if min_percentage.to_f < 0 || min_percentage.to_f > 100
        errors.add(:min_percentage, "deve estar entre 0 e 100")
      end
      if max_percentage.to_f < 0 || max_percentage.to_f > 100
        errors.add(:max_percentage, "deve estar entre 0 e 100")
      end
    elsif min_percentage.blank? && max_percentage.blank?
      errors.add(:base, "Por favor, informe pelo menos a porcentagem mínima ou máxima")
    end
  end

  def validate_prohibition_rule
    # Para proibição, não deve ter porcentagens
    if min_percentage.present? || max_percentage.present?
      errors.add(:base, "Regras de proibição não devem ter porcentagens definidas")
    end
  end
end
