<!---
 MXUnit TestCase Template
 @author
 @description
 @history
 --->

<cfcomponent  extends="mxunit.framework.TestCase">

<!--- Begin Specific Test Cases --->
	<cffunction name="testGenerator" access="public" returntype="void">
	  <cfset assertIsTypeOf(this.generator, "mxunit.generator.Generator") />
	</cffunction>


	<cffunction name="testGenerate" access="public" returntype="void">
      <cfscript>
        testFile = this.generator.generate(this.generator);

        traceString = "testFile = " & testFile & chr(10);
        //traceString = traceString & "file = " & fileToWrite;
        addTrace(traceString);
        assertTrue(fileExists(testFile));
        //dump(md);
      </cfscript>
	</cffunction>

  <cffunction name="testGenerateMethods">
         <cfscript>

         str = this.generator.generateTestMethods(this) ;
         //addTrace(str);

      </cfscript>
  <cfoutput>
    <!--- <xmp>#str#</xmp> --->
  </cfoutput>
  </cffunction>
	<!---

<cffunction name="testSomethingElse2" access="public" returntype="void">

	</cffunction> --->
<!--- End Specific Test Cases --->


	<cffunction name="setUp" access="public" returntype="void">
	  <!--- Place additional setUp and initialization code here --->
      <cfset this.generator = createObject("component","Generator").Generator() />
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void">
	 <!--- Place tearDown/clean up code here --->
	</cffunction>


</cfcomponent>
