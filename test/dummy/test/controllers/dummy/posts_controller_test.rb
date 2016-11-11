require 'test_helper'

class Dummy::PostsControllerTest < ActionController::TestCase
  setup do
    @dummy_post = dummy_posts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dummy_posts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dummy_post" do
    assert_difference('Dummy::Post.count') do
      post :create, dummy_post: { article: @dummy_post.article, owner_id: @dummy_post.owner_id, summary: @dummy_post.summary, title: @dummy_post.title }
    end

    assert_redirected_to dummy_post_path(assigns(:dummy_post))
  end

  test "should show dummy_post" do
    get :show, id: @dummy_post
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dummy_post
    assert_response :success
  end

  test "should update dummy_post" do
    patch :update, id: @dummy_post, dummy_post: { article: @dummy_post.article, owner_id: @dummy_post.owner_id, summary: @dummy_post.summary, title: @dummy_post.title }
    assert_redirected_to dummy_post_path(assigns(:dummy_post))
  end

  test "should destroy dummy_post" do
    assert_difference('Dummy::Post.count', -1) do
      delete :destroy, id: @dummy_post
    end

    assert_redirected_to dummy_posts_path
  end
end
