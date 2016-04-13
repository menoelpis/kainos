================================
Rails New
================================

$ rails new --skip-turbolinks \
            --skip-spring     \
            --skip-test-unit  \
            -d postgresql     \
            shine

<note> github-setup
$ git init
$ git add . 
$ git commit -m "Initial Setup"
$ git remote show origin
$ git remote set-url origin git+ssh://git@github.com/username/reponame.git

============================================
PostgreSQL Setup
============================================

$ psql postgres
postgres> CREATE USER shine PASSWORD 'shine'
postgres> ALTER USER shine CREATEDB;

[config/database.yml]
default: &default
	adapter: postgresql
	encoding: unicode
   +host: localhost
   +username: shine
   +password: shine
    pool: 5

================================
Database Setup
================================

$ bundle exec rake db:create
$ bundle exec rake db:migrate
$ bundle exec rails server

============================================
Devise Setup
============================================
[Gemfile] + gem 'devise', '3.5.6'
$ bundle install
$ bundle exec rails generate devise:install
$ bundle exec rails generate devise user

<note>Restriction on all pages
[app/controllers/application_controller.rb]
+ before_action :authenticate_user!

$ bundle exec rake db:migrate
$ bundle exec rails server -> Sign In / Log In

$ bundle exec rails dbconsole
postgres> \x on
postgres> select * from users;
postgres> \q

========================================
Bower Setup
========================================
$ npm install -g bower
[Gemfile] + gem 'bower-rails'
$ bundle install
$ bundle exec rake -T bower

Create "Bowerfile" in root
+ asset 'bootstrap-sass-official' 

<note> http://bower.is/search

$ bower search bootstrap | head
$ bundle exec rake bower:install

[app/assets/stylesheets/application.css]
+ *= require 'bootstrap-sass-official'

=========================================
Devise View
=========================================

$ bundle exec rails generate devise:views

=========================================
PostgreSQL Email Constraint
=========================================

$ bundle exec rails g migration add-email-constraint-to-users
+
def up
	execute %{
		ALTER TABLE
			users 
		ADD CONSTRAINT 
			email_must_be_company_email
		CHECK ( email ~* '^[^@]+@example\\.com' )
	}  
  end

def down
	execute %{
		ALTER TABLE
			users 
		DROP CONSTRAINT
			email_must_be_company_email
	}
end

$ bundle exec rake db:migrate

<note> UPDATE users SET email = 'user2@example.com' WHERE id = 1;

$ bundle exec rails dbconsole

kainos_development> INSERT INTO
				   	users (
				   		email,
				   		encrypted_password,
				   		created_at,
				   		updated_at
				   	)
				   VALUES (
				   	'foo@example.com',
				   	'$abcd',
				   	now(),
				   	now()
				   );

=========================================
PostgreSQL Schema Change
=========================================

[/config/application.rb]
+ config.active_record.schema_format = :sql

$ rm db/schema.rb
$ bundle exec rake db:migrate
$ RAILS_ENV=test bundle exec rake db:drop
$ RAILS_ENV=test bundle exec rake db:create

=========================================
Create Member Model 
=========================================

$ bundle exec rails g model member first_name:string \ 
> last_name:string \ 
> email:string \ 
> username:string

[db/migrate/123445_create_members.rb]
+ null: false [on all rows]
+ add_index :customers, :email, unique: true
+ add_index :customers, :username, unique: true

$ bundle exec rake db:migrate

=========================================
Member Creation with Faker Gem
=========================================

[Gemfile]
+ gem 'faker'

$ bundle install

[db/seed.rb]
350_000.times do |i| 
	Customer.create!( 
		first_name: Faker::Name.first_name, 
		last_name: Faker::Name.last_name, 
		username: "#{Faker::Internet.user_name}#{i}", 
		email: Faker::Internet.user_name + i.to_s + "@#{Faker::Internet.domain_name}") 
end

$ bundle exec rake db:seed

=======================================================
Member Search Index Page
=======================================================

[config/routes.rb]
+ resources :members, only: [ :only ]

<note> Limit Member Query to 10
[app/controllers/members_controller.rb]

class CustomersController < ApplicationController 
	def index 
		@customers = Customer.all.limit(10) 
	end
end

<note> Implement Search Index Page
[app/views/members/index.html.erb]

<header>
	<h1 class="h2">
		Member Search
	</h1>
</header>
<section class="search-form">
	<%= form_for :members, method: :get do |f| %>
		<div class="input-group input-group-lg">
			<%= label_tag :keywords, nil, class: "sr-only" %>
			<%= text_field_tag :keywords, nil, placeholder: "First Name, Last Name, or Email Address", class: "form-control input-lg" %>
			<span class="input-group-btn">
				<%= submit_tag "Find Members", class: "btn btn-primary" %>
			</span>
		</div>
	<% end %>
</section>
<section class="search-results">
	<header>
		<h1 class="h3">Results</h1>
	</header>
	<table class="table table-striped">
		<thead>
			<tr>
				<th>First Name</th>
				<th>Last Name</th>
				<th>Email</th>
				<th>Joined</th>
			</tr>
		</thead>
		<tbody>
			<% @members.each do |member| %>
				<tr>
					<td><%= member.first_name %></td>
					<td><%= member.last_name %></td>
					<td><%= member.email %></td>
					<td><%= l member.created_at.to_date %></td>
				</tr>
			<% end %>
		</tbody>
	</table>
</section>