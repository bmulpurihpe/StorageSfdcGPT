//TS-10325 start
/*
@description    : Added by Exafort for TS-10325: Enable and disable the 'Save' button during the rerender process of TA/TSA selection.
*/
function disableSaveButton() {
try {
	var elem = document.querySelectorAll('input[id$="saveButton"]');   
	//Disable the save Button of both top and bottom in page block section
	$("[id$=text1]").prop("disabled",true);
	$("[id$=subTechArea]").prop("disabled",true);
	document.body.style.cursor='wait';
	for(var i=0; i<elem.length; i++){ 
		var currentElement = elem[i];
		currentElement.disabled = true;
		currentElement.style.backgroundColor = '#c1bebe'; 
		currentElement.style.color = '#999999'; 
		currentElement.style.cursor = 'not-allowed';          
	}  
	
}
catch (error) {
	// Code to handle the exception
	console.error('Caught an error:', error.message);
}

} 
function enableSaveButton() {
	try{
		var elem = document.querySelectorAll('input[id$="saveButton"]'); 
		//enable the save Button of both top and bottom in page block section
		$("[id$=text1]").prop("disabled",false);
		$("[id$=subTechArea]").prop("disabled",false);
		document.body.style.cursor='default';
		for(var i=0; i<elem.length; i++){            
			var currentElement = elem[i];
			currentElement.disabled = false;
			currentElement.style.backgroundColor = '#e8e8e9'; 
			currentElement.style.color = '#333'; 
			currentElement.style.cursor = '';          
		}    
	}
	catch (error) {
		// Code to handle the exception
		console.error('Caught an error:', error.message);
	}
} 
//End of TS-10325