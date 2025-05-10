<html>
<script>
function updatePercent(percent)
{
 var oneprcnt = 4.15;
 var prcnt = document.getElementById('prcnt');
 prcnt.style.width = percent*oneprcnt;
 prcnt.innerHTML = percent + " %";
 
}
</script>
<body>
<div style="width: 415px; height: 20px;background-color:white;	padding:0px;" id="status"><div id="prcnt" style="height:18px;width:30px;overflow:hidden;background-color:lightgreen" align="center">0%</div></div>
<%
//call my fist stuff
Thread.sleep(3000);
out.println("<script>updatePercent(" + 30 + ")</script>\n");
out.flush();
//// the second part
Thread.sleep(3000);
out.println("<script>updatePercent(" + 30 + ")</script>\n");
out.flush();
Thread.sleep(3000);
//// the fthird parth
out.println("<script>updatePercent(" + 30 + ")</script>\n");
out.flush();
////done
%>
<script>
document.getElementById("status").style.display = "none";
</script>
</body>
