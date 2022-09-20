class ApplicationController < ActionController::Base

  helper_method :current_user
  before_action :require_login

  FORBIDDEN_MESSAGE = 'You do not have access to this page.'

  private

    def require_login
      unless current_user
        return redirect_to controller: 'sessions', action: 'new'
      end
    end

    def require_image_admin
      unless current_user.admin? || current_user.image_admin?
        return render status: :forbidden, html: FORBIDDEN_MESSAGE
      end
    end

    def require_image_viewer
      unless current_user.admin? || current_user.image_admin? || current_user.image_viewer?
        return render status: :forbidden, html: FORBIDDEN_MESSAGE
      end
    end

    def require_admin
      unless current_user.admin?
        return render status: :forbidden, html: FORBIDDEN_MESSAGE
      end
    end

    def current_user
      @current_user ||= User.active.find(session[:user_id]) if session[:user_id]
    end

end
