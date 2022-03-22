class HomeController < ApplicationController

  skip_before_action :require_login

  def index
    if current_user
      @user_grading_sets = current_user.user_grading_sets
        .order('created_at desc')
        .limit(3)
    end
  end

end
