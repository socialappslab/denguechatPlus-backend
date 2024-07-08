# frozen_string_literal: true

return unless Rails.env.development?

require 'annotate'

desc 'Sets annotation options'
task set_annotation_options: :environment do
  Annotate.set_defaults(
    active_admin: false,
    additional_file_patterns: [],
    classified_sort: true,
    exclude_controllers: true,
    exclude_factories: false,
    exclude_fixtures: false,
    exclude_helpers: true,
    exclude_scaffolds: true,
    exclude_serializers: false,
    exclude_sti_subclasses: false,
    exclude_tests: false,
    force: false,
    format_bare: true,
    format_markdown: false,
    format_rdoc: false,
    format_yard: false,
    frozen: false,
    hide_default_column_types: 'json,jsonb,hstore',
    hide_limit_column_types: 'integer,bigint,boolean',
    ignore_columns: nil,
    ignore_model_sub_dir: false,
    ignore_routes: nil,
    ignore_unknown_models: false,
    include_version: false,
    model_dir: 'app/models',
    models: true,
    position_in_class: 'before',
    position_in_factory: 'before',
    position_in_fixture: 'before',
    position_in_routes: 'before',
    position_in_serializer: 'before',
    position_in_test: 'before',
    require: '',
    root_dir: '',
    routes: false,
    show_complete_foreign_keys: false,
    show_foreign_keys: true,
    show_indexes: true,
    simple_indexes: false,
    skip_on_db_migrate: false,
    sort: false,
    trace: false,
    with_comment: true,
    wrapper_close: nil,
    wrapper_open: nil
  )
end

Annotate.load_tasks
