require 'open3'

class GoogleComputeSubnetIamBinding < Inspec.resource(1)
  name 'google_compute_subnet_iam_binding'

  def initialize(subnet:, role:)
    @subnet = subnet
    @project, @region, @name = destructure_subnet(subnet)
    @role = role

    set_iam_binding()
  end

  def exist?
    !@binding.nil?
  end

  def members
    @binding.nil? ? [] : @binding['members']
  end

  def to_s
    "Subnet IAM #{@subnet.inspect} binding #{@role}"
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
    cmd = "gcloud beta compute networks subnets get-iam-policy #{@name} " +
          "--region='#{@region}' --project='#{@project}' --format=json"

    out, err, status = Open3.capture3(cmd)
    if status.exitstatus != 0
      raise Inspec::Exceptions::ResourceFailed, "Cannot fetch IAM policy for subnetwork #{@subnet.inspect}: #{err}"
    end
    JSON.load(out)
  end

  def destructure_subnet(subnet)
    pattern = %r[\Aprojects/(.*?)/regions/(.*?)/subnetworks/(.*?)\z]
    if (match = subnet.match(pattern))
      return match[1], match[2], match[3]
    else
      raise Inspec::Exceptions::ResourceFailed, "Subnetwork #{subnet.inspect} does not match pattern #{pattern.inspect}"
    end
  end
end
