# frozen_string_literal: true

RSpec.describe "Models" do
  let(:base_query) { User.all }

  it "#auto_includes" do
    expect(base_query).to receive(:includes).with(:articles, :comments).and_call_original
    base_query.auto_includes("articles,comments").to_a
  end

  it "#auto_preload" do
    expect(base_query).to receive(:preload).with(:articles, :comments).and_call_original
    base_query.auto_preload("articles,comments").to_a
  end

  it "#auto_eager_load" do
    expect(base_query).to receive(:eager_load).with(:articles, :comments).and_call_original
    base_query.auto_eager_load("articles,comments").to_a
  end

  it "#auto_eager_load" do
    expect(base_query).not_to receive(:eager_load)
    base_query.auto_preload("").to_a
  end
end
