class MembersController < ApplicationController

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

end