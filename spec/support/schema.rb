# frozen_string_literal: true

require "active_record"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

class User < ActiveRecord::Base
  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy
end

class Article < ActiveRecord::Base
  belongs_to :user
  has_many :comments, dependent: :destroy
end

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :article
  has_many :mentions, dependent: :destroy
  has_many :mentioned, class_name: "User", through: :mentions, dependent: :destroy
end

class Mention < ActiveRecord::Base
  belongs_to :comment
  belongs_to :user
end

class ArticleCategory < ActiveRecord::Base
  belongs_to :article
  belongs_to :category
end

class Category < ActiveRecord::Base
end

module Schema
  def self.create
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Schema.define do
      create_table :users, force: true do |t|
        t.string :email, null: false
        t.timestamps null: false
        t.index [:email], unique: true
      end

      create_table :articles, force: true do |t|
        t.belongs_to :user, foreign_key: true, null: false
        t.string :title, null: true
        t.text :body
        t.integer :status
        t.timestamps null: false
      end

      create_table :categories, force: true do |t|
        t.string :title, null: true
        t.timestamps null: false
      end

      create_table :article_categories, force: true do |t|
        t.belongs_to :article, foreign_key: true, null: false
        t.belongs_to :category, foreign_key: true, null: false
        t.timestamps null: false
        t.index %i[user_id category_id], unique: true
      end

      create_table :comments, force: true do |t|
        t.belongs_to :user, foreign_key: true, null: false
        t.belongs_to :article, foreign_key: true, null: false
        t.text :body
        t.timestamps null: false
      end

      create_table :mentions, force: true do |t|
        t.belongs_to :user, foreign_key: true, null: false
        t.belongs_to :comment, foreign_key: true, null: false
        t.timestamps null: false
        t.index %i[user_id comment_id], unique: true
      end
    end
  end
end
