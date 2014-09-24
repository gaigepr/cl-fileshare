'use strict';

var fileshareApp = angular.module('fileshareApp', []);

fileshareApp.directive('indexEntry', function() {
    return {
        restrict: 'AE',
        replace: 'true',
        templateUrl: '/static/index-entry.html'
    };
});

fileshareApp.controller('ShareCtrl', [
    '$scope', '$http',
    function($scope, $http) {

        // gets the last element of a filepath (unix)
        $scope.lastPathElementRegexp = /[^/]+\/*$/;
        $scope.shareRoot = "/home/gaige/Dropbox/";
        $scope.currentPath = "";
        $scope.index = [];

        // When we get back an object from the api we need to sort it.
        // We might also want to extract filename/last index of the path
        // for display purposes. This could also be done on the lisp side
        // pretty easily I think but that means more data being transfered

        var sortIndex = function(a, b) {
            // sort by file or directory status
            if (a.kind > b.kind) return -1;
            if (a.kind < b.kind) return 1;
            // sort by name
            if (a.path < b.path) return -1;
            if (a.path > b.path) return 1;

            return 0;
        };

        $scope.handleItem = function(item) {
            if (item.kind == "Folder") {
                //console.log("Request to download tree: ", item.path);
                //$scope.loadNewIndex(item.path);
                $scope.downloadDirectory(item.path);
            } else if (item.kind == "File") {
                window.open('/download/' + item.path.replace($scope.shareRoot, ''), '_blank', '');
                console.log("Request to download file: ", item.path);
            }
        };

        $scope.downloadDirectory = function(path) {
            $http.post("/download-directory", {
                "path": path
            }).success(function(data, status, headers, config) {
                console.log("SUCCESS: ", data);
                window.open('/download/' + data.path.replace($scope.shareRoot, ''), '_blank', '');
                //$scope.currentPath = data.currentPath;
                //$scope.index = data.index.sort(sortIndex);
            }).error(function(data, status, headers, config) {
                console.log("ERROR: ", data, status, headers, config);
            });
        };

        $scope.loadNewIndex = function(path) {
            $http.post("/index", {
                "path": path
            }).success(function(data, status, headers, config) {
                console.log("SUCCESS: ", data);
                $scope.currentPath = data.currentPath;
                $scope.index = data.index.sort(sortIndex);
            }).error(function(data, status, headers, config) {
                console.log("ERROR: ", data, status, headers, config);
            });
        };

        $scope.loadNewIndex("/home/gaige/Dropbox/");

    }
]);
