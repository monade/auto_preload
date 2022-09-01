# frozen_string_literal: true

class CommentSerializer < ActiveModel::Serializer
  belongs_to :user
end

class UserSerializer < ActiveModel::Serializer
end

class ArticleSerializer < ActiveModel::Serializer
end

class CustomCommentSerializer < ActiveModel::Serializer
  belongs_to :user
  belongs_to :article
end
