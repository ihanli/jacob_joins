class IngredientsController < ApplicationController
  #respond_to :html, :json

  def names
    render :json => Ingredient.names_with(params[:term]).to_json
  end

  def search
    respond_to do |format|
      format.json {
        #raise params.inspect
        @recipe_match = []
        params[:ingredients].each do |key, value|
          query = Recipe.search_by_ingredient(value)
          if @recipe_match.include?(query.entries)
            index = @recipe_match.index(query.entries)
            @recipe_match[index]
            binding.pry
          else
            @recipe_match << query.entries
          end
        end



        binding.pry

        # @ingredients = []
        # params[:ingredients].each do |key, value|
        #   query = Ingredient.search_by_name(value)
        #   @ingredients << query.entries
        # end
        # @ingredients = @ingredients.flatten

        #binding.pry

        #Compare recipe_ids with each other
        # raise "bla"
        # if @ingredients.length > 1
        #   @recipe_match = []
        #   counter = 0
        #   #Loop through every ingredient and get the recipe_ids
        #   @ingredients.each do |ingredient|
        #     ingredient.recipe_ids.each do |id|
              
        #       #Loop through all other recipes and compare
        #       compare_counter = counter+1
        #       @ingredients[compare_counter].recipe_ids.each do |compare_id|
        #         if id == compare_id
        #           @recipe_match << id
        #           raise @recipe_match.inspect
        #         end
        #       end
        #     end
        #     counter+=1
        #   end
        # end

        # @recipes = []
        # @ingredients.each do |ingredient|
        #   @recipes << Recipe.find(ingredient.recipe_ids[0])
        # end
        # render :json => {:ingredients => @ingredients, :recipes => @recipes}
        render :json =>{}
      }
      format.html
    end
  end
end
