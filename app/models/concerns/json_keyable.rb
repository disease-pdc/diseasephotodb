require "active_support/concern"

module JsonKeyable
  extend ActiveSupport::Concern
  
  class_methods do
    def query_json_metadata_keys field
      result = ActiveRecord::Base.connection.execute %(
      SELECT
        DISTINCT field
      FROM (
        SELECT jsonb_object_keys(#{field}) AS field
        FROM #{self.table_name}
      ) AS subquery
      ORDER BY field
    ).squish
    result.map { |row| row['field'] }
    end
  end
end
