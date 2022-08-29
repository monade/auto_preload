# frozen_string_literal: true

RSpec.describe AutoPreload::Resolver do
  it "skips invalid associations" do
    expect(subject.resolve(User, "posts")).to eq []
  end

  it "resolves a basic association" do
    expect(subject.resolve(User, "articles")).to eq [:articles]
  end

  it "resolves a list of associations" do
    expect(subject.resolve(User, "articles,comments")).to eq %i[articles comments]
  end

  it "resolves the * association" do
    expect(subject.resolve(User, "*")).to eq %i[articles comments]
  end

  it "resolves nested relations" do
    expect(
      subject.resolve(User, "articles.user,articles.comments")
    ).to eq [{ articles: %i[user comments] }]
  end

  it "resolves nested relations" do
    expect(
      subject.resolve(User, "articles.*, comments")
    ).to eq [:comments, { articles: %i[user comments] }]
  end

  it "resolves nested relations looping" do
    expect(subject.resolve(User, "articles.user.articles.user.articles")).to eq(
      [{ articles: [{ user: [{ articles: [{ user: [:articles] }] }] }] }]
    )
  end

  it "fails to resolve looping ** association" do
    expect { subject.resolve(User, "**") }.to raise_error("Too many iterations reached")
  end

  it "resolves the ** association" do
    Article.auto_preloadable = [:comments]
    Comment.auto_preloadable = []
    expect(subject.resolve(User, "**")).to eq([:comments, { articles: %i[comments] }])
  end
end
