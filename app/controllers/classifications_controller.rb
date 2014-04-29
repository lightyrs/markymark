class ClassificationsController < ApplicationController

  before_action :set_classification, only: [:show]

  def index
    @classifications = Classification.all
  end

  def new
    @classification = Classification.new
  end

  def create
    @classification = Classification.new(classification_params)

    if @classification.save
      redirect_to classifications_path
    else
      render :new
    end
  end

  def show
  end

  def update
  end

  private

  def set_classification
    @classification = Classification.find(params[:id])
  end

  def classification_params
    params.require(:classification).permit(:name, :description, :content_type)
  end
end
