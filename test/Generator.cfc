<!--- 
   1-30-2007
   Template generation logic

--->
 
 <cfcomponent displayName="Generator" hint="Generates TestCases template">
   
   <cfparam name="this.packages" type="struct" default="#structNew()#" />
   <!--- hint="This is the directory path where the tests and test suites are placed." --->
   <cfparam name="this.basePath" type="string" default=""  />

     
  <cffunction name="Generator" access="remote" returnType="Generator">
   <cfscript>
 
    cfcexplorer = createobject("component","cfide.componentutils.cfcexplorer"); 
    cfcTree = cfcexplorer.getcfcTree(true);
    //let's filter everything in /gateway,/wwroot/cfide
    roots = structNew();
    pacakgesArray = arrayNew(1);
    i = 1;
    for(item in cfcTree){
      //excluded everything in cfide and the gateway mapping
      if (not refindnocase("cfide|/gateway/cfc" , item.toString())  ){
       structinsert(roots,item.toString(),structFind(cfcTree,item.toString() ));
       pacakgesArray[i] = structFind(cfcTree,item.toString());
       i = i + 1;
      }
    }
 
    this.packages = structnew();
    //make a single structure with all the packages and associated component refs
    for (j = 1; j lte arrayLen(pacakgesArray); j = j + 1) {
      for (thing in pacakgesArray[j]){
       structInsert(this.packages,thing,structFind(pacakgesArray[j],thing));
      }
    }
   </cfscript>
    <cfreturn this />
  </cffunction>


<cffunction name="aBunchOfParams"  hint="Does nothing. Used for testing test generation" access="public" returntype="String" mxunit:skip="false" mxunit:tests="5">
    <cfargument name="component" type="WEB-INF.cftags.component" required="true" mxunit:type="component" />
    <cfargument name="aString" type="string" required="true" mxunit:type="sTRIng" mxunit:regex="[a-zA-Z]" mxunit:length="10" />
    <cfargument name="aBoolean" type="boolean" required="false" default="true" mxunit:type="boolean" />
    <cfargument name="aNumber" type="numeric" required="true" mxunit:type="float" mxunit:min="5" mxunit:max="10" mxunit:precision="4"/>
    <cfargument name="anInt" type="numeric" required="true" mxunit:type="int" mxunit:min="5" mxunit:max="10" />
    <cfargument name="noType" />
  
  <cfreturn 'foo' />

</cffunction>


<cffunction name="getPackages" access="public" returntype="struct">
  <cfreturn this.packages />
 <!--- No argument. Returns an arr --->
</cffunction>


<!--- Good all around meta data function --->
<cffunction name="getPackagesAsXml" access="remote" returntype="xml" output="true">
   <cfxml variable="xml">
   <cfscript>
   //generator = Generator();
   packages = getPackages();
   writeoutput("<packages>");  
   for(item in packages){
    writeoutput("<package><name>" & item & "</name>");
    comps = structFind(packages,item);
    for( i = 1 ; i lte arrayLen(comps); i = i + 1) {
     writeoutput("<component>" & comps[i] &  "</component>");
    }
    writeoutput("</package>");
   }
    writeoutput("</packages>");
  </cfscript>
  </cfxml>
  <cfreturn xml />
</cffunction>





<!--- 

  02-06-07
  Loading the package but not the TEST packages!
 --->

<cffunction name="generateTestSuite" access="remote">
  <cfargument name="package" type="string" required="true" />
  <cfargument name="components" type="array" required="true" />
  <cfargument name="subDir" type="string" required="false" default="tests" />
  <cfargument name="testSuitePath" type="string" required="false" default="mxunit.framework.TestSuite" />
   
   
   
   <cfscript>    
     suiteStr = '<cfscript>#chr(10)#';
     suiteStr = suiteStr & 'testSuite = createObject("component","#testSuitePath#");#chr(10)#';
     for(i = 1; i lte arrayLen(arguments.components);i = i + 1){
       suiteStr = suiteStr & 'testSuite.addAll("#package#.#subDir#.#components[i]#Test");#chr(10)#';
     } 
     suiteStr = suiteStr & ' results = testSuite.run();#chr(10)#';
     suiteStr = suiteStr & '</cfscript>#chr(10)#'; 
     suiteStr = suiteStr & '<cfoutput>##results.getHtmlResults()##</cfoutput>#chr(10)#';
     //Instantiate any component to get some metadata
     tempComp = createObject("component","#package#.#components[1]#");
     md = getMetadata(tempComp);
     fileToWrite =  generateFileString(tempComp,subDir);
     //To Do - name the file something better
     //maybe just generated_test_suite_#date#.cfm
     delim = "\";
     fileToWrite = ListSetAt(fileToWrite, listLen(fileToWrite,delim), "GeneratedTestSuite.cfm" , delim );
     //fileToWrite = replace(fileToWrite,"Test.cfc","TestSuite.cfm");
   </cfscript>  
<!--- <cfdump var="#md#"> --->

   <cffile action="write" file="#fileToWrite#" output="#suiteStr#" />
</cffunction>




<!--- 
 Generates a single test file based on the component being passed in and places it in
 a subdirectory /tests/ relative to the component being passed in

 --->
  <cffunction name="generate" access="remote" output="true" returnType="string" hint="">
    <cfargument name="component" type="WEB-INF.cftags.component" required="true" />
    <cfargument name="subDir" type="string" required="false" default="tests" />
    <cfargument name="acceptDefaultValues" type="boolean" required="false" default="true" hint="Todo: When false, generates random data in place of default values" />
    <cfargument name="xUnitPath" type="string" required="false" default="mxunit.framework.TestCase" />
    <cfargument name="overwrite" type="boolean" required="false" default="true" />
    <cfargument name="destination" type="string" required="false" default="/" />
        <cfscript>    
      
        var fileToWrite = generateFileString(arguments.component,subDir);
        var componentText = '<cfcomponent generatedOn="#dateFormat(now(), "mm-dd-yyyy")# #timeformat(now(), "long")#" extends="#arguments.xUnitPath#">#chr(10)# #chr(10)#';
        var md = getMetaData(arguments.component);
            
        componentText = componentText & generateTestMethods(arguments.component);
        componentText = componentText & '#chr(10)#</cfcomponent>';
        
       </cfscript>  
      <cffile action="write" file="#fileToWrite#" output="#componentText#"   />  
     <cfreturn fileToWrite />
  </cffunction>


<!--- Todo:
 Generates test files for each component found in the path passed in.
 ? What should the path format be? System or CF.? Probably CF

 --->
  <cffunction name="generateAll" access="remote" output="true" returnType="any" hint="">
    <cfthrow type="mxunit.exception.NotImplementedException" message="This method is not implemented" />
    <!--- <cfargument name="path" type="string" required="true" />
    <cfargument name="overwrite" type="boolean" required="false" default="true" />
    <cfargument name="destination" type="string" required="false" default="/" />
      <cfscript>
      </cfscript> 
     <cfreturn "Not implemented" />   --->
  </cffunction>
  
  
  
<!--- ~~~~~~~~~~  Private Util methods ~~~~~~~~~~ --->

<!--- 

  To Do: Add Params
  To Do: Research Random number and text generation.
  To Do: decouple test data generation from this component

 --->

<cffunction name="generateTestMethods" access="public" returnType="string">
  <cfargument name="component" required="true" type="WEB-INF.cftags.component" />
  <!--- 
  Algorithm: iterate over component and build a cffuntion for every public and remote method,
  prepending the name with test and capitalizing the next letter in the method's name'
   --->
    <cfscript>
      var i = 1;//iterator index
      var j = 1;//iterator index
      var testMethods = '';
      var md = getMetaData(arguments.component);
      var cName = '';
      var paramString = '';
      var methods = arrayNew(1);
      if(not isDefined("md.functions") ){
       return '<!--- No methods found in this component --->';
      }
      methods = md.functions;
      instanceName = listLast(md.name, ".")  ;
      
      //Make mixed case variable name
      firstLetter = lCase(left(instanceName,1));
      lastLetters = right(instanceName, len(instanceName)-1);
      instanceName = firstLetter & lastLetters; 
      //writeoutput(instanceName );

      for(i = 1; i lte arrayLen(methods); i = i +1){
        method = methods[i]; //struct
        
        if( structKeyExists(method,"mxunit:skip") ) {
          if(method["mxunit:skip"] is true){
          return; //don't write a test for this method
          }
        }
        
        if( structKeyExists(method,"mxunit:tests") ) {
          numberOfTests = method["mxunit:tests"];
        }   
        //dump(method);
        
        if(isDefined("method.access")){
          
        if(method.access is not 'private'){ //can't yet test private methods'  
         firstLetter = uCase(left(method.name,1));
         lastLetters = right(method.name, len(method.name)-1);
         name = 'test' & firstLetter & lastLetters;
         testMethods = testMethods & '#chr(10)#<cffunction name="#name#">#chr(10)#';  //use default puplic access   
         testMethods = testMethods & '';
         //Here's where to insert the loop from the mxunit:tests param
         testMethods = testMethods & '  <cfinvoke component="##this.#instanceName###"  method="#methods[i].name#" returnVariable="actual">#chr(10)#';
         params = methods[i].parameters;
         testMethods = testMethods & generateTestArguments(params);
         testMethods = testMethods & '  </cfinvoke>#chr(10)#'; 
         testMethods = testMethods & '  <!--- Make me pass! --->#chr(10)#'; 
         testMethods = testMethods & '  <cfset assertTrue(false) />#chr(10)#';
         testMethods = testMethods & '#chr(10)#</cffunction>#chr(10)##chr(10)#';
       }
      }//end if isDefined
      }
      
   
      testMethods = testMethods & '#chr(10)#<!--- Override these methods as needed. Note that the call to setUp() is Required if using a this-scoped instance--->#chr(10)#';
      testMethods = testMethods & '#chr(10)#<cffunction name="setUp">#chr(10)#';
      testMethods = testMethods & '<!--- Assumption: Instantiate an instance of the component we want to test --->#chr(10)#';
      testMethods = testMethods & '<cfset this.#instanceName# = createObject("component","#md.name#") />#chr(10)#';
      testMethods = testMethods & '<!--- Add additional set up code here--->#chr(10)#';
      testMethods = testMethods & '</cffunction>#chr(10)# #chr(10)#';

      testMethods = testMethods & '#chr(10)#<cffunction name="tearDown">#chr(10)#</cffunction>#chr(10)##chr(10)#';
       /* */
    </cfscript> 
  <cfreturn testMethods />
</cffunction>  
  
  
  <cffunction name="generateTestArguments" access="private" returntype="string">
    <cfargument name="params" type="array" />
    <cfscript>
     var val = '';
     var args = '';
     var i = 1;
     var param = '';
     //dump(params);
     //Insert new method call here
     
     for(i = 1; i lte arrayLen(arguments.params); i = i + 1){
      param = arguments.params[i];
       val = generateTestParameterValue(param);
       //dump(param);
       args = args & '    <cfinvokeargument name="#arguments.params[i].name#" value="#val#" />#chr(10)#';       
     }
    </cfscript>
    <cfreturn args />
  </cffunction>


<!--- Can return  "any" type, int, float, string, query, xml, array, struct (to do: generate complex objects) --->
<cffunction name="generateTestParameterValue" returntype="any">
  <cfargument name="param" type="struct" required="true" />
  <cfset var retval = "" />
  <cfset var min = -1 />
  <cfset var max =  1 />
  <cfset var len =  0 />
  <cfset var regex = "" />
   <cfscript>
     //Note: Dependent upon applicaion.cfc
     var testDataGenerator = createObject("component","#request.mxunitRoot#.generator.TestDataGenerator").TestDataGenerator();
    // val = generateTestParameterValue(param);
     if( structKeyExists(param,"mxunit:type") ) {
       switch(param["mxunit:type"]){
          
          //Integer
          case 'int':
            if( structKeyExists(param,"mxunit:min") ) {
              min = param["mxunit:min"];
            } 
            else{
             min = testDataGenerator.minInt;
            }
            
            if( structKeyExists(param,"mxunit:max") ) {
              max = param["mxunit:max"];
            } 
            else{
             max = testDataGenerator.maxInt;
            }           
           retval = testDataGenerator.genInteger(min,max);
          break;
          
          case 'string':
           if( structKeyExists(param,"mxunit:len") ) {
              len = param["mxunit:len"];
            } 
            else{
             len = testDataGenerator.stringLen;
            }
            
            if( structKeyExists(param,"mxunit:regex") ) {
              regex = param["mxunit:regex"];
            } 
            else{
             regex = testDataGenerator.defaultRegEx;
            }
           retval = testDataGenerator.genString(len,regex);
          break;
          
          
          case 'boolean':
           retval = testDataGenerator.genBoolean();
          break;
          
          default:
          retval = '';
          break;
         }
       }
  </cfscript>
  <cfreturn retval />
</cffunction>

<cffunction name="generateFileString" access="private" returntype="string">
   <cfargument name="component" required="true" type="WEB-INF.cftags.component" />
   <cfargument name="subDir" required="false" type="string" default="tests" />
    <cfscript>
      var md = getMetaData(arguments.component);
      var directory = generateTestDirectory(arguments.component,subDir);
      var testFile = getFileFromPath(md.path);
      //Apend Test to the original component name as per best practices
      var fileToWrite = directory & left(testFile,find("." , testFile)-1) & "Test.cfc";
      return fileToWrite;
    </cfscript> 
   </cffunction>  


<cffunction name="generateTestDirectory" access="private" returntype="string">
   <cfargument name="component" required="true" type="WEB-INF.cftags.component" />
    <cfargument name="dirName" required="false" type="string" default="tests" />
    <cfscript>
      var sys = createObject("java","java.lang.System");
      var fileSeparator = sys.getProperty("file.separator");
      var md = getMetaData(arguments.component);
      var directory = getDirectoryFromPath(md.path);
      var directoryToCreate = directory & dirName & fileSeparator; //To Do: test on unix box
    </cfscript>    
    <cftry>
      <!--- 
        If this fails, it's probably because the directory exists, so, we can safely ignore
        The error and write the file
        --->
    <cfdirectory action="create" directory="#directoryToCreate#" />
     <cfcatch type="any"></cfcatch>
    </cftry>
   <cfreturn directoryToCreate />
  </cffunction>



<cffunction name="dump" access="private">
   <cfargument name="obj" required="true" type="any">
   <cfargument name="label" required="false" default="MXUNIT Dump" />
   <cfdump var="#arguments.obj#" label="#arguments.label#" expand="false" />
  </cffunction>

</cfcomponent>
















