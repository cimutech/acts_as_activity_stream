require 'spec_helper'

describe Post do
  before do
    @post = FactoryGirl.create(:post)
  end

  it "should send an post activity" do
    @post.should have(1).activities
  end

  it "should renturn first activity by default" do
    @post.activity.should == @post.activities.first
  end

  it "activity verb should be post" do
    @post.activity.verb.should == 'post'
  end

  it "activity should have data" do
    @post.activity.data.should == @post.to_builder
  end

  it "activity should belong to a user" do
    @post.activity.author.user.should_not be_nil
  end

end

