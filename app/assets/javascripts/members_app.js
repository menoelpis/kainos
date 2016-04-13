var app = angular.module('members', []);

app.controller("MemberSearchController", [
	"$scope",
	function($scope) {
		$scope.search = function(searchTerm) {
			$scope.searchedFor = searchTerm;
		}
	}
]);