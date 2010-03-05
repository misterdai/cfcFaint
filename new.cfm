<cfsilent>
	<cfset cfcFaint = CreateObject('component', 'faint').init() />
	<cfif Not StructKeyExists(form, 'windowSize')>
		<cfset form.windowSize = cfcFaint.getScanWindowSize() />
	<cfelse>
		<cfset cfcFaint.setScanWindowSize(form.windowSize) />
	</cfif>
	<cfif StructKeyExists(form, 'redetect')>
		<cfset filename = form.redetect />
		<cfset filepath = ExpandPath('images/' & filename) />
	<cfelse>
		<cftry>
			<cffile action="upload" fileField="image" destination="#ExpandPath('images')#" nameConflict="error" />
			<cfset filename = cfFile.serverFile />
			<cfset filepath = cfFile.serverDirectory & '/' & filename />
			<cfcatch type="any">
				<cflocation url="index.cfm" />
			</cfcatch>
		</cftry>
	</cfif>
	<cfimage source="#filepath#" name="img" />
	<cfset imgInfo = ImageInfo(img) />
	<cfset numFacesDb = cfcFaint.getFacesFromDb() />
	<cfset facesDetected = cfcFaint.detectFaces(filepath) />
</cfsilent>
<cfoutput>
<h1><a href="index.cfm">Face Detection</a>: New image</h1>

Found <cfoutput>#facesDetected#</cfoutput> face(s).<br />

<form action="new.cfm" method="post">
	<input type="hidden" name="redetect" value="#HtmlEditFormat(filename)#" />
	<label for="windowSize">Detection Window size [percentage] (Default: 15% = #Round(Min(imgInfo.height, imgInfo.width) * form.windowSize / 100)#px)</label><br />
	<input type="text" name="windowSize" id="windowSize" value="#form.windowSize#" /><br />
	<input type="submit" value="Redetect" />
</form>

<img src="images/#UrlEncodedFormat(filename)#" width="600" />
</cfoutput>
<hr />


<cfset faces = cfcFaint.getFaces() />

<form action="save.cfm" method="post">
<cfoutput><input type="hidden" name="image" value="#filename#" /></cfoutput>
<cfloop from="1" to="#facesDetected#" index="f">
	<cfoutput>
		<cfimage action="writeToBrowser" source="#cfcFaint.getThumbnail(faces[f])#" /><br />
		Possible matches:<br />
		<cfif numFacesDb Gt 0>
			<cfset recognised = cfcFaint.recogniseFace(faces[f]) />
			<table>
				<cfloop collection="#recognised#" item="posname">
					<tr>
						<th scope="row">#HtmlEditFormat(posName)#</th>
						<td>#recognised[posname]#</td>
						<td><input type="radio" name="name-#f#" value="#HtmlEditFormat(posName)#" /></td>
					</tr>
				</cfloop>
			</table>
		</cfif>
		<label for="newName-#f#">New name:</label><br />
		<input type="text" name="newName-#f#" id="newName-#f#" value="" /><br />
		<cflock scope="session" type="exclusive" timeout="5" throwOnTimeout="true">
			<cfset session.faces[filename & '-face-' & f] = faces[f] />
		</cflock>
	</cfoutput>
</cfloop>
<input type="submit" value="Save" />
</form>