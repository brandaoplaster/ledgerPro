module Instruments
  class FilterService
      ALLOWED_SORTS = %w[ticker name kind created_at].freeze

      def initialize(params = {})
        @params = params
        @scope = Instrument.all
      end

      def call
        apply_search
        apply_filters
        apply_sorting
        @scope
      end

      private

      def apply_search
        return unless @params[:search].present?

        @scope = @scope.where("ticker ILIKE ? OR name ILIKE ?",
                              "%#{@params[:search]}%",
                              "%#{@params[:search]}%")
      end

      def apply_filters
        return unless @params[:kind].present?

        @scope = @scope.where(kind: @params[:kind])
      end

      def apply_sorting
        column = @params.dig(:order, :column) || "created_at"
        direction = @params.dig(:order, :direction) || "desc"

        column = "created_at" unless ALLOWED_SORTS.include?(column)
        direction = direction == "asc" ? "asc" : "desc"

        @scope = @scope.order("#{column} #{direction}")
      end
  end
end
