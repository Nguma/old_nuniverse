require 'image_science'
module Technoweenie # :nodoc:
  module AttachmentFu # :nodoc:
    module Processors
      module ImageScienceProcessor
        def self.included(base)
          base.send :extend, ClassMethods
          base.alias_method_chain :process_attachment, :processing
        end

        module ClassMethods
          # Yields a block containing an Image Science image for the given binary data.
          def with_image(file, &block)
            ::ImageScience.with_image file, &block
          end
        end

        protected
          def process_attachment_with_processing
            return unless process_attachment_without_processing && image?
            with_image do |img|
              self.width  = img.width  if respond_to?(:width)
              self.height = img.height if respond_to?(:height)
              resize_image_or_thumbnail! img
            end
          end

				  def resize_image(img, size)
				    # create a dummy temp file to write to
				    self.temp_path = write_to_temp_file(filename)
				    grab_dimensions = lambda do |img|
				      self.width = img.width if respond_to?(:width)
				      self.height = img.height if respond_to?(:height)
				      img.save temp_path
				      self.size = File.size(self.temp_path)
				      callback_with_args :after_resize, img
				    end
				    size = size.first if size.is_a?(Array) && size.length == 1
				    if size.is_a?(Fixnum) || (size.is_a?(Array) && size.first.is_a?(Fixnum))
				      if size.is_a?(Fixnum)
				        img.thumbnail(size, &grab_dimensions)
				      else
				        img.resize(size[0], size[1], &grab_dimensions)
				      end
				    else
				      n_size = [img.width, img.height] / size.to_s
				      if size.ends_with? "!"
				        aspect = n_size[0].to_f / n_size[1].to_f
				        ih, iw = img.height, img.width
				        w, h = (ih * aspect), (iw / aspect)
				        w = [iw, w].min.to_i
				        h = [ih, h].min.to_i
				        img.with_crop( (iw-w)/2, (ih-h)/2, (iw+w)/2, (ih+h)/2) {
				          |crop| crop.resize(n_size[0], n_size[1], &grab_dimensions )
				        }
				      else
				        img.resize(n_size[0], n_size[1], &grab_dimensions)
				      end
				    end
				  end

      end
    end
  end
end