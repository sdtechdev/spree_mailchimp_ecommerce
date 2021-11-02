source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

spree_branch = '2-3-stable'
gem 'spree', github: 'spree/spree', branch: spree_branch
gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: spree_branch
gem 'rspec-sqlimit', git: 'https://github.com/nepalez/rspec-sqlimit', ref: '0c62feb61710c93f20f086a427a7a14784e5ca0d'
gemspec
