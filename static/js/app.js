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
    '$scope', '$http', '$location', 'ShareService',
    function($scope, $http, $location, ShareService) {

        // gets the last element of a filepath (unix)
        $scope.lastPathElementRegexp = /[^/]+\/*$/;
        $scope.shareRoot = "/home/gaige/Dropbox/";
        $scope.currentPath = "";
        $scope.crumbs = [];
        $scope.index = [];

        // When we get back an object from the api we need to sort it.
        // We might also want to extract filename/last index of the path
        // for display purposes. This could also be done on the lisp side
        // pretty easily I think but that means more data being transfered

        //$scope.splitCurrentPath = function()

        ShareService.loadNewIndex("/home/gaige/Dropbox/").then(function(data) {
            // get and sort the index
            $scope.index = data.index.sort(ShareService.sortIndex);
        });

        $scope.handleItem = function(item) {
            console.log("Reqeust");
            if (item.kind == "Folder") {
                ShareService.loadNewIndex(item.path).then(function(data) {
                    $scope.index = data.index.sort(ShareService.sortIndex);
                    $location.path(item.path);
                });
            } else if (item.kind == "File") {
                window.open('/download/' + item.path.replace($scope.shareRoot, ''), '_blank', '');
                console.log("Request to download file: ", item.path);
            }
        };

        $scope.joinCrumbs = function(index) {
            console.log(index);
            var path = "/";
            for (var i = 0; i <= index; i++) {
                path += $scope.crumbs[i] + "/";
            }
            console.log(path);
            return path;
        };

    }
]);
