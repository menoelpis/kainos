class MembersController < ApplicationController
	PAGE_SIZE = 10

	def index
		@page = (params[:page] || 0).to_i
		if params[:keywords].present?
			@keywords = params[:keywords]
			member_search_term = MemberSearchTerm.new(@keywords)
			@members = Member.where(
				member_search_term.where_clause,
				member_search_term.where_args).
			order(member_search_term.order).
			offset(PAGE_SIZE * @page).limit(PAGE_SIZE)
		else
			@members = []
		end
	end

end