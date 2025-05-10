<html lang="en">
    <head>
        <title>Show progress of long running process with help of Thread and Ajax.</title>
        <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
        <script type="text/javascript">
            $(document).ready(init);

            function init() {
                if (${not empty longProcess}) {
                    //$.progress = "";
                    checkProgress();
                }
            }
            function checkProgress() {
               	jQuery.get('batchpeptidematch', function(progress) {
                    jQuery('#progress').html(progress);
			if(progress.indexOf("Finished") == -1) {
                    		setTimeout(checkProgress, 1000);
				
			}
                });
            }
        </script>
    </head>
    <body>
        <form action="batchpeptidematch" method="post">
            <p>Run long process: <input type="submit"></p>
		<!--
            <p>Current status: <span id="progress">0</span>%</p>
		-->
        </form>
		<div id="progress"></div>
    </body>
</html>
