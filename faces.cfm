<cfsilent>
	<cfset cfcFaint = CreateObject('component', 'faint').init() />
	<cfif cgi.request_method Eq 'post'>
		<cfif StructKeyExists(form, 'newName') And form.newName Neq url.name>
			<cfset cfcFaint.changeNameInDb(url.name, form.newName) />
			<cflocation url="faces.cfm?name=#UrlEncodedFormat(form.newName)#" statusCode="303" />
		</cfif>
	</cfif>
	<cfscript>
		matches = cfcFaint.getFacesFromDb(url.name);
		
		if (Not StructKeyExists(url, 'amount') Or Not IsNumeric(url.amount)) {
			url.amount = 10;
		}
		
		if (Not StructKeyExists(url, 'page') Or Not IsNumeric(url.page) Or url.page * url.amount Gt matches) {
			url.page = 1;
		}
		
		start = (url.page - 1) * url.amount + 1;
		end = Min(start + url.amount - 1, matches);
		
		faces = cfcFaint.getFaces();
	</cfscript>
</cfsilent>
<html>
<head>
</head>
<body><cfoutput>
	<h1><a href="index.cfm">Face Database</a>: #url.name#</h1>
	<form method="post" action="faces.cfm?name=#UrlEncodedFormat(url.name)#">
		<input type="text" name="newName" value="#HtmlEditFormat(url.name)#" />
		<input type="submit" value="Change name" />
	</form>
	<h2>Faces</h2>
	<table>
		<thead>
			<tr>
				<th scope="col">Number</th>
				<th scope="col">Action</th>
				<th scope="col">Preview</th>
			</tr>
		</thead>
		<tbody>
			<cfset faceNum = 0 />
			<cfloop array="#faces#" index="face"><tr>
				<td>#faceNum++#</td>
				<td><form action="faces.cfm?name=#UrlEncodedFormat(url.name)#" method="post">
					<label for="training-#faceNum#-true"><input type="radio" name="training-#faceNum#" id="training-#faceNum#-true" value="true" <cfif face.isUsedForTraining()>checked="checked"</cfif> /> Yes</label><br />
					<label for="training-#faceNum#-false"><input type="radio" name="training-#faceNum#" id="training-#faceNum#-false" value="false" <cfif Not face.isUsedForTraining()>checked="checked"</cfif> /> No</label>
				</form></td>
				<td><cfimage action="writeToBrowser" source="#cfcFaint.getDataDir()#\#face.getCachedFile()#" /></td>
			</tr></cfloop>
		</tbody>
	</table>
</cfoutput></body>
</html>
