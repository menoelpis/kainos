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

=======================================================
Searching Logic for Member 
=======================================================

[app/models/member_search_term.rb]

class MemberSearchTerm
	attr_reader :where_clause, :where_args, :order
	def initialize(search_term)
		search_term = search_term.downcase
		@where_clause = ""
		@where_args = {}
		if search_term =~ /@/
			build_for_email_search(search_term)
		else
			build_for_name_search(search_term)
		end
	end

	def build_for_name_search(search_term)
		@where_clause << case_insensitive_search(:first_name)
		@where_args[:first_name] = starts_with(search_term)

		@where_clause << " OR #{case_insensitive_search(:last_name)}"
		@where_args[:last_name] = starts_with(search_term)

		@order = "last_name asc"
	end

	def starts_with(search_term)
		search_term + "%"
	end

	def case_insensitive_search(field_name)
		"lower(#{field_name}) like :#{field_name}"
	end

	def extract_name(email)
		email.gsub(/@.*$/,'').gsub(/[0-9]+/,'')
	end

	def build_for_email_search(search_term)
		@where_clause << case_insensitive_search(:first_name)
		@where_args[:first_name] = starts_with(extract_name(search_term))

		@where_clause << " OR #{case_insensitive_search(:last_name)}"
		@where_args[:last_name] = starts_with(extract_name(search_term))

		@where_clause << " OR #{case_insensitive_search(:email)}"
		@where_args[:email] = search_term

		@order = "lower(email) = " + 
		ActiveRecord::Base.connection.quote(search_term) + 
		" desc, last_name asc"
	end
end

[app/controllers/members_controller.rb]

def index
	if params[:keywords].present?
		@keywords = params[:keywords]
		member_search_term = MemberSearchTerm.new(@keywords)
		@members = Member.where(
			member_search_term.where_clause,
			member_search_term.where_args).
		order(member_search_term.order)
	else
		@members = []
	end
end

=======================================================
Query Performance Analyze
=======================================================

$ bundle exec rails dbconsole 

> EXPLAIN ANALYZE 
> SELECT * 
> FROM customers 
> WHERE 
> lower(first_name) like 'bob%' OR 
> lower(last_name) like 'bob%' OR 
> lower(email) = 'bob@example.com' 
> ORDER BY 
> email = 'bob@example.com' DESC, 
> last_name ASC ; 

=======================================================
Adding Lowercase Indexes on Member Fields
=======================================================

$ bundle exec rails g migration add-lower-indexes-to-memberrs

[db/migrate/12345_add_lower_indexes_to_members]

 class AddLowerIndexesToMembers < ActiveRecord::Migration

  def up
  	execute %{
  		CREATE INDEX 
  			members_lower_last_name
  		ON
  			members (lower(last_name) varchar_pattern_ops)
  	}
  	execute %{
  		CREATE INDEX 
  			members_lower_first_name
  		ON
  		 	members (lower(first_name) varchar_pattern_ops)
  	}
  	execute %{
  		CREATE INDEX 
  			members_lower_email
  		ON
  			members (lower(email))
  	}
  end

  def down
  	remove_index :members, name: 'members_lower_last_name'
  	remove_index :members, name: 'members_lower_first_name'
  	remove_index :members, name: 'members_lower_email'
  end

end

=======================================================
Pagination Implementation
=======================================================

[app/controllers/members_controller.rb]

class MembersController < ApplicationController 
+	PAGE_SIZE = 10

	def index 
+		@page = (params[:page] || 0).to_i
		# ...
	end 
end

@members = Member.where(
				member_search_term.where_clause,
				member_search_term.where_args).
			order(member_search_term.order).
+			offset(PAGE_SIZE * @page).limit(PAGE_SIZE)

[app/views/members/_pager.html.erb]

<nav>
	<ul class="pager">
		<li class="previous <%= page == 0 ? 'disabled' : '' %>">
			<%= link_to_if page > 0, "&larr; Previous".html_safe,
				members_path(keywords: keywords, page: page - 1) %>
		</li>
		<li class="next">
			<%= link_to "Next &rarr;".html_safe,
				members_path(keywords: keywords, page: page + 1) %>
		</li>
	</ul>
</nav>

[app/views/members/index.html.erb]

+ <%= render partial: "pager", locals: { keywords: @keywords, page: @page } %>

========================================
Angular Setup & Test
========================================

[Bowerfile]

+ asset 'angular', '~> 1.5'
+ resolution 'angular', '1.5'

$ bundle exec rake bower:install

[app/assets/javascripts/application.js]

+ //= require angular

[config/routes.rb]

+ get "angular_test", to: "angular_test#index"

[app/controllers/angular_test_controller.rb]

class AngularTestController < ApplicationController
	def index
	end
end

[app/views/angular_test/index.html.erb]

<article ng-app="angular_test"> 
	<header> 
		<h1 ng-if="name">Hello, {{name}}</h1>
	</header> 
	<section> 
		<form class="form-inline"> 
			<div class="form-group"> 
				<label for="name">Name</label> 
				<input class="form-control" name="name" type="text" placeholder="Enter your name" autofocus ng-model="name"> 
			</div> 
		</form> 
	</section> 
</article>

[app/assets/javascripts/angular_test_app.js]

+ angular.module('angular_test', [ ]);

========================================================
Angular SearchedFor Pipeline Implementation
========================================================

[app/views/members/index.html.erb]

<article ng-app="customers" ng-controller="CustomerSearchController"> 
	#......
	<section class="search-form">
		<form>
			<div class="input-group input-group-lg">
				<label for="keywords" class="sr-only">Keywords</label>
				<input type="text"
				       name="keywords"
				       class="form-control input-lg"
				       placeholder="First Name, Last Name, or Email Address"
				       ng-model="keywords">
				<span class="input-group-btn">
					<button class="btn btn-primary" ng-click="search(keywords)">
						Find Members
					</button>
				</span>
			</div>
		</form>
		<h1 class="searchedFor" ng-if="searchedFor">
			<small>Searched for:</small> {{searchedFor}}
		</h1>
	</section> 
	#.......
</article>

[app/assets/javascripts/members_app.js]

var app = angular.module('members', []);

app.controller("MemberSearchController", [
	"$scope",
	function($scope) {
		$scope.search = function(searchTerm) {
			$scope.searchedFor = searchTerm;
		}
	}
]);

========================================================
Angular Implementation - Hardcoded
========================================================

[app/assets/javascripts/members_app.js]

var app = angular.module('members', []);

app.controller("MemberSearchController", [
	"$scope",
	function($scope) {
		$scope.members = []; 
		$scope.search = function(searchTerm) { 
			$scope.members = [ 
				{ 
					"first_name":"Schuyler", 
					"last_name":"Cremin", 
					"email":"giles0@macgyver.net", 
					"username":"jillian0", 
					"created_at":"2015-03-04", 
				}, 
				{ 
					"first_name":"Derick", 
					"last_name":"Ebert", 
					"email":"lupe1@rennerfisher.org", 
					"username":"ubaldo_kaulke1", 
					"created_at":"2015-03-04", 
				}, 
				{ 
					"first_name":"Derick", 
					"last_name":"Johnsons", 
					"email":"dj@somewhere.org", 
					"username":"djj", 
					"created_at":"2015-03-04", 
				}
			]
		}
	}
]);

[app/views/members/index.html.erb]

<ol class="list-group">
	<li class="list-group-item clearfix" 
		ng-repeat="member in members">
		<h3 class="pull-right">
			<small class="text-uppercase">Joined</small>
			{{ member.created_at }}
		</h3>
		<h2 class="h3">
			{{ member.first_name }} {{ member.last_name }}
			<small>{{ member.username }}</small>
		</h2>
		<h4>{{ member.email }}</h4>
	</li>
</ol>

========================================================
Making an Ajax Request to Complete the Circle
========================================================

[app/controllers/members_controller.rb]

class CustomersController < ApplicationController 
	def index

		# existing index method

		respond_to do |format| 
			format.html {} 
			format.json { render json: @customers } 
		end 
	end 
end

[app/assets/javascripts/members_app.js]

app.controller("MemberSearchController", [
+	"$scope", "$http",
+	function($scope, $http) {

+		var page = 0;

		$scope.members = []; 
		$scope.search = function(searchTerm) {
+			if (searchTerm.length < 3) {
+				return;
+			}

+			$http.get("/members.json",
+				{ "params" : { "keywords": searchTerm, "page": page } }
+			).then(function(response) {
+				$scope.members = response.data;
+			}, function(response) {
+				alert("There was a problem: " + response.status);
+				}
+			);
		}

		$scope.previousPage = function() {
			if (page > 0) {
				page = page - 1;
				$scope.search($scope.keywords);
			}
		}

		$scope.nextPage = function() {
			page = page + 1;
			$scope.search($scope.keywords);
		}
	}
]);

[app/views/members/index.html.erb]

<h3 class="pull-right">
	<small class="text-uppercase">Joined</small>
	{{ member.created_at | date }}
</h3>