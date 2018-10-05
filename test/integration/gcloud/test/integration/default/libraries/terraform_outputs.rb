require 'open3'
require 'json'

class TerraformOutputs < Inspec.resource(1)
  name 'terraform_outputs'

  def initialize(dir: Dir.getwd(), mod: nil)
    @dir = dir
    @mod = mod
    read_outputs()
  end

  def exist?
    !@outputs.nil?
  end

  def method_missing(m, *args)
    key = m.to_s
    if exist? && @outputs.key?(key)
      @outputs[key]["value"]
    else
      nil
    end
  end

  def to_s
    "Terraform outputs (#{@dir})"
  end

  private

  def read_outputs
    cmd = "terraform output -json"
    if @mod
      cmd << " -module #{@mod}"
    end

    out, _err, status = Open3.capture3(cmd, chdir: @dir)

    if status.exitstatus == 0
      @outputs = JSON.load(out)
    end
  end
end
