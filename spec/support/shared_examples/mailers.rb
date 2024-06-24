# frozen_string_literal: true

RSpec.shared_examples 'mail with correct headers' do
  it 'renders the headers' do
    expect(mail.subject).to eq(mail_subject)
    expect(mail.to).to eq([try(:email) || user_profile.user_account.email])
    expect(mail.from).to eq(['no-reply@denguechatplus.com'])
    expect(mail.from_address.name).to eq('DengueChatPlus')
  end
end
