require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
  end

  def other_table
  end
end

class BelongsToAssocParams < AssocParams
  attr_accessor :name, :other_class_name, :primary_key, :foreign_key
   #:other_class, :other_table_name # idk about this

  def initialize(name, params)
    self.name = name

    if params[:other_class_name].nil?
      self.other_class_name = name.to_s.camelize
    else
      self.other_class_name = params[:other_class_name]
    end

    if params[:primary_key].nil?
      self.primary_key = "id"
    else
      self.primary_key = params[:primary_key]
    end

    if params[:foreign_key].nil?
      self.foreign_key = name.to_s + "_id"
    else
      self.foreign_key = params[:foreign_key].to_s
    end


    # self.other_class = other_class_name.to_s.constantize
#     self.other_table_name = other_class.table_name
  end

  def other_class
    other_class_name.to_s.constantize
  end

  def other_table_name
    other_class.table_name
  end

  def type
    :belongs_to
  end
end

class HasManyAssocParams < AssocParams
  attr_accessor :name, :other_class_name, :primary_key, :foreign_key,
   :other_class, :other_table_name

   # WARNING not changed from belongs_to
  def initialize(name, params, self_class)
    self.name = name

    if params[:other_class_name].nil?
      self.other_class_name = name.to_s.singularize.camelize
    else
      self.other_class_name = params[:other_class_name]
    end

    if params[:primary_key].nil?
      self.primary_key = "id"
    else
      self.primary_key = params[:primary_key]
    end

    if params[:foreign_key].nil?
      self.foreign_key = self_class.to_s.underscore + "_id"
    else
      self.foreign_key = params[:foreign_key].to_s
    end

    self.other_class = other_class_name.to_s.constantize
    self.other_table_name = other_class.table_name
  end

  def type
    :has_many
  end
end

module Associatable
  def assoc_params
    @assoc_params ||= {} # really?
  end

  def belongs_to(name, params = {})
    belongs_instance = BelongsToAssocParams.new(name, params)

    self.send(:define_method, "#{name}") do #|name, params|
      # make query and get hashes back
      # foreign key stored on our side.
      # TODO: Is all that self.send drama necessary?
      hashes = DBConnection.execute(<<-SQL,       self.send(belongs_instance.foreign_key))
      SELECT *
      FROM #{belongs_instance.other_table_name}
      WHERE #{belongs_instance.primary_key} = ?
      SQL

      belongs_instance.other_class.parse_all(hashes).first
    end

    assoc_hash = self.assoc_params
    assoc_hash[belongs_instance.name] = belongs_instance
  end

  def has_one_through(name, assoc1, assoc2)
    #through_params = self.assoc_params[assoc1]
    self.send(:define_method, "#{name}") do
      # you don't even need a new kind of instance i bet. just be smart with
      # the two you have.
      #p "Z"

      through_params = self.class.assoc_params[assoc1]

      has_params = through_params.other_class.assoc_params[assoc2]

      hashes = DBConnection.execute(<<-SQL, self.send(:id)) # id?
      SELECT #{has_params.other_table_name}.*
      FROM #{has_params.other_table_name}
      JOIN #{through_params.other_table_name}
      ON #{has_params.other_table_name}.#{has_params.primary_key} = #{through_params.other_table_name}.#{has_params.foreign_key}
      JOIN #{self.class.table_name}
      ON #{self.class.table_name}.#{through_params.foreign_key} = #{through_params.other_table_name}.#{through_params.primary_key}
      WHERE #{self.class.table_name}.id = ? -- really?
      SQL
      has_params.other_class.parse_all(hashes).first
    end
  end

  def has_many(name, params = {})
    self.send(:define_method, "#{name}") do
      has_instance = HasManyAssocParams.new(name, params, self.class)


      hashes = DBConnection.execute(<<-SQL, self.id) # FIX THIS
      SELECT #{has_instance.other_table_name}.*
      FROM #{self.class.table_name}
      JOIN #{has_instance.other_table_name}
      ON #{has_instance.foreign_key} = #{self.class.table_name}.#{has_instance.primary_key}
      WHERE #{has_instance.foreign_key} = ?
      SQL

      has_instance.other_class.parse_all(hashes)
    end
  end
end
