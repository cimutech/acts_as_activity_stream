require 'spec_helper'

describe Activity do
  before do
    @user_1 = FactoryGirl.create(:user)
    @user_2 = FactoryGirl.create(:user)
    @user_1.follow(@user_2)
    @user_2.follow(@user_1)
    @post_1 = @user_1.post("hello1")
    @post_2 = @user_2.post("hello2")
    @user_1.comment(@post_2.activity, "world")
    @user_1.like(@post_2.activity)
  end

  context "build json with jbuilder" do
    before {@json = @post_2.activity.to_builder.attributes!}
    subject {@json}

    it{ should_not be_nil }
    specify{ @json["id"] == @post_2.activity.id }
    specify{ @json["type"] == "post" }
    specify{ @json["data"]["id"] == @post_2.id }
  end

  context "counter" do
    it "likes counter" do
      @post_2.activity.likes_count.should == 1
    end
    it "comments counter" do
      @post_2.activity.comments_count.should == 1
    end
  end

  context "activable data" do
    it "should be valid with right verb" do
      @post_2.activity.data.should_not be_nil
    end
    it "should raise error with nil verb" do
      @post_2.activity.update_column(:verb, nil)
      lambda{ @post_2.activity.data }.should raise_error
    end
  end
end