class LinksController < ApplicationController

  before_action :set_link, only: [:show]

  def index
    if params[:tag]
      links = current_user.links.tagged_with(params[:tag])
    elsif params[:site]
      links = current_user.links.where(domain: params[:site])
    else
      links = current_user.links
    end
    @links = links.page(params[:page]).order('posted_at DESC')
  end

  def new
    @link = current_user.links.build
  end

  def create
    @link = current_user.links.build(link_params.merge(posted_at: Time.now))

    if @link.save
      redirect_to links_path
    else
      render :new
    end
  end

  def show
  end

  def tags
    @tags = ActsAsTaggableOn::Tag.where('lower(name) like ?', "%#{params[:q].downcase}%").limit(100)
  end

  private

  def set_link
    @link = Link.find(params[:id])
  end

  def link_params
    params.require(:link).permit(:title, :description, :url, :image_url, :content, :domain, :posted_at)
  end
end
