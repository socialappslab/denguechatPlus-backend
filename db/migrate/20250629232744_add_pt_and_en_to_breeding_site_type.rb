class AddPtAndEnToBreedingSiteType < ActiveRecord::Migration[7.1]
  def up
    add_column :breeding_site_types, :name_en, :string, null: true
    add_column :breeding_site_types, :name_pt, :string, null: true

    translations = {
      'Pozos' => { en: 'Wells', pt: 'Poços' },
      'Otros' => { en: 'Others', pt: 'Outros' },
      'Sumidero' => { en: 'Drain', pt: 'Ralo' },
      'Llantas' => { en: 'Tires', pt: 'Pneus' },
      'Tanques' => { en: 'Tanks', pt: 'Tanques' },
      'Estructura de la casa' => { en: 'House structure', pt: 'Estrutura da casa' },
      'Bidones o cilindros (metal, plástico)' => { en: 'Barrels or cylinders (metal, plastic)',
                                                   pt: 'Tambores ou cilindros (metal, plástico)' },
      'Plantas, frutas o verduras' => { en: 'Plants, fruits or vegetables', pt: 'Plantas, frutas ou verduras' },
      'Maceteros o floreros' => { en: 'Flowerpots or vases', pt: 'Vasos ou floreiras' },
      'Criaderos, bebederos o acuarios' => { en: 'Breeding sites, drinkers or aquariums',
                                             pt: 'Criadouros, bebedouros ou aquários' }
    }

    translations.each do |name_es, t|
      BreedingSiteType.where(name: name_es).update_all(
        name_en: t[:en],
        name_pt: t[:pt]
      )
    end
  end

  def down
    remove_column :breeding_site_types, :name_en
    remove_column :breeding_site_types, :name_pt
  end
end
