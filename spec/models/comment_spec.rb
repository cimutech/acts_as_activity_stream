require 'spec_helper'

describe Comment do
  before do
    @user_1 = FactoryGirl.create(:user)
    @user_2 = FactoryGirl.create(:user)
    @user_3 = FactoryGirl.create(:user)
    @user_1.follow(@user_2)
    @user_2.follow(@user_1)
    @user_1.follow(@user_3)
    @post_1 = @user_1.post("hello1")
    @post_2 = @user_2.post("hello2")
    @post_3 = @user_3.post("hello3")
  end

  context 'sns like facebook' do
    it "can post a comment to a friend\'s activity" do
      @user_1.comment(@post_2.activity, "world1").should_not be_nil
      @user_1.should have(1).comments
      @post_2.activity.should have(1).comments
    end

    it "can post a comment to self activity" do
      @user_1.comment(@post_1.activity, "world1").should_not be_nil
      @user_1.should have(1).comments
      @post_1.activity.should have(1).comments
    end

    it "cannot post a comment to an activity if owner is not a friend" do
      @user_1.comment(@post_3.activity, "world1").should be_nil
      @user_1.should have(0).comments
      @post_3.activity.should have(0).comments
    end
  end

  context 'sns like twitter' do
    before { ActsAsActivityStream.sns_type = :follow }

    it "can post a comment to a friend\'s activity" do
      @user_1.comment(@post_2.activity, "world1").should_not be_nil
      @user_1.should have(1).comments
      @post_2.activity.should have(1).comments
    end

    it "can post a comment to self activity" do
      @user_1.comment(@post_1.activity, "world1").should_not be_nil
      @user_1.should have(1).comments
      @post_1.activity.should have(1).comments
    end

    it "cannot post a comment to an activity if owner is not a friend" do
      @user_2.comment(@post_3.activity, "world1").should_not be_nil
      @user_2.should have(1).comments
      @post_3.activity.should have(1).comments
    end
  end

end