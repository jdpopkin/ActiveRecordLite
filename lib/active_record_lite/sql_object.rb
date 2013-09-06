require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  def self.set_table_name(table_name)
    @table_name = table_name

    # TODO: use active_support/inflector to supply default value
  end

  def self.table_name
    @table_name
  end

  def self.all
    hashes = DBConnection.execute(<<-SQL)
    SELECT *
    FROM #{@table_name}
    SQL

    object_arr = []
    hashes.each do |hash|
      object_arr << self.new(hash)
    end
    object_arr
  end

  def self.find(id)
    hash = DBConnection.execute(<<-SQL, id)
    SELECT *
    FROM #{@table_name}
    WHERE
    id = ?
    SQL

    return nil if hash.empty?
    self.new(hash.first)
  end

  def create
  end

  def update
  end

  def save
  end

  def attribute_values
  end
end
