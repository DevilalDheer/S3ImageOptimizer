class CollectImagesJob < ActiveJob::Base
  queue_as :collect_images

  S3Client = Aws::S3::Client.new(:credentials => ImageOpt::Application.config.aws_creds, :region => ImageOpt::Application.config.aws[:region])
  S3Bucket = Aws::S3::Bucket.new(ImageOpt::Application.config.aws[:bucket], :client => S3Client)

  def perform(id)
    dir_path = DirPath.find_by_id(id)
    if dir_path.present?
      aws_image_list = S3Bucket.objects(:prefix => dir_path.path).collect(&:key)
      aws_image_list_o = aws_image_list.select{ |aws_image| aws_image[/_original\./] }
      # puts aws_image_list_large
      # aws_image_list_o.each {|aws_image| dir_path.images.create(:path => aws_image)} if aws_image_list_o.present?
      aws_image_list_o.each do |o|
        image = dir_path.aws_images.create(:path => o)
        image.original=true
        image.save
      end
    end
  end
end
