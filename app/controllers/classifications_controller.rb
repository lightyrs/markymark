class ClassificationsController < ApplicationController

  before_action :set_classification, only: [:show]

  def index
    @sample = Link.order_by_rand.first
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

  def classify
    @structural_classification = StructuralClassification.find(classification_params[:structural_classification_id])
    @link = Link.find(classification_params[:link_id])
    Trainer.classify(category: @structural_classification.name, sample: @link.sample)
    redirect_to classifications_path
  end

  private

  def set_classification
    @classification = Classification.find(params[:id])
  end

  def classification_params
    params.require(:classification).permit(:id, :structural_classification_id, :name, :description, :content_type, :link_id, :tags)
  end
end
