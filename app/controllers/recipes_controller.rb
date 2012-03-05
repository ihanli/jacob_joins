class RecipesController < ApplicationController
  include Geocoder::Model::Mongoid

  def index
    @recipes = Recipe.all
  end

	def new
		@recipe = Recipe.new
    
    #Get location by IP-address
    @location = request.location
	end

	def create
    @recipe = Recipe.new(params[:recipe])
    if @recipe.save 
      cookies[:jacob_joins_recipe] = { :value => @recipe.id, :expires => 20.years.from_now.utc }
      if cookies[:jacob_joins_user].present?
        @user = User.find(cookies[:jacob_joins_user])
        @recipe.user_id = @user.id
        @recipe.save!
      end
      redirect_to user_upload_index_path
    else
      session[:error] = @recipe
      redirect_to recipe_upload_index_path
    end
	end

  def show
    @recipe = Recipe.find_by_slug params[:id]
  end
end
