require_relative '../facades/github_facade'

class ApplicationController < ActionController::Base
  # before_action :get_pr_total, :user_names
  
  private

  def user_names
    @user_names = GitHubFacade.user_names
  end

  def get_pr_total
    @pr_total = GitHubFacade.get_pr_total
  end
end
