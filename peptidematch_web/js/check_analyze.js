var checkflag = "false";
var global_list = [];

function update_global_list(value,flag,checked)
{
  var temp_list = [];
if(flag == "single")
  {
    var exists = false;
    for(var i =0; i<global_list.length;i++)
   {
     if(global_list[i] == value)
     {
      exists = true;
      continue;
     }
     else 
      temp_list.push(global_list[i]);
    }
  if(exists == false)
  temp_list.push(value);
  }
else
 {
  if(checked == true){
    temp_list = global_list; 
   for(var i=0;i<value.length;i++)
   {
       var exists = false; 
       for(var j=0;j<global_list.length;j++)
          if(value[i]==global_list[j])
          {
          exists = true;
          break;
        }
    if(exists == false)
       temp_list.push(value[i]);
  }     
 }
 else
 {
   for(var i=0; i<global_list.length;i++)
   {
     var exists = false;
      for(var j =0 ; j< value.length;j++)
          if(global_list[i] == value[j])
            {
            exists = true;
            break;
           }
    if(exists == false)
        temp_list.push(global_list[i]);
  }
  }
}
 global_list = temp_list;
 updateCheckbox();
}

function updateCheckbox()
{
  var idlist = document.getElementsByName('idlist');
  var all_checked = false;
  var count = 0;
  for(var i = 0; i<idlist.length;i++)
 { 
    var checked = false;
   for(var j =0 ; j<global_list.length;j++)
       if(idlist[i].value == global_list[j])
       {
          idlist[i].checked = true;
          checked = true;
          count++;
       }
   if(checked == false) idlist[i].checked = false;
 }
if(count == idlist.length)
    all_checked = true;
  if(all_checked == false)
    document.getElementById('all_box').checked = false;
  else
    document.getElementById('all_box').checked = true;
}

/*function check(field) 
{ 
   if (checkflag == "false") { 
      for (i = 0; i < field.length; i++) { 
         field[i].checked = true 
	      }
	      if (i == 0) { 
	         field.checked = true 
	      }
	      checkflag = "true" 
	   } else { 
	      for (i = 0; i < field.length; i++) { 
	        field[i].checked = false 
	      } 
	      if (i == 0) { 
	        field.checked = false 
	      }
	      checkflag = "false" 
	   } 
}
 
function test_sel(form) 
{ 
      var sel_num=0 
      for(var x=0; x<form.idlist.length; x++) { 
          if (form.idlist[x].checked==true) { 
            sel_num++ 
          } 
      } 
      if (x == 0) { 
         if (form.idlist.checked==true) { 
           sel_num++ 
         } 
      }
      if ( sel_num >50 ) { 
         var answer=confirm("More than 50 proteins are selected. Proceed with the most recently selected 50 entries?") 
         if (!answer) { 
             return false; 
         }  
      }  
}
*/

function verifyNums(tool,organism_id) 
{ 
    var anal=tool;
    var curnum = global_list.length; 
  if(curnum == 0){
    alert("please select at least one sequence");
    return false;
   }
else{
    if (anal == 'blast' || anal == 'fasta' || anal == 'pat' || anal == 'hmm') { 
         if ( curnum == 0 ) { 
             alert('Please pick one protein first.') 
         } else if ( curnum > 1 ) { 
          var answer=confirm("More than one protein is selected. Process the first one?") 
          if (answer) { 
             newWin(anal,organism_id) 
             }  
         } else if ( curnum == 1 ) { 
             newWin(anal,organism_id) 
         }  
     } 
    if ( anal == 'maln' ) { 
	   if ( curnum < 2 ) { 
             alert('Please pick at least two proteins.') 
        } else if ( curnum > 50 ) { 
             alert('Too many proteins are selected. Please narrow them down. The maximum is 50.') 
        } else { 
             newWin(anal,organism_id); 
        } 
     } 
    if ( anal == 'dom' ) { 
	   if ( curnum < 1 ) { 
             alert('Please pick at least one protein.') 
	        } else if ( curnum > 50 ) { 
             alert('Too many proteins are selected. Please narrow them down. The maximum is 50.') 
        } else { 
            newWin(anal,organism_id); 
        } 
     }
    } 
     return false 
    }

function newWin(anal,organism_id) 
{ 
   winprops = 'menubar,toolbar,status,height=600,width=750,resizable,scrollbars=yes,left=80,top=20' 
   var tool = anal; 
   var ids = ''; 
   for (i = 0; i < global_list.length; i++) { 
            ids += '&idlist=' + global_list[i]; 
   } 
   if(organism_id == "all"||organism_id == "ALL"||organism_id == "")
      organism_id = "on";
   if(anal == 'dom'){
   windowURL = 'http://pir20.georgetown.edu/cgi-bin/seq_dom.pl?tool=' + tool + '&db='+organism_id + ids; 
   }
   else{
   windowURL = 'http://pir20.georgetown.edu/cgi-bin/seq_ana_main.pl?tool=' + tool + '&db='+organism_id + ids; 
   }
		  // alert(windowURL);
   win = window.open(windowURL, tool, winprops) 
   win.focus(); 
}

function save_data(format,query,ilEquivalent){
 if(global_list.length == 0) {
   alert("Please use the checkbox on the left to select before download");
   return false;
  }
 else {
    var ids = ''; 
    for (i = 0; i < global_list.length; i++) { 
          ids += global_list[i]+';';
    } 
   var uniref100Only = document.getElementById("uniref100").value; 
  windowURL = './server/savedata.jsp?keyword='+query+'&ids='+ids+'&format='+format+'&uniref100Only='+uniref100Only+'&ilEquivalent='+ilEquivalent;
  window.open(windowURL);
  return false;
 }
}
 
function current_sel(form,value,organism_id,keyword,lEQi) 
{
   var all_checked = false;
   var current_list = [];
   var ids = document.getElementsByName('idlist');
   if(value != "all"){ 
   var sel_num=0;
    for(var x=0; x<ids.length; x++) { 
        if (ids[x].checked == true)  
          sel_num++;
    current_list.push(ids[x].value); 
  }
  if(sel_num == ids.length) 
    all_checked = true;
    if (all_checked==true) { 
         form.all.checked = true;
    } else {
         form.all.checked = false;
    }
    update_global_list(value,"single");
   }
   else
  {
  if(document.getElementById("all_box").checked) 
     all_checked = true;
  for(var x=0; x<ids.length; x++) { 
    current_list.push(ids[x].value); 
  }
    update_global_list(current_list,"all",all_checked);
  }
   showSelected(global_list.length,organism_id,keyword,lEQi);
       return false 
}

function showSelected(global_num,organism_id,keyword,lEQi){
 var obj=document.getElementById('select_box') 
        var show_img='' 
    if (global_num > 0) { 
       show_img='<input type=image onclick="return selWindow(\''+organism_id+'\',\''+keyword+'\',\''+lEQi+'\')" name=show_selected src=./imagefiles/show.png border=0>' 
    } 
 var sel_box='<table border=0 cellspacing=0 cellpadding=2><tr>' 
       sel_box+='<td nowrap><img src=./imagefiles/transparent_dot.png border=0 height=1 width=4>'+global_list.length+'</td>' 
       sel_box+='<td><img src=./imagefiles/selected.png border=0></td>' 
       sel_box+='<td>' + show_img + '</td></tr></table>' 
		 obj.innerHTML=sel_box 
}


function selWindow(organism_id,keyword,lEQi) 
{ 
    winprops = 'menubar,toolbar,status,height=300,width=760,resizable,scrollbars=yes,left=80,top=20';
    var tool='selWin';
    var uniref100 = document.getElementById("uniref100").value; 
    var ids='';
    for (i = 0; i < global_list.length; i++) { 
          ids += global_list[i]+';';
    } 
//    if ( sel_num >50 ) { 
//       var answer=confirm("More than 50 proteins are selected. Proceed with the most recently selected 50 entries?") 
//       if (!answer) { 
//           return false; 
//       }  
//    }  
    windowURL = './showpeptidewithids.jsp?organism_id='+organism_id+'&ids='+ ids +'&keyword='+keyword+'&lEqi='+ lEQi+'&uniref100='+uniref100
    win = window.open(windowURL, tool, winprops) 
    win.focus(); 
    return false; 
} 
 
