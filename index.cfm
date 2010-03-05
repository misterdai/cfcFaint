<cfscript>
	cfcFaint = CreateObject('component', 'faint').init();
	matches = cfcFaint.getFacesFromDb();
	
	if (Not StructKeyExists(url, 'amount') Or Not IsNumeric(url.amount)) {
		url.amount = 10;
	}
	
	if (Not StructKeyExists(url, 'page') Or Not IsNumeric(url.page) Or url.page * url.amount Gt matches) {
		url.page = 1;
	}
	
	start = (url.page - 1) * url.amount + 1;
	end = Min(start + url.amount - 1, matches);
	
	knownFaces = cfcFaint.getNamesFromDb();
</cfscript>
<html>
<head>
</head>
<body>
	<h1>Face Database</h1>
	<h2>Process a new Image</h2>
	<form action="new.cfm" method="post" enctype="multipart/form-data">
		<label for="image">Image:</label><br />
		<input type="file" name="image" id="image" /><br />
		<input type="submit" value="Process" />
	</form>
	<h2>Faces</h2>
	<table>
		<thead>
			<tr>
				<th scope="col">Name</th>
				<th scope="col">Preview</th>
			</tr>
		</thead>
		<tbody>
			<cfloop array="#knownFaces#" index="name"><tr>
				<th scope="row"><cfoutput><a href="faces.cfm?name=#UrlEncodedFormat(name)#">#HtmlEditFormat(name)#</a></cfoutput></th>
				<cfset numberOfFaces = cfcFaint.getFacesFromDb(name) />
				<cfif numberOfFaces Gt 0>
					<cfset face = cfcFaint.getFace(1) />
					<td><cfimage action="writeToBrowser" source="#cfcFaint.getDataDir()#\#face.getCachedFile()#" /></td>
				<cfelse>
					<td>No faces assoicated with this record.</td>
				</cfif>
			</tr></cfloop>
		</tbody>
	</table>
</body>
</html>
