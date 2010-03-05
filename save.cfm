<cfsilent>
	<cfif cgi.request_method Eq 'post'>
		<cfset identified = {} />
		<cfloop collection="#form#" item="field">
			<cfif Left(field, 5) Eq 'name-' And Not StructKeyExists(identified, ListLast(field, '-'))
				Or Left(field, 8) Eq 'newName-' And Len(form[field]) Gt 0>
				<cfset identified[ListLast(field, '-')] = form[field] />
			</cfif>
		</cfloop>
		<cfif StructCount(identified) Gt 0>
			<cfset cfcFaint = CreateObject('component', 'faint').init() />
			<cflock scope="session" type="exclusive" timeout="5" throwOnTimeout="true">
				<cfloop collection="#identified#" item="num">
					<cfset cfcFaint.saveFaceToDb(session.faces[form.image & '-face-' & num], identified[num]) />
				</cfloop>
			</cflock>
		</cfif>
	</cfif>
	<cflocation url="index.cfm" />
</cfsilent>