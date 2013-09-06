class MassObject

  def self.set_attrs(*attributes)
  end

  def self.my_attr_accessible(*attributes)
    attributes.each do |attribute|
      attr_accessor(attribute.to_sym) # no to_sym?
    end

    # get all attributes?
    # self.instance_variables
    @attributes = attributes.map(&:to_sym) #no map?
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    objects = []
    results.each do |result|
      objects << new(result)
    end
    objects
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      # proper
      if self.class.attributes.include?(attr_name.to_sym) # black magic; check
        self.send("#{attr_name}=", value)
      else
        raise Exception.new("mass assignment to unregistered attribute #{attr_name}")
      end
    end
  end
end
