# frozen_string_literal: true

RSpec.describe AutoPreload::Resolver do
  context "with the Serializer adapter" do
    before(:each) do
      AutoPreload.config.adapter = AutoPreload::Adapters::Serializer.new
    end

    after(:each) do
      AutoPreload.config.adapter = AutoPreload::Adapters::ActiveRecord.new
    end

    it "resolves a basic association" do
      expect(subject.resolve(Comment, "user")).to eq [:user]
    end

    it "skips not defined associations in the serializer" do
      expect(subject.resolve(Comment, "user,article")).to eq [:user]
    end

    it "skips not defined associations in the serializer when it's nested" do
      expect(subject.resolve(Comment, "user.something.something.something,article")).to eq([{ user: [] }])
    end

    it "prevents loops" do
      expect(subject.resolve(Comment, "**")).to eq [:user]
    end

    context "with custom serializer" do
      it "resolves a simple association" do
        subject = AutoPreload::Resolver.new(serializer: CustomCommentSerializer)
        expect(subject.resolve(Comment, "user,article")).to eq %i[user article]
      end

      it "runs recursion with it" do
        subject = AutoPreload::Resolver.new(serializer: CustomCommentSerializer)
        expect(subject.resolve(Comment, "**")).to eq [:user, { article: [:user] }]
      end
    end
  end
end
