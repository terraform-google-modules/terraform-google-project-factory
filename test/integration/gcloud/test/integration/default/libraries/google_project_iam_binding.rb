require 'open3'

class GoogleProjectIamBinding < Inspec.resource(1)
  name 'google_project_iam_binding'

  def initialize(project:, role:)
    @project = project
    @role    = role
  end

  def exist?
    !binding.nil?
  end

  def members
    if exist?
      binding['members']
    else
      []
    end
  end

  def binding
    @binding ||= set_iam_binding
  end

  private

  def set_iam_binding()
    policy = fetch_iam_policy()
    bindings = policy['bindings']
    if bindings
      @binding = bindings.find { |b| b['role'] == @role }
    end
  end

  def fetch_iam_policy()
    cmd = "gcloud projects get-iam-policy #{@project} --format json"

    out, _err, status = Open3.capture3(cmd)
    if status.exitstatus == 0
      JSON.load(out)
    end
  end
end
