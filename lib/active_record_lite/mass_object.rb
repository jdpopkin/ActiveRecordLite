class MassObject

  def self.set_attrs(*attributes)
  end

  def self.my_attr_accessible(*attributes)
    attributes.each do |attribute|
      attr_accessor(attribute)
    end

    # get all attributes?
    # self.instance_variables
    @attributes = attributes
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      if self.class.attributes.include?(attr_name) # black magic; check
        self.send("#{attr_name}=", value)
      else
        raise GeneralError.new("mass assignment to unregistered attribute #{attr_name}")
      end
    end
  end
end
