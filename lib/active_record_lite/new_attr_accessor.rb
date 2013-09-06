class Object
  def new_attr_accessor(*args)
    args.each do |arg|
      self.send(:define_method, "#{arg}".to_sym) do
        instance_variable_get("@#{arg}")
      end

      self.send(:define_method, "#{arg}=".to_sym) do |argu|
        instance_variable_set("@#{arg}".to_sym, argu)
      end
    end
  end
end

class Cat
  new_attr_accessor :name, :color

end

cat = Cat.new
cat.name = "Sally"
p cat