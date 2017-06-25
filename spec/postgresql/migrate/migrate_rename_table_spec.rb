describe 'Ridgepole::Client#diff -> migrate' do
  context 'when rename table' do
    let(:actual_dsl) {
      erbh(<<-EOS)
        create_table "clubs", force: :cascade do |t|
          t.string "name", limit: 255, default: "", null: false
        end

        <%= add_index "clubs", ["name"], name: "idx_name", unique: true, <%= i cond(5.0, using: :btree) %>

        create_table "departments", primary_key: "dept_no", force: :cascade do |t|
          t.string "dept_name", limit: 40, null: false
        end

        <%= add_index "departments", ["dept_name"], name: "idx_dept_name", unique: true, <%= i cond(5.0, using: :btree) %>

        create_table "dept_emp", id: false, force: :cascade do |t|
          t.integer "emp_no", null: false
          t.string  "dept_no", limit: 4, null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
        end

        <%= add_index "dept_emp", ["dept_no"], name: "idx_dept_emp_dept_no", <%= i cond(5.0, using: :btree) %>
        <%= add_index "dept_emp", ["emp_no"], name: "idx_dept_emp_emp_no", <%= i cond(5.0, using: :btree) %>

        create_table "dept_manager", id: false, force: :cascade do |t|
          t.string  "dept_no", limit: 4, null: false
          t.integer "emp_no", null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
        end

        <%= add_index "dept_manager", ["dept_no"], name: "idx_dept_manager_dept_no", <%= i cond(5.0, using: :btree) %>
        <%= add_index "dept_manager", ["emp_no"], name: "idx_dept_manager_emp_no", <%= i cond(5.0, using: :btree) %>

        create_table "employee_clubs", force: :cascade do |t|
          t.integer "emp_no", null: false
          t.integer "club_id", null: false
        end

        <%= add_index "employee_clubs", ["emp_no", "club_id"], name: "idx_employee_clubs_emp_no_club_id", <%= i cond(5.0, using: :btree) %>

        create_table "employees", primary_key: "emp_no", force: :cascade do |t|
          t.date   "birth_date", null: false
          t.string "first_name", limit: 14, null: false
          t.string "last_name", limit: 16, null: false
          t.date   "hire_date", null: false
        end

        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no", null: false
          t.integer "salary", null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
        end

        <%= add_index "salaries", ["emp_no"], name: "idx_salaries_emp_no", <%= i cond(5.0, using: :btree) %>

        create_table "titles", id: false, force: :cascade do |t|
          t.integer "emp_no", null: false
          t.string  "title", limit: 50, null: false
          t.date    "from_date", null: false
          t.date    "to_date"
        end

        <%= add_index "titles", ["emp_no"], name: "idx_titles_emp_no", <%= i cond(5.0, using: :btree) %>
      EOS
    }

    let(:expected_dsl) {
      erbh(<<-EOS)
        create_table "clubs", force: :cascade do |t|
          t.string "name", limit: 255, default: "", null: false
        end

        <%= add_index "clubs", ["name"], name: "idx_name", unique: true, <%= i cond(5.0, using: :btree) %>

        create_table "departments", primary_key: "dept_no", force: :cascade do |t|
          t.string "dept_name", limit: 40, null: false
        end

        <%= add_index "departments", ["dept_name"], name: "idx_dept_name", unique: true, <%= i cond(5.0, using: :btree) %>

        create_table "dept_emp", id: false, force: :cascade do |t|
          t.integer "emp_no", null: false
          t.string  "dept_no", limit: 4, null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
        end

        <%= add_index "dept_emp", ["dept_no"], name: "idx_dept_emp_dept_no", <%= i cond(5.0, using: :btree) %>
        <%= add_index "dept_emp", ["emp_no"], name: "idx_dept_emp_emp_no", <%= i cond(5.0, using: :btree) %>

        create_table "dept_manager", id: false, force: :cascade do |t|
          t.string  "dept_no", limit: 4, null: false
          t.integer "emp_no", null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
        end

        <%= add_index "dept_manager", ["dept_no"], name: "idx_dept_manager_dept_no", <%= i cond(5.0, using: :btree) %>
        <%= add_index "dept_manager", ["emp_no"], name: "idx_dept_manager_emp_no", <%= i cond(5.0, using: :btree) %>

        create_table "employee_clubs", force: :cascade do |t|
          t.integer "emp_no", null: false
          t.integer "club_id", null: false
        end

        <%= add_index "employee_clubs", ["emp_no", "club_id"], name: "idx_employee_clubs_emp_no_club_id", <%= i cond(5.0, using: :btree) %>

        create_table "employees2", primary_key: "emp_no", force: :cascade, renamed_from: 'employees' do |t|
          t.date   "birth_date", null: false
          t.string "first_name", limit: 14, null: false
          t.string "last_name", limit: 16, null: false
          t.date   "hire_date", null: false
        end

        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no", null: false
          t.integer "salary", null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
        end

        <%= add_index "salaries", ["emp_no"], name: "idx_salaries_emp_no", <%= i cond(5.0, using: :btree) %>

        create_table "titles", id: false, force: :cascade do |t|
          t.integer "emp_no", null: false
          t.string  "title", limit: 50, null: false
          t.date    "from_date", null: false
          t.date    "to_date"
        end

        <%= add_index "titles", ["emp_no"], name: "idx_titles_emp_no", <%= i cond(5.0, using: :btree) %>
      EOS
    }

    before { subject.diff(actual_dsl).migrate }
    subject { client }

    it {
      delta = subject.diff(expected_dsl)
      expect(delta.differ?).to be_truthy
      expect(subject.dump).to match_fuzzy actual_dsl
      delta.migrate
      expect(subject.dump).to match_fuzzy expected_dsl.gsub(/, renamed_from: 'employees'/, '')
    }

    it {
      delta = Ridgepole::Client.diff(actual_dsl, expected_dsl, reverse: true)
      expect(delta.differ?).to be_truthy
      expect(delta.script).to match_fuzzy <<-EOS
        rename_table("employees2", "employees")
      EOS
    }
  end

  context 'when rename table (dry-run)' do
    let(:actual_dsl) {
      erbh(<<-EOS)
        create_table "employees", primary_key: "emp_no", force: :cascade do |t|
          t.date   "birth_date", null: false
          t.string "first_name", limit: 14, null: false
          t.string "last_name", limit: 16, null: false
          t.date   "hire_date", null: false
        end

        <%= add_index "employees", ["first_name"], name: "first_name", <%= i cond(5.0, using: :btree) %>
      EOS
    }

    let(:expected_dsl) {
      erbh(<<-EOS)
        create_table "employees2", primary_key: "emp_no", force: :cascade, renamed_from: 'employees' do |t|
          t.date   "birth_date", null: false
          t.string "first_name", limit: 14, null: false
          t.string "last_name", limit: 16, null: false
          t.date   "hire_date", null: false
        end

        <%= add_index "employees2", ["first_name"], name: "first_name", <%= i cond(5.0, using: :btree) %>
      EOS
    }

    before { subject.diff(actual_dsl).migrate }
    subject { client }

    it {
      delta = subject.diff(expected_dsl)
      expect(delta.differ?).to be_truthy
      expect(subject.dump).to match_fuzzy actual_dsl
      delta.migrate(noop: true)
      expect(subject.dump).to match_fuzzy actual_dsl
    }
  end
end
