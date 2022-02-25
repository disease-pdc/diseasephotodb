class ImagesController < ApplicationController

  before_action :require_image_view, only: [:index, :show]
  before_action :require_image_admin, only: [:create, :update, :destroy]

  def index

  end

end
