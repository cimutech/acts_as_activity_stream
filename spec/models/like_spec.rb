require 'spec_helper'

describe Like do
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
    it "can like a friend\'s activity" do
      @user_1.like(@post_2.activity).should_not be_nil
      @user_1.should have(1).likes
      @post_2.activity.should have(1).likes
    end

    it "can like self activity" do
      @user_1.like(@post_1.activity).should_not be_nil
      @user_1.should have(1).likes
      @post_1.activity.should have(1).likes
    end

    it "cannot like an activity if owner is not a friend" do
      @user_1.like(@post_3.activity).should be_nil
      @user_1.should have(0).likes
      @post_3.activity.should have(0).likes
    end

    it "can auto increase the counter" do
      @user_1.like(@post_2.activity).should_not be_nil
      @post_2.activity.likes_count.should == 1
    end
  end

  context 'sns like twitter' do
    before { ActsAsActivityStream.sns_type = :follow }

    it "can like a friend\'s activity" do
      @user_1.like(@post_2.activity).should_not be_nil
      @user_1.should have(1).likes
      @post_2.activity.should have(1).likes
    end

    it "can like self activity" do
      @user_1.like(@post_1.activity).should_not be_nil
      @user_1.should have(1).likes
      @post_1.activity.should have(1).likes
    end

    it "cannot like an activity if owner is not a friend" do
      @user_2.like(@post_3.activity).should_not be_nil
      @user_2.should have(1).likes
      @post_3.activity.should have(1).likes
    end

    it "can auto increase the counter" do
      @user_1.like(@post_2.activity).should_not be_nil
      @post_2.activity.likes_count.should == 1
    end
  end

end