class NumericValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.is_a? Numeric
      record.errors.add(attribute, options[:message] || "is not a number")
    end
  end
end