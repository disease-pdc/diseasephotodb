class UpdateImageSourceCreateImageSets < ActiveRecord::Migration[6.1]

  def up
    execute %(
      ALTER TABLE image_sources 
        ALTER create_image_sets TYPE boolean
        USING CASE create_image_sets WHEN '1' THEN true ELSE false END;
      ALTER TABLE image_sources ALTER COLUMN create_image_sets SET DEFAULT FALSE;
      ALTER TABLE image_sources ALTER COLUMN create_image_sets SET NOT NULL;
    )
  end

  def down
    execute %(
      ALTER TABLE image_sources 
        ALTER create_image_sets TYPE text
      USING CASE create_image_sets WHEN true THEN '1' ELSE null END;
    )
  end

end