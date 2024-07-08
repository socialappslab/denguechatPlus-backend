# frozen_string_literal: true

class RegistrationMailer < ApplicationMailer
  def confirmation_instructions(email:, redirect_to:, token:)
    @link = build_link(redirect_to, token:)
    mail(to: email, subject: default_i18n_subject)
  end

  private

  def recipient
    UserAccount.name
  end
end
