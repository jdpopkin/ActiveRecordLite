require_relative './db_connection'

module Searchable
  def where(params)
    keys = params.keys
    vals = params.values

    key_strings = keys.map do |key|
      "#{key.to_s} = ?"
    end
    where_string = key_strings.join(" AND ")

    hashes = DBConnection.execute(<<-SQL, *vals)
    SELECT *
    FROM #{@table_name}
    WHERE #{where_string}
    SQL
  end
end