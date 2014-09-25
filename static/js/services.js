fileshareApp.service('ShareService', [
    '$http', '$q',
    function($http, $q) {
        return {

            sortIndex: function(a, b) {
                // sort by file or directory status
                if (a.kind > b.kind) return -1;
                if (a.kind < b.kind) return 1;
                // sort by name
                if (a.path < b.path) return -1;
                if (a.path > b.path) return 1;

                return 0;
            },

            loadNewIndex: function(path) {

                var index = $q.defer();

                console.log(path);
                $http.post("/index", {
                    "path": path
                }).success(function(data, status, headers, config) {
                    console.log("SUCCESS: ", data);
                    //$scope.currentPath = data.currentPath;
                    //$scope.index = data.index.sort(sortIndex);
                    //data.index = data.index.sort(this.sortIndex);
                    //console.log(data);
                    index.resolve(data);
                    //var crumbs = data.currentPath.split('/');
                    //for (var i in crumbs) {
                    //    if (crumbs[i] !== "") {
                    //        $scope.crumbs.push(crumbs[i]);
                    //    }
                    //}
                }).error(function(data, status, headers, config) {
                    console.log("ERROR: ", data, status, headers, config);
                });

                return index.promise;
            },

            downloadDirectory: function(path) {

                var dlPath = $q.defer();

                $http.post("/download-directory", {
                    "path": path
                }).success(function(data, status, headers, config) {
                    console.log("SUCCESS: ", data);
                    //window.open('/dl/' + data.path.replace("/tmp/fileshare/", ''), '_blank', '');
                    dlPath.resolve(data);
                }).error(function(data, status, headers, config) {
                    console.log("ERROR: ", data, status, headers, config);
                });

                return dlPath.promise;
            }
        };
    }
]);
