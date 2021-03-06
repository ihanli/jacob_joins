class IngredientWithQuantity
  include Mongoid::Document
  
  field :quantity
  field :name

  embedded_in :recipe, :inverse_of => :ingredients_with_quantities

  attr_accessible :quantity, :name, :recipe
end
