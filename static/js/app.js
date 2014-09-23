'use strict';

var fileshareApp = angular.module('fileshareApp', []);

fileshareApp.controller('ShareCtrl', [
    '$scope', '$http',
    function($scope, $http) {

        $scope.currentPath = "";
        $scope.index = [];

        $http.post("/api", {
            "path": "/home/gaige/quicklisp/"
        }).success(function(data, status, headers, config) {
            console.log("SUCCESS: ", data);
            $scope.index = data.index;
        }).error(function(data, status, headers, config) {
            console.log("ERROR: ", data, status, headers, config);
        });

    }
]);
