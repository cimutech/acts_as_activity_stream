require 'spec_helper'

describe User do
  before do
    @user_1 = FactoryGirl.create(:user)
    @user_2 = FactoryGirl.create(:user)
    @user_3 = FactoryGirl.create(:user)
  end

  describe "actor belongs to actorable" do
    it "should have user method" do
      @user_1.actor.user.should == @user_1
    end
  end

  describe "friendship" do
    context 'self contact' do
      it "should be invalid" do
        @user_1.follow(@user_1).should have(1).errors
      end
    end

    context 'follow a stranger' do
      before { @user_1.follow(@user_2) }

      it "should have followings" do
        @user_1.should have(0).friends
        @user_1.should have(1).followings
        @user_1.followings.first.id.should == @user_2.id
      end

      it "should have followers" do
        @user_2.should have(0).friends
        @user_2.should have(1).followers
        @user_2.followers.first.id.should == @user_1.id
      end

      it "should have pedding_friends" do
        @user_2.should have(1).pending_friends
        @user_2.pending_friends.first.id.should == @user_1.id
      end

      it "should have requested_friends" do
        @user_1.should have(1).requested_friends
        @user_1.requested_friends.first.id.should == @user_2.id
      end

      describe 'reply a follower' do
        before { @user_2.follow(@user_1) }

        it "should be friend to each other" do
          @user_1.should have(1).friends
          @user_1.friends.first.id.should == @user_2.id
          @user_1.should have(1).friends
          @user_2.friends.first.id.should == @user_1.id
        end

        describe 'unfriend' do
          it 'sns like facebook will bolck all contacts' do
            @user_1.unfriend(@user_2)
            @user_1.should have(0).followings
            @user_2.should have(0).followers
            @user_2.should have(0).followings
            @user_1.should have(0).followers
          end

          it 'sns like twitter only block one contact' do
            ActsAsActivityStream.sns_type = :follow
            @user_1.unfriend(@user_2)
            @user_1.should have(0).followings
            @user_2.should have(0).followers
            @user_2.should have(1).followings
            @user_1.should have(1).followers
          end
        end
      end

      describe 'unfollow' do
        before { @user_1.unfollow(@user_2) }

        it "should not follow anymore" do
          @user_1.should have(0).followings
          @user_2.should have(0).followers
        end
      end

    end

    context 'suggestions list' do
      it "should return suggestion list" do
        @user_1.suggestions("User", 5).size.should == 2
      end

      it "should avoid the followings" do
        @user_1.follow(@user_2)
        @user_1.suggestions("User", 5).size.should == 1
        @user_1.suggestions("User", 5, []).size.should == 1
        @user_1.suggestions("User", 5, [@user_3.id]).size.should == 0
      end
    end
  end

  describe "activities on wall" do
    before do
      # user_1 and user_2 are friends
      @user_1.follow(@user_2)
      @user_2.follow(@user_1)
      # user_1 follow user_3, but without feedback
      @user_1.follow(@user_3)

      # posts
      @user_1.post("hello1")
      @user_1.post("hello2")

      @user_2.post("hello1")
      @user_2.post("hello2")

      @user_3.post("hello1")
      @user_3.post("hello2")
    end

    context 'sns like facebook' do
      it "wall home" do
        @user_1.wall(:home).size.should == 4
        @user_2.wall(:home).size.should == 4
        @user_3.wall(:home).size.should == 2
      end
      it "wall profile" do
        @user_1.wall(:profile).size.should == 2
        @user_2.wall(:profile).size.should == 2
        @user_3.wall(:profile).size.should == 2
      end
      it "wall custom" do
        actor_ids = [@user_2.actor.id, @user_3.actor.id]
        @user_1.wall(:custom, actor_ids: actor_ids).size.should == 2
      end
    end

    context 'sns like twitter' do
      before { ActsAsActivityStream.sns_type = :follow }
      it "wall home" do
        @user_1.wall(:home).size.should == 6
        @user_2.wall(:home).size.should == 4
        @user_3.wall(:home).size.should == 2
      end
      it "wall profile" do
        @user_1.wall(:profile).size.should == 2
        @user_2.wall(:profile).size.should == 2
        @user_3.wall(:profile).size.should == 2
      end
      it "wall custom" do
        actor_ids = [@user_2.actor.id, @user_3.actor.id]
        @user_1.wall(:custom, actor_ids: actor_ids).size.should == 4
      end
    end
  end
end

