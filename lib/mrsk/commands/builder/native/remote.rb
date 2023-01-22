require "mrsk/commands/builder/native"

class Mrsk::Commands::Builder::Native::Remote < Mrsk::Commands::Builder::Native
  def create
    combine \
      create_context,
      create_buildx
  end

  def remove
    combine \
      remove_context,
      remove_buildx
  end

  def push
    docker :buildx, :build,
      "--push",
      "--platform", platform,
      "-t", config.absolute_image,
      *build_args,
      *build_secrets,
      "."
  end

  def info
    combine \
      docker(:context, :ls),
      docker(:buildx, :ls)
  end


  private
    def arch
      config.builder["remote"]["arch"]
    end

    def host
      config.builder["remote"]["host"]
    end

    def builder_name
      "mrsk-#{config.service}"
    end

    def builder_name_with_arch
      "#{builder_name}-#{arch}"
    end

    def platform
      "linux/#{arch}"
    end

    def create_context
      docker :context, :create,
        builder_name_with_arch, "--description", "'#{builder_name} #{arch} native host'", "--docker", "'host=#{host}'"
    end

    def remove_context
      docker :context, :rm, builder_name_with_arch
    end

    def create_buildx
      docker :buildx, :create,
        "--use", "--name", builder_name, builder_name_with_arch, "--platform", platform
    end

    def remove_buildx
      docker :buildx, :rm, builder_name
    end
end
