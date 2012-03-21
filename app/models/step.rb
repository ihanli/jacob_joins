class Step
  include Mongoid::Document
  include Mongoid::Paperclip

  field :description, :type => String

  embedded_in :recipe
  
  has_mongoid_attached_file :image,
    :url => "/system/steps_images/:id/:style/:filename",
    :path => ":rails_root/public/system/steps_images/:id/:style/:filename",
    :styles => {
      :original => ['1920x1680>', :jpg],
      :small    => ['100x100#',   :jpg],
      :medium   => ['250x250',    :jpg],
      :large    => ['500x500>',   :jpg]
    }

  validates_presence_of :description

  def to_jq_upload
    if self.image.present?
      {
        "name" => File.basename(self.image_file_name, '.*'),
        "size" => self.image_file_size,
        "thumbnail_url" => self.image.url(:small),
        "step_id" => self.id,
        "delete_url" => Rails.application.routes.url_helpers.recipes_delete_step_image_path(self.id)
      }
    end
  end

end