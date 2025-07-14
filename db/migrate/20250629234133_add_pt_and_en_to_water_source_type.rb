class AddPtAndEnToWaterSourceType < ActiveRecord::Migration[7.1]
  def up
    add_column :water_source_types, :name_en, :string, null: true
    add_column :water_source_types, :name_pt, :string, null: true

    translations = {
      'Del grifo o de otro envase' => {
        en: 'From the tap or another container',
        pt: 'Da torneira ou de outro recipiente'
      },
      'Agua activamente recogida. Ejemplo: canaleta, gotera, techo.' => {
        en: 'Actively collected water. E.g.: gutter, leak, roof.',
        pt: 'Água coletada ativamente. Ex.: calha, goteira, telhado.'
      },
      'Agua pasivamente recogida. Ejemplo: la lluvia lo llenó.' => {
        en: 'Passively collected water. E.g.: rain filled it.',
        pt: 'Água coletada passivamente. Ex.: a chuva encheu.'
      },
      'Otro (tratamiento manual)' => {
        en: 'Other (manual treatment)',
        pt: 'Outro (tratamento manual)'
      }
    }

    translations.each do |name_es, t|
      WaterSourceType.where(name: name_es).update_all(
        name_en: t[:en],
        name_pt: t[:pt]
      )
    end
  end

  def down
    remove_column :water_sources, :name_en
    remove_column :water_sources, :name_pt
  end
end
