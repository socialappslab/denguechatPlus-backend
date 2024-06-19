class AddResourceReferenceToRole < ActiveRecord::Migration[7.1]
  def change
    add_reference :roles, :resource, polymorphic: true

    add_index(:roles, %i[name resource_type resource_id])
  end
end
