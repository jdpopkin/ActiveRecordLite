require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable
  extend Associatable
  #my_attr_accessible :assoc_params
  @assoc_params = nil
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
    attrib_names, qmark_string, attrib_vals = strings_and_attribs
    attrib_name_string = attrib_names.join(", ")

    DBConnection.execute(<<-SQL, *attrib_vals)
     INSERT INTO #{self.class.table_name} (#{attrib_name_string})
     VALUES
     (#{qmark_string})
     SQL
     @id = DBConnection.last_insert_row_id
     self
  end

  def update
    # query db
    attrib_names, qmark_string, attrib_vals = strings_and_attribs
    attrib_name_string = attrib_names.join(" = ?, ") << " = ?"
    attrib_vals << self.id

    DBConnection.execute(<<-SQL, *attrib_vals)
    UPDATE #{self.class.table_name}
    SET #{attrib_name_string}
    WHERE id = ?
    SQL
  end

  def strings_and_attribs
    attrib_names = self.class.attributes - [:id]
    qmark_string = ("?, " * attrib_names.count)[0...-2]
    attrib_vals = attrib_names.map { |name| self.send(name) }
    [attrib_names, qmark_string, attrib_vals]
  end

  def save
    self.create if self.id.nil?
    self.update unless self.id.nil?
  end

  def attribute_values
  end
end
