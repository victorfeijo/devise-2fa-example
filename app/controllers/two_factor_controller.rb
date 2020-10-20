class TwoFactorController < ApplicationController
  before_action :authenticate_user!

  def new
    provisioning_uri = current_user.provisioning_uri('Devise 2FA Example',
                                                     issuer: 'https://devise-2fa-example.com')

    qr_code = RQRCode::QRCode.new(provisioning_uri, size: 12, level: :h)

    @qr_code_svg = qr_code.as_svg(offset: 0, color: '000', shape_rendering: 'crispEdges', module_size: 4)
  end

  def create
    otp_response_code = two_factor_params[:otp_response_code]

    if current_user.authenticate_otp(otp_response_code)
      current_user.touch(:otp_enabled_at)

      redirect_to root_path, notice: '2FA successfully enabled.'
    else
      redirect_to new_two_factor_path, notice: 'Authenticator code is invalid.'
    end
  end

  private

  def two_factor_params
    params.permit(:otp_response_code)
  end
end
