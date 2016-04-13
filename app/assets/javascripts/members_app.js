var app = angular.module('members', []);

app.controller("MemberSearchController", [
	"$scope", "$http",
	function($scope, $http) {

		var page = 0;

		$scope.members = []; 
		$scope.search = function(searchTerm) {
			if (searchTerm.length < 3) {
				return;
			}

			$http.get("/members.json",
				{ "params" : { "keywords": searchTerm, "page": page } }
			).then(function(response) {
				$scope.members = response.data;
			}, function(response) {
				alert("There was a problem: " + response.status);
				}
			);
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


