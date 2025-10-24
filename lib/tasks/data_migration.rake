# frozen_string_literal: true

namespace :data_migration do
  desc 'Add permission for bulk_upload endpoint'
  task add_permission: :environment do
    permission = Permission.find_or_create_by(name: 'bulk_upload', resource: 'visits')

    roles = Role.where(name: %w[admin])
    roles.each { |role| role.permissions << permission unless role.permissions.include?(permission) }

    puts '✅ Bulk upload permission for visits created and assigned!'
  end

  desc 'Fix label mismatch between environment for some options'
  task fix_labels: :environment do
    Option.find_by!(name_es: 'Si, tiene tapa y está bien cerrado').update(name_es: 'Sí, tiene tapa y está bien cerrado')
    Option.find_by!(name_es: 'Si, tiene tapa pero no está bien cerrado').update(name_es: 'Sí, tiene tapa pero no está bien cerrado')
  end
end
