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
  attr_accessor :name, :other_class_name, :primary_key, :foreign_key,
   :other_class, :other_table_name # idk about this

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
      self.foreign_key = params[:foreign_key]
    end

    self.other_class = other_class_name.to_s.constantize
    self.other_table_name = other_class.table_name
  end

  def type
    :belongs_to
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    self.send(:define_method, "#{name}") do #|name, params|
      belongs_instance = BelongsToAssocParams.new(name, params)
      # assemble needed values in order


      # make query and get hashes back
      hashes = DBConnection.execute(<<-SQL, self.id)
      SELECT *
      FROM #{belongs_instance.other_table_name}
      WHERE #{belongs_instance.foreign_key} = ?
      SQL

      belongs_instance.other_class.parse_all(hashes).first
    end
  end

  def has_many(name, params = {})
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
