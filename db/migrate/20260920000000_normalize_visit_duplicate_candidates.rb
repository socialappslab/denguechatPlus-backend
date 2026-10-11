# frozen_string_literal: true

class NormalizeVisitDuplicateCandidates < ActiveRecord::Migration[7.1]
  CHECK_NAME = 'chk_visit_duplicate_candidates_canonical_pair'

  def up
    execute 'LOCK TABLE visit_duplicate_candidates IN SHARE ROW EXCLUSIVE MODE'

    execute <<~SQL.squish
      DELETE FROM visit_duplicate_candidates AS duplicate_candidates
      WHERE duplicate_candidates.visit_id = duplicate_candidates.duplicate_visit_id
    SQL

    execute <<~SQL.squish
      DELETE FROM visit_duplicate_candidates AS duplicate_candidates
      USING visit_duplicate_candidates AS retained_candidates
      WHERE duplicate_candidates.id > retained_candidates.id
        AND LEAST(duplicate_candidates.visit_id, duplicate_candidates.duplicate_visit_id) =
            LEAST(retained_candidates.visit_id, retained_candidates.duplicate_visit_id)
        AND GREATEST(duplicate_candidates.visit_id, duplicate_candidates.duplicate_visit_id) =
            GREATEST(retained_candidates.visit_id, retained_candidates.duplicate_visit_id)
    SQL

    execute <<~SQL.squish
      UPDATE visit_duplicate_candidates
      SET visit_id = LEAST(visit_id, duplicate_visit_id),
          duplicate_visit_id = GREATEST(visit_id, duplicate_visit_id)
    SQL

    add_check_constraint :visit_duplicate_candidates, 'visit_id < duplicate_visit_id', name: CHECK_NAME
  end

  def down
    remove_check_constraint :visit_duplicate_candidates, name: CHECK_NAME
  end
end
