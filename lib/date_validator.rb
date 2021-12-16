class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.respond_to?(:strftime) 
      record.errors.add(attribute, options[:message] || "is an invalid date")
    end
  end
end