module DeviseAvatarable
  module AvatarDefaults
    def self.limit_to
      [1000, 1000]
    end

    def self.convert_to
      :jpg
    end

    def self.editor_size
      200
    end

    def self.version(size)
      { default: size || [200,200] }
    end
    # Returns the aspect ratio to use in the crop tool.
    def self.aspect_ratio(avatar_name, versions)
      aspect = nil
      warned = false
      versions.each do |name, args|
        args.extract_options!

        if aspect != (args[0] / (args[1] + 0.0)) && aspect.present? && !warned
          warn "Different aspect rations detected for avatar '#{avatar_name}'. Make sure all versions are of the same aspect ratio or the cropping won't work correctly. #{versions}"
          warned = true
        end

        aspect = args[0] / (args[1] + 0.0)
      end
      aspect || 1
    end
  end
end
