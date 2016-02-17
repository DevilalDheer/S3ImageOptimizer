class OptimizeImageJob < ActiveJob::Base
  queue_as :optimize_image

  BucketName = ImageOpt::Application.config.aws[:bucket]
  S3Client = Aws::S3::Client.new(:credentials => ImageOpt::Application.config.aws_creds, :region => ImageOpt::Application.config.aws[:region])
  ACL = ImageOpt::Application.config.aws_image[:acl]
  METATAG = ImageOpt::Application.config.aws_image[:metatag]
  CACHECONTROL = ImageOpt::Application.config.aws_image[:cachecontrol]

  def perform(id)
    image = AwsImage.find_by_id(id)
    if image.present?
      # s3_object = S3Client.get_object({:key => image.path, :bucket => BucketName})
      # image.content_type = s3_object.content_type
      # image.save
      if not (image.zoom &&  image.large_m &&  image.large && image.small_m &&  image.small)
        if not image.zoom
          optimize_upload_zoom_for_mobile(image)
        end
        if not image.large
          optimize_upload_large_for_mobile(image)
        end
        if not image.small
          optimize_upload_small_for_mobile(image)
        end
        if not image.large_m
          optimize_upload_large_m_for_mobile(image)
        end 
        if not image.small_m
          optimize_upload_small_m_for_mobile(image)
        end
        if not image.small_mo
          optimize_upload_small_mo_for_mobile(image)
        end
      end
    end
  end

  def optimize_upload_zoom_for_mobile(image)
    s3_object = S3Client.get_object({:key => image.path, :bucket => BucketName})
    file = create_file(s3_object.body, image.path)
    img = Magick::Image::read(file.path).first
    imagepath = image.path.sub "_original.", "_zoom."
    temp_file = Tempfile.new(File.basename imagepath)
    img.resize_to_fit!(800,1100)
    img.write(temp_file.path) do
      self.quality = 70
      self.interlace = Magick::PlaneInterlace
    end
    s3_upload(imagepath, temp_file.path,s3_object.content_type)
  end

  def optimize_upload_large_for_mobile(image)
    imagepath = image.path.sub "_original.", "_zoom."
    s3_object = S3Client.get_object({:key => imagepath, :bucket => BucketName})
    file = create_file(s3_object.body, image.path)
    img = Magick::Image::read(file.path).first
    imagepath = image.path.sub "_original.", "_large."
    temp_file = Tempfile.new(File.basename imagepath)
    img.resize_to_fit!(350,400)
    img.write(temp_file.path) do
      self.quality = 90
      self.interlace = Magick::PlaneInterlace
    end
    s3_upload(imagepath, temp_file.path,s3_object.content_type)
  end

  def optimize_upload_large_m_for_mobile(image)
    imagepath = image.path.sub "_original.", "_large."
    s3_object = S3Client.get_object({:key => imagepath, :bucket => BucketName})
    file = create_file(s3_object.body, image.path)
    img = Magick::Image::read(file.path).first
    imagepath = image.path.sub "_original.", "_large_m."
    temp_file = Tempfile.new(File.basename imagepath)
    img.write(temp_file.path) do
      self.quality = 70
      self.interlace = Magick::PlaneInterlace
    end
    s3_upload(imagepath, temp_file.path,s3_object.content_type)
  end


  def optimize_upload_small_for_mobile(image)
    imagepath = image.path.sub "_original.", "_zoom."
    s3_object = S3Client.get_object({:key => imagepath, :bucket => BucketName})
    file = create_file(s3_object.body, image.path)
    img = Magick::Image::read(file.path).first
    imagepath = image.path.sub "_original.", "_small."
    temp_file = Tempfile.new(File.basename imagepath)
    img.resize_to_fit!(225,257)
    img.write(temp_file.path) do
      self.quality = 70
      self.interlace = Magick::PlaneInterlace
    end
    s3_upload(imagepath, temp_file.path,s3_object.content_type)
  end

  def optimize_upload_small_m_for_mobile(image)
    imagepath = image.path.sub "_original.", "_zoom."
    s3_object = S3Client.get_object({:key => imagepath, :bucket => BucketName})
    file = create_file(s3_object.body, image.path)
    img = Magick::Image::read(file.path).first
    imagepath = image.path.sub "_original.", "_small_m."
    temp_file = Tempfile.new(File.basename imagepath)
    img.resize_to_fit!(225,257)
    img.write(temp_file.path) do
      self.quality = 30
      self.interlace = Magick::PlaneInterlace
    end
    s3_upload(imagepath, temp_file.path,s3_object.content_type)
  end

  def optimize_upload_small_mo_for_mobile(image)
    imagepath = image.path.sub "_original.", "_zoom."
    s3_object = S3Client.get_object({:key => imagepath, :bucket => BucketName})
    file = create_file(s3_object.body, image.path)
    img = Magick::Image::read(file.path).first
    imagepath = image.path.sub "_original.", "_small_mo."
    temp_file = Tempfile.new(File.basename imagepath)
    img.resize_to_fit!(151,173)
    img.write(temp_file.path) do
      self.quality = 50
      self.interlace = Magick::PlaneInterlace
    end
    s3_upload(imagepath, temp_file.path,s3_object.content_type)
  end


  # def perform_v1(id)
  #   image = AwsImage.find_by_id(id)
  #   if image.present?
  #     begin
  #       s3_object = S3Client.get_object({:key => image.path, :bucket => BucketName})
  #       file = create_file(s3_object.body, image.path)
  #       if (content_type = get_content_type(file)).match(/\/(jpg|jpeg)$/)
  #         # if (s3_object.metadata["#{METATAG}"].nil? || s3_object.metadata["#{METATAG}"] != 'Y')
  #           optimize_upload_for_mobile(file, image, content_type)
  #         # else
  #         #   image.optimized = true
  #         #   image.save
  #         # end
  #       else
  #         image.delete
  #       end
  #       file.delete
  #     rescue Aws::S3::Errors::NoSuchKey
  #       image.delete
  #     end
  #   end
  # end

  def s3_upload(bucket_path, file, content_type)
    exp_httpdate = 10.years.from_now.httpdate
    file_options = {:content_type => content_type, :expires => exp_httpdate, :cache_control => CACHECONTROL, :metadata => {"#{METATAG}" => 'Y'}, :acl => ACL}
    new_image_obj = Aws::S3::Object.new(BucketName, bucket_path, :client => S3Client)
    new_image_obj.upload_file(file, file_options)
  end

  def invalidate_cloudfront(item_name)
    cloudfront = Aws::CloudFront::Client.new(:region => ImageOpt::Application.config.aws[:region], :credentials => ImageOpt::Application.config.aws_creds)
    cloudfront.create_invalidation(:distribution_id => ImageOpt::Application.config.aws[:cloudfront_distribution_id], :invalidation_batch => {:paths => {:quantity => 1, :items => [item_name]}, :caller_reference => "#{item_name} #{Time.now}"})
  end

  def create_file(s3_object, path)
    temp_file = Tempfile.new(File.basename path)
    temp_file.binmode
    temp_file.write(s3_object.read)
    temp_file.close
    temp_file
  end

  def get_content_type(file)
    mime_magic = MimeMagic.by_magic(file.open)
    file.close
    mime_magic.type if mime_magic.present?
  end

  def optimize_upload(file, image, content_type)
    image.original_size = file.size
    image_optim = ImageOptim.new(pngout: false, svgo: false, verbose: true, jpegoptim: {max_quality: 70})
    image_optim.optimize_image!(file)
    if file.size < image.original_size.to_i && s3_upload(image.path, file.path, content_type)
      image.modified = true
      image.current_size = file.size
      invalidate_cloudfront('/' + image.path) if image.dir_path.invalidate_cloudfront
    end
    image.optimized = true
    image.save
  end

  def optimize_upload_for_mobile(file, image, content_type)
    image.original_size = file.size
    # image_optim = ImageOptim.new(pngout: false, svgo: false, verbose: true, jpegoptim: {max_quality: 70})
    # image_optim.optimize_image!(file)
    img = Magick::Image::read(file.path).first
    imagepath = image.path.sub "_large.", "_large_m."
    # imagepath = image.path.sub "_zoom.", "_zoom."
    temp_file = Tempfile.new(File.basename imagepath)
    # img.resize_to_fit!(800,1100)
    img.write(temp_file.path) do
      self.quality = 70
      self.interlace = Magick::PlaneInterlace
    end

    uploadfilefrompath = temp_file.size < image.original_size.to_i ? temp_file.path : file.path

    if s3_upload(imagepath, uploadfilefrompath, content_type)
      image.modified = true
      image.current_size = temp_file.size < image.original_size.to_i ? temp_file.size : file.size
      invalidate_cloudfront('/' + image.path) if image.dir_path.invalidate_cloudfront
    end
    image.optimized = true
    image.save
# # ------------
#     imagepath = image.path.sub "_zoom.", "_small_m."
#     temp_file = Tempfile.new(File.basename imagepath)
#     img.resize_to_fit!(225,257)
#     img.write(temp_file.path) do
#       self.quality = 70
#       self.interlace = Magick::PlaneInterlace
#     end

#     uploadfilefrompath = temp_file.size < image.original_size.to_i ? temp_file.path : file.path

#     if s3_upload(imagepath, uploadfilefrompath, content_type)
#       image.modified = true
#       # image.current_size = temp_file.size < image.original_size.to_i ? temp_file.size : file.size
#       invalidate_cloudfront('/' + image.path) if image.dir_path.invalidate_cloudfront
#     end
#     image.optimized = true
#     image.save
  end
end