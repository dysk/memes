# encoding: UTF-8

require 'random_data'

module GenerateId

  def provide_unique_id(column, prefix='', limit=20)
    Guid.new(klass: self.class, column: column, prefix: prefix, limit: limit).to_s
  end

  class Guid
    def initialize(hash)
      @klass  = hash[:klass]
      @column = hash[:column].to_sym if hash[:column].present?
      @prefix = hash[:prefix].to_s
      @limit  = hash[:limit] || 12
      raise(ArgumentError, ":klass and :column arguments are mandatory!") unless @klass.present? && @column.present?
      @value  = render_unique
    end

    def to_s
      @value
    end

    private

      def render_unique
        loop do
          unique_id = SecureRandom.urlsafe_base64(@limit)
          unique_id = unique_id.insert(0, "#{@prefix}_") if @prefix.present? && @prefix.length > 0
          unique_id = unique_id[0..@limit-1]
          break unique_id unless @klass.where(@column => unique_id).first
        end
      end
  end
end
