class DashboardController < ApplicationController

  def index
    @user_grading_sets = current_user.user_grading_sets.order('created_at desc')
  end

end
