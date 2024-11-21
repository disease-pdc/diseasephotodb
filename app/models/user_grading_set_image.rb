class UserGradingSetImage < ApplicationRecord

  FIXED_CSV_HEADERS = %w(id grading_set name source user_id user_email)

  YES_NO_VALUES = {
    yes: 'y',
    no: 'n'
  }

  GRADE_VALUES = {
    positive: 'p',
    negative: 'n',
    maybe_positive: 'mp',
    maybe_negative: 'mn'
  }

  belongs_to :user
  belongs_to :grading_set_image

  def self.search params
    # Seach via grading set
    if !params[:grading_sets].blank?
      gsp = params[:grading_sets]
      return self.joins(:grading_set_image, :user)
        .where("grading_set_images.grading_set_id = ?", gsp[:id])

    # Search via image_set 
    elsif !params[:image_sets].blank?
      ids = params[:image_sets][:image_set_id_all] ?
        ImageSet.search(params).select(:id).map(&:id) :
        params[:image_sets][:image_set_ids]
      return self.joins(:grading_set_image)
        .where("grading_set_images.gradeable_type = 'ImageSet'")
        .where("grading_set_images.gradeable_id in (?)", ids)
    
    # Search via image params
    elsif !params[:images].blank?

      if !params[:images][:image_set_gradingdata].blank?
        ids = params[:images][:image_id_all] ?
          Image.joins({image_set_images: :image_set})
            .search(params).select("id", "image_sets.id as image_set_id")
            .map(&:image_set_id).uniq :
          Image.joins({image_set_images: :image_set})
            .where("id in (:ids)", params[:images][:image_ids])
            .search(params).select("id", "image_sets.id as image_set_id")
            .map(&:image_set_id).uniq
        return self.joins(:grading_set_image)
          .where("grading_set_images.gradeable_type = 'ImageSet'")
          .where("grading_set_images.gradeable_id in (?)", ids)
      else
        ids = params[:images][:image_id_all] ?
          Image.search(params).select(:id).map(&:id) :
          params[:images][:image_ids]
        return self.joins(:grading_set_image)
          .where("grading_set_images.gradeable_type = 'Image'")
          .where("grading_set_images.gradeable_id in (?)", ids)
      end
      
    end
  end

  def self.data_csv_headers search_params
    headers = [] + FIXED_CSV_HEADERS
    UserGradingSetImage.search(search_params).find_in_batches do |batch|
      batch.each do |user_grading_set_image|
        user_grading_set_image.grading_data.each do |k,v|
          if v.is_a? Array
            v.each do |option|
              header = "#{k}.#{option}"
              headers << header unless headers.include?(header)
            end
          else
            headers << k unless headers.include?(k)
          end
        end
      end
    end
    return headers
  end

  def self.data_csv_enumerator search_params
    Enumerator.new do |yielder|
      headers = nil
      UserGradingSetImage.search(search_params).find_in_batches do |batch|
        batch.each do |user_grading_set_image|
          unless headers
            headers = UserGradingSetImage.data_csv_headers(search_params)
            yielder << CSV.generate_line(headers)
          end
          yielder << CSV.generate_line(
            user_grading_set_image.data_csv_line(headers)
          )
        end
      end
    end
  end

  def data_csv_line headers
    line = [
      id,
      grading_set_image.grading_set.name,
      grading_set_image.gradeable.name,
      grading_set_image.gradeable.image_source.name,
      user.id,
      user.email
    ]
    headers.drop(FIXED_CSV_HEADERS.length).each do |header|
      if header.include?(".")
        k, v = header.split(".")
        line << (grading_data[k] && grading_data[k].include?(v) ? '1' : nil)
      else
        line << grading_data[header]
      end
    end
    return line
  end

  def grade_text
    TEXT_VALUES[grade] || 'Unknown grade value'
  end

end
