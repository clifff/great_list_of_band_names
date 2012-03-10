class InitialModels < ActiveRecord::Migration
  def self.up
    create_table "ideas", :force => true do |t|
      t.column "body", :text
      t.column "user_name", :string
    end

    create_table "votes", :force => true do |t|
      t.column "uuid", :integer
      t.column "idea_id", :integer
    end
  end

  def self.down
    drop_table "votes"
    drop_table "ideas"
  end
end
