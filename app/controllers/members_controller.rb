class MembersController < ApplicationController

	def index
		@members = Member.all.limit(10)
	end

end