window.onunload=function(){
window.localStorage.clear();
if(UPLOAD_CORE.files_data[UPLOAD_CORE.lastFileLoad]!=null){
localStorage.setItem("UPLOAD_LAST_FILE",UPLOAD_CORE.files_data[UPLOAD_CORE.lastFileLoad].name);
localStorage.setItem("UPLOAD_LAST_FILE_TYPE",UPLOAD_CORE.files_data[UPLOAD_CORE.lastFileLoad].type);
}
localStorage.setItem("UPLOAD_C_DATA",document.getElementById("file_upload").innerHTML);
localStorage.setItem("UPLOAD_CORE_DATA_FILES",UPLOAD_CORE.files);
localStorage.setItem("UPLOAD_CORE_DATA_LAST_FILE_ID",UPLOAD_CORE.lastFileLoad);
for(i=0;i<=100;i++){
if(UPLOAD_CORE.files_data[i]!=null){
localStorage.setItem("UPLOAD_CORE_DATA_"+i,JSON.stringify(UPLOAD_CORE.files_data[i]));
}
}

};

document.addEventListener('DOMContentLoaded', function() {
document.temp_file_upload_f.addEventListener('change', checkFile, false);
}, false);


function checkFile(e) {

    var file_list = e.target.files;

		file=file_list[0];
        UPLOAD_CORE.temp_name=file.name;
		if(file.size>1024){
		UPLOAD_CORE.temp_size=Math.ceil(file.size/1024)+ " KB";
		}else{
		UPLOAD_CORE.temp_size=file.size + " B";
		}
        
		
	UPLOAD_CORE.isFile=true;

}

var UPLOAD_CORE={
MAX_FILES:100,
files:0,
loadedFiles:0,
files_data:new Array(this.MAX_FILES),
loadingFile:0,
isLoading:false,
temp_name:"",
temp_size:"",
isFile:false,
onlyOne:false,
XHR:0,
lastFileLoad:0,

ADD_FILE:function (){
if(this.isFile){
this.files_data[this.files]=new Object();
this.files_data[this.files].name=this.temp_name;
this.files_data[this.files].prog=0;
this.files_data[this.files].size=this.temp_size;
this.files_data[this.files].formData=new FormData(document.temp_file_upload_f);
this.files_data[this.files].formData.append("file",document.temp_file_upload_f.file);
this.files_data[this.files].formData.append("fID",this.files);
this.files_data[this.files].loaded=false;
this.files_data[this.files].type=0;

document.getElementById("file_upload_c_"+this.files).innerHTML="<table><tr><td id='upload_b_n_"+this.files+"' width='310'>"+this.files_data[this.files].name+"</td><td width='15'></td><td width='80'>"+this.files_data[this.files].size+"</td><td width='15'></td><td width='250'><div id='progBarBG"+this.files+"' class='file_upload_bar_bg_h'><img width='0' height='20' src='img/upload/bar.png' class='progBar' id='progBar"+this.files+"'/></div></td><td width='20'></td><td width='100'><select id='file_type_"+this.files+"' onchange='javascript:UPLOAD_CORE.CHECK_TYPE("+this.files+")'><option value='0'>Trénovacia</option><option value='1'>Testovacia</option><option value='2'>...</option></select></td><td width='15'></td><td id='upload_b_c_"+this.files+"' width='50'><button class='upload_button_b' onclick='javascript:UPLOAD_CORE.UPLOAD_SPC("+this.files+");' id='upload_button_b"+this.files+"'></button></td><td width='50'><button class='button_remove' onclick='javascript:UPLOAD_CORE.REMOVE("+this.files+");' id='remove_button_"+this.files+"'></button></td></tr></table>";
this.files++;
document.getElementById("file_upload").innerHTML+="<div class='file_upload_c' id='file_upload_c_"+this.files+"'><table><tr><td width='400'><form name='temp_file_upload_f' method='post' enctype='multipart/form-data'><input name='file' type='file'/></form></td><td width='480'></td><td width='50'><button class='add_button' type='button' onclick='javascript:UPLOAD_CORE.ADD_FILE();'/></button></td></tr></table></div>";
this.isFile=false;
document.temp_file_upload_f.addEventListener('change', checkFile, false);
for(i=0;i<100;i++){
    if(this.files_data[i] != null){
       
       document.getElementById("file_type_"+i).selectedIndex="" + this.files_data[i].type;
        
    }
}

this.UPLOAD_INIT(this.files);
}
},
CHECK_TYPE:function (id){
this.files_data[id].type=parseInt(document.getElementById("file_type_"+id).value);
}
,
UPLOAD_SPC:function (id){
if(!this.isLoading){
this.onlyOne=true;
this.isLoading=true;
this.loadingFile=id;
this.UPLOAD();
}
},
START_UPLOAD: function (file){
if(!this.isLoading){
if(this.files!=0){
for(i=0;i<=100;i++){
if(this.files_data[i]!=null){
if(!this.files_data[i].loaded){
this.loadingFile=i;
break;
}
}
}
if(this.files_data[this.loadingFile]!=null){
if(!this.files_data[this.loadingFile].loaded){
this.isLoading=true;
this.UPLOAD();
}
}
}
}
},		
NEXT_UPLOAD:function(){
if(this.isLoading){
for(i=this.loadingFile;i<=100;i++){
if(this.files_data[i]!=null){
if(!this.files_data[i].loaded){
this.loadingFile=i;
break;
}
}
}
if(this.files_data[this.loadingFile]!=null){
if(!this.files_data[this.loadingFile].loaded){
this.UPLOAD();
}else{
this.isLoading=false;
}
}else{
this.isLoading=false;
}
}
},
REMOVE:function(id){


if(this.loadingFile==id && this.isLoading){
this.XHR.abort();
document.getElementById("progBar"+this.loadingFile).setAttribute("width","0px");
document.getElementById("progBarBG"+this.loadingFile).setAttribute("class","file_upload_bar_bg_h");
this.isLoading=false;
}else{
document.getElementById("file_upload").removeChild(document.getElementById("file_upload_c_"+id));
this.files_data[id]=null;
}

},
UPLOAD_INIT:function(id){
	var formData = this.files_data[id-1].formData;
	var _XHR = new XMLHttpRequest();
	_XHR.open("POST", "fileUpload_cache.jsp", true); 
	_XHR.send(formData);
},
UPLOAD:function () {

	var formData = new FormData(document.temp_file_f_up);
	formData.append("fID",this.loadingFile);
	document.getElementById("progBarBG"+this.loadingFile).setAttribute("class","file_upload_bar_bg");
	this.XHR = new XMLHttpRequest();
	this.XHR.upload.addEventListener("progress", UPLOAD_CORE.UPLOAD_PROG, false);
	this.XHR.addEventListener("load",  UPLOAD_CORE.UPLOAD_COMP, false);
	this.XHR.open("POST", "fileUpload.jsp", true); 
	this.XHR.send(formData);
},

UPLOAD_PROG:function (event) {

	var progress = Math.floor((100/event.total)*event.loaded);
	document.getElementById("progBar"+UPLOAD_CORE.loadingFile).setAttribute("width",1.8*progress + "px");

},
UPLOAD_COMP:function uploadComplete(event) {
	document.getElementById("progBar"+UPLOAD_CORE.loadingFile).setAttribute("width","200px");
	UPLOAD_CORE.files_data[UPLOAD_CORE.loadingFile].loaded=true;
        UPLOAD_CORE.UPDATE_CONTENT(UPLOAD_CORE.loadingFile);
        if(UPLOAD_CORE.files_data[UPLOAD_CORE.loadingFile].type != 2){
        UPLOAD_CORE.lastFileLoad=UPLOAD_CORE.loadingFile;
        }
	document.getElementById("upload_b_c_"+UPLOAD_CORE.loadingFile).innerHTML="";
	if(!UPLOAD_CORE.onlyOne){
	UPLOAD_CORE.NEXT_UPLOAD();
	}else{
	UPLOAD_CORE.onlyOne=false;
	UPLOAD_CORE.isLoading=false;
	}
},
UPDATE_CONTENT:function(id){
tempName = document.getElementById("upload_b_n_"+id).innerHTML;    
document.getElementById("upload_b_n_"+id).innerHTML="<a class='uploadClickButton' onclick='javascript:UPLOAD_CORE.SHOW_CONTENT("+id+")'>"+tempName+"</a>";
},
SHOW_CONTENT:function(id){
document.getElementById("fileContent_bg").style.width=window.screen.availWidth+"px";
document.getElementById("fileContent_bg").style.height=window.screen.availHeight+"px";
document.getElementById("fileContent_bg").style.visibility="visible";
var ifr = document.createElement('iframe');
var url = document.URL.split("/");
var rem = url[url.length-1];
var finalURL=document.URL.replace(rem,"");
ifr.src = finalURL+'FileContent.jsp?file='+UPLOAD_CORE.files_data[id].name;
document.getElementById("fileContent_bg_if").innerHTML="";
document.getElementById("fileContent_bg_if").appendChild(ifr);
},
CLOSE:function(){
document.getElementById("fileContent_bg").style.visibility="hidden";
},
RESET_STORAGE:function (){
window.localStorage.clear();
}
};

if(localStorage.getItem("UPLOAD_CORE_DATA")){
window.UPLOAD_CORE.files_data=JSON.parse(localStorage.getItem("UPLOAD_CORE_DATA"));
}

function checkForData(){
if(localStorage.getItem("UPLOAD_C_DATA")){
document.getElementById("file_upload").innerHTML=localStorage.getItem("UPLOAD_C_DATA");
UPLOAD_CORE.files=parseInt(localStorage.getItem("UPLOAD_CORE_DATA_FILES"));
UPLOAD_CORE.lastFileLoad=parseInt(localStorage.getItem("UPLOAD_CORE_DATA_LAST_FILE_ID"));
for(i=0;i<=100;i++){
if(localStorage.getItem("UPLOAD_CORE_DATA_"+i)){  

UPLOAD_CORE.files_data[i]=JSON.parse(localStorage.getItem("UPLOAD_CORE_DATA_"+i));
document.getElementById("file_type_"+i).selectedIndex=UPLOAD_CORE.files_data[i].type;

}
}
}
};



