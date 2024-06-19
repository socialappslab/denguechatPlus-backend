# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Constants::Mailers::DEFAULT_FROM
  layout 'mailer'

  protected

  def build_link(...)
    Services::FrontendUrlBuilder.call(...)
  end

  def recipient
    raise NotImplementedError, 'recipient has to be overridden (UserAccount.name)'
  end
end
