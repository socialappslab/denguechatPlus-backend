class ModifyOptionTextFromOptions < ActiveRecord::Migration[7.1]
  def change
    option= Option.find_by(name_es: 'Agua del grifo o potable')
    if option
      option.name_es = 'Del grifo o de otro recipiente'
      option.name_en = 'From the faucet or from another container'
      option.save!
    end
  end
end
