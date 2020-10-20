module AuthenticateWithOtpTwoFactor
  extend ActiveSupport::Concern

  def authenticate_with_otp_two_factor
    user = self.resource = find_user

    if user_params[:otp_response_code].present? && session[:otp_user_id]
      authenticate_user_with_otp_two_factor(user)
    elsif user&.valid_password?(user_params[:password])
      prompt_for_otp_two_factor(user)
    end
  end

  private

  def prompt_for_otp_two_factor(user)
    @user = user

    session[:otp_user_id] = user.id

    render 'two_factor/verify'
  end

  def authenticate_user_with_otp_two_factor(user)
    if user.authenticate_otp(user_params[:otp_response_code])
      session.delete(:otp_user_id)

      user.save!
      sign_in(user, event: :authentication)
    else
      flash.now[:alert] = 'Invalid 2FA code.'
      prompt_for_otp_two_factor(user)
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :otp_response_code)
  end

  def find_user
    if session[:otp_user_id].present?
      User.find(session[:otp_user_id])
    elsif user_params[:email].present?
      User.find_by(email: user_params[:email])
    end
  end

  def otp_two_factor_enabled?
    find_user&.otp_enabled_at?
  end
end
