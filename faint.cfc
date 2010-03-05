<cfcomponent output="false">
	<cfscript>
		variables.tnWidth = 100;
		variables.tnHeight = 100;
	</cfscript>
	
	<cffunction name="init" output="true">
		<cfargument name="tnWidth" type="numeric" required="false" default="#variables.tnWidth#" />
		<cfargument name="tnHeight" type="numeric" required="false" default="#variables.tnHeight#" />
		<cfscript>
			variables.tnWidth = arguments.tnWidth;
			variables.tnHeight = arguments.tnHeight;
			variables.jTnSize = CreateObject("java", "java.awt.Dimension").init(variables.tnWidth, variables.tnHeight);
			variables.jFaint = CreateObject('java', 'de.offis.faint.controller.MainController').getInstance();
			variables.dataDir = variables.jFaint.getDataDir();
			variables.jDb = jFaint.getFaceDB();
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="detectFaces" output="false" returntype="numeric">
		<cfargument name="imagePath" type="string" required="true" />
		<cfargument name="saveToDb" type="boolean" required="false" default="true" />
		<cfscript>
			variables.jModel = CreateObject('java', 'de.offis.faint.model.ImageModel').init(arguments.imagePath);
			variables.jRegions = variables.jFaint.detectFaces(variables.jModel, JavaCast('boolean', arguments.saveToDb));
			if (StructKeyExists(variables, 'jRegions')) {
				return ArrayLen(variables.jRegions);
			} else {
				return 0;
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="getScanWindowSize" output="false" returntype="numeric">
		<cfreturn variables.jFaint.getScanWindowSize() />
	</cffunction>

	<cffunction name="setScanWindowSize" output="false">
		<cfargument name="percent" type="numeric" required="true" />
		<cfset variables.jFaint.setScanWindowSize(arguments.percent) />
	</cffunction>
	
	<cffunction name="saveToDb" output="false">
		<cfargument name="faceNum" type="numeric" required="true" />
		<cfargument name="faceName" type="string" required="true" />
		<cfscript>
			variables.jDb.put(variables.jRegions[arguments.faceNum], arguments.faceName);
			variables.jDb.writeToDisk();
		</cfscript>
	</cffunction>
	
	<cffunction name="saveFaceToDb" output="false">
		<cfargument name="face" required="true" />
		<cfargument name="faceName" type="string" required="true" />
		<cfscript>
			variables.jDb.put(arguments.face, arguments.faceName);
			variables.jDb.writeToDisk();
		</cfscript>
	</cffunction>
	
	<cffunction name="getFacesFromDb" output="false" returntype="numeric">
		<cfargument name="faceName" type="string" required="false" />
		<cfscript>
			if (StructKeyExists(arguments, 'faceName')) {
				variables.jRegions = variables.jDb.getRegionsForFace(arguments.faceName);
			} else {
				variables.jRegions = variables.jDb.getKnownFaces();
			}
			if (StructKeyExists(variables, 'jRegions')) {
				return ArrayLen(variables.jRegions);
			} else {
				return 0;
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="getNamesFromDb" output="false">
		<cfscript>
			var local = {};
			local.names = variables.jDb.getExistingAnnotations();
			if (StructKeyExists(local, 'names')) {
				return local.names;
			} else {
				return ArrayNew(1);
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="getFace" output="false">
		<cfargument name="matchNum" type="numeric" required="false" />
		<cfscript>
			return variables.jRegions[arguments.matchNum];
		</cfscript>
	</cffunction>

	<cffunction name="getFaces" output="false">
		<cfscript>
			if (StructKeyExists(variables, 'jRegions')) {
				return variables.jRegions;
			} else {
				return ArrayNew(1);
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="getThumbnail" output="false">
		<cfargument name="face" required="true" />
		<cfscript>
			var local = {};
			local.thumbnail = arguments.face.toThumbnail(variables.jTnSize);
			return ImageNew(local.thumbnail);
		</cfscript>
	</cffunction>
	
	<cffunction name="getDataDir" output="false" returntype="string">
		<cfreturn variables.dataDir />
	</cffunction>
	
	<cffunction name="changeNameInDb" output="false">
		<cfargument name="oldName" type="string" required="true" />
		<cfargument name="newName" type="string" required="true" />
		<cfset variables.jDb.renameAnnotation(arguments.oldName, arguments.newName) />
	</cffunction>
	
	<cffunction name="recogniseFace" output="false">
		<cfargument name="face" required="true" />
		<cfscript>
			var local = {};
			local.matches = variables.jFaint.recognizeFace(arguments.face);
			if (StructKeyExists(local, 'matches')) {
				return local.matches;
			} else {
				return 0;
			}
		</cfscript>
	</cffunction>
</cfcomponent>