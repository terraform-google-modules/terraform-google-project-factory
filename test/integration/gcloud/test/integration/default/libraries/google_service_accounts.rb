require 'open3'

class GoogleServiceAccounts < Inspec.resource(1)
  name 'google_service_accounts'

  attr_reader :service_accounts

  def initialize(project: )
    @project  = project
    @service_accounts = nil
  end

  def exist?
    !service_accounts.nil?
  end

  def emails
    if exist?
      service_accounts.map { |acct| acct["email"] }
    end
  end

  def service_accounts
    @service_accounts ||= fetch_service_accounts
  end

  private

  def fetch_service_accounts()
    result = inspec.command("gcloud iam service-accounts list --project #{@project} --format='json'")
    if result.exit_status == 0
      @service_accounts = JSON.load(result.stdout)
    end
  end
end
