'use strict';

var fileshareApp = angular.module('fileshareApp', []);

fileshareApp.controller('ShareCtrl', [
    '$scope', '$http',
    function($scope, $http) {

        $scope.currentPath = "";
        $scope.index = [];

        var sortIndex = function(a, b) {
            // sort by file or directory status
            if (a.kind > b.kind) return -1;
            if (a.kind < b.kind) return 1;
            // sort by name
            if (a.path < b.path) return -1;
            if (a.path > b.path) return 1;
            return 0;
        };

        $http.post("/api", {
            "path": "/home/gaige/quicklisp/"
        }).success(function(data, status, headers, config) {
            console.log("SUCCESS: ", data);
            $scope.currentPath = data.currentPath;
            $scope.index = data.index.sort(sortIndex);
        }).error(function(data, status, headers, config) {
            console.log("ERROR: ", data, status, headers, config);
        });

    }
]);
