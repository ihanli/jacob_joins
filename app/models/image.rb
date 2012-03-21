class Image
  include Mongoid::Document
  include Mongoid::Paperclip

  embedded_in :recipe, :inverse_of => :images

  has_mongoid_attached_file :attachment,
    :url => "/system/recipes_images/:id/:style/:filename",
    :path => ":rails_root/public/system/recipes_images/:id/:style/:filename",
    :styles => {
      :original => ['1920x1680>', :jpg],
      :small    => ['100x100#',   :jpg],
      :medium   => ['250x250',    :jpg],
      :large    => ['500x500>',   :jpg]
    }

  def to_jq_upload
    if self.attachment.present?
      {
        "name" => File.basename(self.attachment_file_name, '.*'),
        "size" => self.attachment_file_size,
        "thumbnail_url" => self.attachment.url(:small),
        "image_id" => self.id,
        "delete_url" => Rails.application.routes.url_helpers.recipes_delete_image_path(self.id)
      }
    end
  end
end