class Dummy::PostsController < ApplicationController
  include Hqfilter::IndexFilterAndSortHelper
  before_action :set_dummy_post, only: [:show, :edit, :update, :destroy]

  # GET /dummy/posts
  def index
    @dummy_posts = do_params_filter_and_sort Dummy::Post.all.joins(:owner)
  end

  # GET /dummy/posts/1
  def show
  end

  # GET /dummy/posts/new
  def new
    @dummy_post = Dummy::Post.new
  end

  # GET /dummy/posts/1/edit
  def edit
  end

  # POST /dummy/posts
  def create
    @dummy_post = Dummy::Post.new(dummy_post_params)

    if @dummy_post.save
      redirect_to @dummy_post, notice: 'Post was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /dummy/posts/1
  def update
    if @dummy_post.update(dummy_post_params)
      redirect_to @dummy_post, notice: 'Post was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /dummy/posts/1
  def destroy
    @dummy_post.destroy
    redirect_to dummy_posts_url, notice: 'Post was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dummy_post
      @dummy_post = Dummy::Post.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def dummy_post_params
      params.require(:dummy_post).permit(:title, :summary, :article, :owner_id)
    end
end
