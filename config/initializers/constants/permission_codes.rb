# frozen_string_literal: true

module Constants
  module PermissionCodes
    CODE = {
      expired_token: :expired_token,
      not_found: :token_not_found,
      invalid_token: :invalid_token,
      no_specified: :no_specified,
      organizations_index: :organizations_index,
      organizations_show: :organizations_show,
      organizations_create: :organizations_create,
      organizations_edit: :organizations_edit,
      organizations_update: :organizations_update,
      users_index: :users_index,
      users_show: :users_show,
      users_create: :users_create,
      users_edit: :users_edit,
      users_update: :users_update,
      roles_index: :roles_index,
      roles_show: :roles_show,
      roles_create: :roles_create,
      roles_edit: :roles_edit,
      roles_update: :roles_update,
      teams_index: :teams_index,
      teams_show: :teams_show,
      teams_create: :teams_create,
      teams_edit: :teams_edit,
      teams_update: :teams_update,
      posts_index: :posts_index,
      posts_show: :posts_show,
      posts_create: :posts_create,
      posts_edit: :posts_edit,
      posts_update: :posts_update,
      comments_index: :comments_index,
      comments_show: :comments_show,
      comments_create: :comments_create,
      comments_edit: :comments_edit,
      comments_update: :comments_update,
      houses_index: :houses_index,
      houses_show: :houses_show,
      houses_create: :houses_create,
      houses_edit: :houses_edit,
      houses_update: :houses_update,
      breading_sites_index: :breading_sites_index,
      breading_sites_show: :breading_sites_show,
      breading_sites_create: :breading_sites_create,
      breading_sites_edit: :breading_sites_edit,
      breading_sites_update: :breading_sites_update,
      elimination_methods_index: :elimination_methods_index,
      elimination_methods_show: :elimination_methods_show,
      elimination_methods_create: :elimination_methods_create,
      elimination_methods_edit: :elimination_methods_edit,
      elimination_methods_update: :elimination_methods_update,
      visits_index: :visits_index,
      visits_show: :visits_show,
      visits_create: :visits_create,
      visits_edit: :visits_edit,
      visits_update: :visits_update,
      cities_create: :cities_create,
      cities_index: :cities_index,
      cities_show: :cities_show,
      cities_destroy: :cities_destroy,
      house_blocks: :house_blocks_index,
      users_change_status: :users_change_status,
      wedges_index: :wedges_index
    }.freeze
  end
end
