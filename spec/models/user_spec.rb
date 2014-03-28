require 'spec_helper'

describe User do
  before do
    @user_1 = FactoryGirl.create(:user)
    @user_2 = FactoryGirl.create(:user)
  end

  # describe "friend suggestions" do
  #   it "should get friend candidates" do
  #     @user_1.suggestions
  #   end
  # end

  describe "friendship" do
    before { @user_1.follow(@user_2) }

    context 'follow a stranger' do

      it "should have followings" do
        @user_1.followings.size.should > 0
        @user_1.followings.first.id.should == @user_2.id
      end

      it "should have followers" do
        @user_2.followers.size.should > 0
        @user_2.followers.first.id.should == @user_1.id
      end

      it "should have pedding_friends" do
        @user_2.pending_friends.size.should > 0
        @user_2.pending_friends.first.id.should == @user_1.id
      end
    end

    context 'reply a follower' do
      before { @user_2.follow(@user_1) }

      it "should be friend to each other" do
        @user_1.friends.size.should > 0
        @user_1.friends.first.id.should == @user_2.id
        @user_2.friends.size.should > 0
        @user_2.friends.first.id.should == @user_1.id
      end
    end

  end
end

