require 'pipeline/mounters/base_mounter'

class Pipeline::DockerMounter < Pipeline::BaseMounter

  Pipeline::Mounters.add self
  
  #Pass in path to the root of the Rails application
  def initialize trigger, options
  	super(trigger)
    @options = options
  end

  def mount target
    base = @options[:working_dir]
    target = target.slice(0, target.length - 7)
    working_target = base + "/docker/" + target + "/"
    Pipeline.notify "Cleaning directory: #{working_target}"
    if ! working_target.match(/\A\/var\/redsky\/.*/)
      Pipeline.notify "Bailing in case #{working_target} is malicious."      
    else
      result = `rm -rf #{working_target}`
      Pipeline.debug result
      result = `mkdir -p #{working_target}`
      Pipeline.debug result
      result = `docker export #{target} > #{working_target}#{target}.tar`
      Pipeline.debug result
      result = `tar -C #{working_target} -xf #{working_target}#{target}.tar`
      Pipeline.debug result
      result = `rm #{working_target}#{target}.tar`
      Pipeline.debug result
    end
    return working_target
  end
  
  def supports? target
    last = target.slice(-7,target.length)
    Pipeline.debug "Target: #{target} became: #{last}"
    if last === ".docker"
      return true
    else
      return false
    end
  end
end
