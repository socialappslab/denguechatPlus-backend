class AddWeightedPointToOptions < ActiveRecord::Migration[7.1]
  def up
    unless column_exists?(:options, :weighted_points)
      add_column :options, :weighted_points, :integer
    end

    Option.reset_column_information
    option_points = {
      'Si, tiene tapa y está bien cerrado' => 9,
      'Si, tiene tapa pero no está bien cerrado' => 2,
      'Sí, está bajo techo' => 2,
      'Otro tipo de protección' => 2,
      'No tiene protección' => 2,
      'Larvas' => 10,
      'Pupas' => 10,
      'Huevos' => 10,
      'Nada' => 1,
      'Sí, contiene agua' => 5,
      'No, no contiene agua' => 100
    }

    option_points.each do |name, points|
      option = Option.find_by(name_es: name)

      option&.update!(weighted_points: points)
    end

  end

  def down
    remove_column :options, :weighted_points if column_exists?(:options, :weighted_points)
  end
end
