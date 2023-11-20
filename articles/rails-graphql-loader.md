---
title: "Railsのgraphql-batchでN+1を回避する"
emoji: "🏋"
type: "tech"
topics: ["ruby", "rails", "graphql"]
published: false
publication_name: "ispec_inc"
---

# モチベーション

graphql-rubyでN+1を回避したい


# 実装

## model
```mermaid
erDiagram
    User ||--o{ Post
    User {
        string id
        string name
    }
    Post ||--|{ Comment
    Post {
        int user_id
        string body
    }
    Comment {
        int post_id
        float pricePerUnit
    }
```
```code:ruby
class User < ApplicationRecord
  has_many :posts
end

class Post < ApplicationRecord
  has_many :comments
  belongs_to :user
end

class Comment < ApplicationRecord
  has_many :comments
  belongs_to :post
end
```
